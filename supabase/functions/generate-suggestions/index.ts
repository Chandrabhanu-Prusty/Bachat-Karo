// @ts-ignore - Deno is available in Supabase Edge Functions
declare const Deno: any

// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions'

// ── Groq suggestion call ──────────────────────────────────────────────────────

async function generateSuggestionsWithGroq(
  summaryData: object,
  groqKey: string
): Promise<string[]> {

  const prompt = `You are a personal finance advisor for Indian users.

Given this user's spending summary for the past 30 days:
${JSON.stringify(summaryData, null, 2)}

Generate exactly 3 short, specific, actionable saving suggestions.

RULES (follow strictly):
- Base EVERY suggestion on the actual numbers in the data. No generic advice.
- Use Indian Rupees (₹). Reference specific amounts from the data.
- Each suggestion must be maximum 2 sentences.
- Tone: friendly, encouraging, not preachy.
- Return ONLY a JSON array of exactly 3 strings.
- No markdown, no code fences, no explanation outside the array.

Example of correct output format:
["You spent ₹4,200 on food this month across 14 orders. Cooking dinner 4 nights a week could save you around ₹1,200.", "Your travel spending of ₹1,800 is your second biggest expense. A metro monthly pass at ₹700 could cut this cost by half.", "You are close to your monthly budget of ₹25,000. Setting a daily cap of ₹800 for the rest of the month would keep you on track."]

Return only the JSON array, nothing else.`

  const response = await fetch(GROQ_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${groqKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      temperature: 0.3,
      max_tokens: 500,
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

  // Handle text before the array
  const arrayStart = content.indexOf('[')
  if (arrayStart > 0) content = content.slice(arrayStart)

  try {
    const suggestions = JSON.parse(content)
    if (Array.isArray(suggestions)) {
      return suggestions.slice(0, 3).map(String)
    }
    return []
  } catch (e) {
    console.error('JSON parse failed:', content)
    return [
      'Could not generate suggestions right now. Add more expenses to see personalized tips.',
      'Track your spending daily for a week to unlock better insights.',
      'Try importing your bank statement for a complete financial picture.',
    ]
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
    const { userId, summaryData } = body

    if (!userId) throw new Error('userId is required')
    if (!summaryData) throw new Error('summaryData is required')

    const groqKey = Deno.env.get('GROQ_API_KEY')
    if (!groqKey) throw new Error('GROQ_API_KEY secret is not set')

    // Generate suggestions from Groq
    const suggestions = await generateSuggestionsWithGroq(summaryData, groqKey)

    // Cache in DB (upsert — one row per user)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { error } = await supabase.from('ai_suggestions').upsert(
      {
        user_id:      userId,
        suggestions:  suggestions,
        generated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' }
    )

    if (error) {
      // Log but don't fail — suggestions are still returned
      console.error('Failed to cache suggestions:', error.message)
    }

    return new Response(
      JSON.stringify({ success: true, suggestions }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error('generate-suggestions error:', error)
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
