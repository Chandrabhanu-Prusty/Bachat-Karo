// @ts-ignore - Deno is available in Supabase Edge Functions
declare const Deno: any

// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions'

// ── Text extraction by file type ─────────────────────────────────────────────

async function extractText(bytes: Uint8Array, extension: string): Promise<string> {
  switch (extension.toLowerCase()) {

    case 'txt':
    case 'csv': {
      return new TextDecoder().decode(bytes)
    }

    case 'xlsx':
    case 'xls': {
      // Parse Excel using a lightweight XLSX reader
      // We convert each row to a tab-separated line
      // @ts-ignore
      const { read, utils } = await import('https://esm.sh/xlsx@0.18.5')
      const workbook = read(bytes, { type: 'array' })
      const sheet = workbook.Sheets[workbook.SheetNames[0]]
      const rows: unknown[][] = utils.sheet_to_json(sheet, { header: 1 })
      return rows
        .filter((row) => row.some((cell) => cell !== null && cell !== undefined && cell !== ''))
        .map((row) => row.join('\t'))
        .join('\n')
    }

    case 'docx':
    case 'doc': {
      // DOCX is a ZIP — extract word/document.xml and strip tags
      // @ts-ignore
      const { BlobReader, ZipReader, BlobWriter } = await import('https://deno.land/x/zipjs@v2.7.32/index.js')
      // @ts-ignore
      const blob = new Blob([bytes])
      const zipReader = new ZipReader(new BlobReader(blob))
      const entries = await zipReader.getEntries()
      const docEntry = entries.find((e: any) => e.filename === 'word/document.xml')
      if (!docEntry) throw new Error('Could not read .docx — word/document.xml not found')
      const xmlBlob = await docEntry.getData!(new BlobWriter())
      const xml = await xmlBlob.text()
      await zipReader.close()
      // Strip XML tags to get plain text
      return xml.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim()
    }

    default:
      // Fallback: try plain text decode
      return new TextDecoder().decode(bytes)
  }
}

// ── Groq extraction call ──────────────────────────────────────────────────────

async function extractExpensesWithGroq(
  rawText: string,
  groqKey: string
): Promise<object[]> {
  const today = new Date().toISOString().split('T')[0]

  const prompt = `You are an expense extraction engine. Extract all expense entries from the text below.

RULES (follow strictly):
- Return ONLY a JSON array of arrays. No explanation, no markdown, no code fences.
- Format: [ ["YYYY-MM-DD", amount, "description", "category"], ... ]
- DO NOT return objects with keys like "date" or "amount". Return only the inner values.
- Valid categories: food, travel, shopping, bills, entertainment, health, education, personalCare, rent, others
- The year for these expenses is 2026.
- If amount is missing, SKIP that entry.
- Categorize accurately:
    - xerox, print, pen, pages -> education
    - auto, parking, ticket, bus, train -> travel
    - physiotherapy, doctor -> health

TEXT TO EXTRACT FROM:
"""
${rawText.slice(0, 8000)}
"""

Return only the flat JSON array of arrays.`

  const response = await fetch(GROQ_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${groqKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      temperature: 0,
      max_tokens: 4096,
      messages: [{ role: 'user', content: prompt }],
    }),
  })

  if (!response.ok) {
    const err = await response.text()
    throw new Error(`Groq API error ${response.status}: ${err}`)
  }

  const data = await response.json()
  let content: string = data.choices?.[0]?.message?.content ?? '[]'

  // Strip markdown code fences
  content = content.replace(/```json\s*/gi, '').replace(/```\s*/g, '').trim()

  const arrayStart = content.indexOf('[')
  if (arrayStart >= 0) content = content.slice(arrayStart)

  try {
    const rows = JSON.parse(content)
    if (!Array.isArray(rows)) return []
    
    // Map array of arrays back to objects for the Flutter app
    return rows.map((r: any) => ({
      date: r[0],
      amount: r[1],
      description: r[2],
      category: r[3]
    }))
  } catch (e) {
    console.error('JSON parse failed. Raw content:', content)
    return []
  }
}

// ── Main handler ─────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const body = await req.json()
    const { storagePath, extension, rawText } = body

    const groqKey = Deno.env.get('GROQ_API_KEY')
    if (!groqKey) throw new Error('GROQ_API_KEY secret is not set')

    let textToProcess: string

    if (rawText && rawText.trim().length > 0) {
      // ── Paste flow: text came directly from Flutter ───────────────────────
      textToProcess = rawText
    } else if (storagePath && extension) {
      // ── File flow: download from Supabase Storage ─────────────────────────
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      )

      const { data, error } = await supabase.storage
        .from('import-files')
        .download(storagePath)

      if (error) throw new Error(`Storage download failed: ${error.message}`)

      const bytes = new Uint8Array(await (data as Blob).arrayBuffer())
      textToProcess = await extractText(bytes, extension)
    } else {
      throw new Error('Request must include either rawText or both storagePath + extension')
    }

    if (!textToProcess || textToProcess.trim().length < 5) {
      throw new Error('Extracted text is empty — file may be empty or unsupported format')
    }

    // Call Groq
    const expenses = await extractExpensesWithGroq(textToProcess, groqKey)

    return new Response(
      JSON.stringify({ success: true, rows: expenses, count: expenses.length }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error('parse-import error:', error)
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
