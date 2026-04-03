import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/models.dart';

/// Handles all file import I/O:
///  1. Picking a file from the device
///  2. Uploading it to Supabase Storage (`import-files` bucket)
///  3. Calling the `parse-import` Edge Function (Groq LLM)
///  4. Returning structured [ParsedExpenseRow] list for the preview screen
///
/// For the paste flow, step 1 and 2 are skipped — raw text is sent directly.
class ImportRepository {
  final SupabaseClient _client;

  ImportRepository(this._client);

  // ── File picker ───────────────────────────────────────────────────────────

  /// Opens the platform file picker and returns the selected file.
  /// Returns null if the user cancelled.
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv', 'xlsx', 'xls', 'docx', 'doc'],
      withData: true,       // loads bytes into memory
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;

    // 25 MB cap
    if (file.size > 25 * 1024 * 1024) {
      throw Exception('File is too large. Maximum allowed size is 25 MB.');
    }

    return file;
  }

  // ── Storage upload ────────────────────────────────────────────────────────

  /// Uploads [bytes] to the `import-files` Supabase Storage bucket.
  /// Returns the storage path (used later by the Edge Function).
  Future<String> uploadFile(Uint8List bytes, String fileName) async {
    final uid       = _client.auth.currentUser!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path      = 'imports/$uid/${timestamp}_$fileName';

    await _client.storage.from('import-files').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: false),
        );

    return path;
  }

  // ── Edge Function call ────────────────────────────────────────────────────

  /// Calls the `parse-import` Supabase Edge Function.
  ///
  /// Supply **either**:
  ///  - [storagePath] + [extension] → file flow (downloaded inside the function)
  ///  - [rawText]                   → paste flow (text parsed directly)
  Future<List<ParsedExpenseRow>> parseImport({
    String? storagePath,
    String? extension,
    String? rawText,
  }) async {
    assert(
      rawText != null || (storagePath != null && extension != null),
      'Provide either rawText or both storagePath + extension',
    );

    final response = await _client.functions.invoke(
      'parse-import',
      body: {
        if (storagePath != null) 'storagePath': storagePath,
        if (extension != null)   'extension':   extension,
        if (rawText != null)     'rawText':      rawText,
      },
    );

    final data = response.data as Map<String, dynamic>?;

    if (data == null || data['success'] != true) {
      final err = data?['error'] ?? 'Unknown error from parse-import';
      throw Exception('AI extraction failed: $err');
    }

    final rows = data['rows'] as List<dynamic>;
    return rows
        .map((r) => ParsedExpenseRow.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Combined: pick → upload → parse ──────────────────────────────────────

  /// Full file-import flow in one call:
  ///  pick file → upload to storage → call Edge Function → return rows
  Future<List<ParsedExpenseRow>> importFromFile() async {
    final file = await pickFile();
    if (file == null) return []; // user cancelled

    final storagePath = await uploadFile(file.bytes!, file.name);
    return parseImport(
      storagePath: storagePath,
      extension: file.extension ?? 'txt',
    );
  }

  // ── Paste flow ────────────────────────────────────────────────────────────

  /// Text-paste flow — no file, no storage upload needed.
  Future<List<ParsedExpenseRow>> importFromText(String text) async {
    if (text.trim().isEmpty) throw Exception('Please enter some text to import.');
    return parseImport(rawText: text);
  }

  // ── Bulk insert confirmed rows ────────────────────────────────────────────

  /// Inserts all selected [rows] into the `expenses` Supabase table in one batch.
  Future<void> confirmImport(List<ParsedExpenseRow> rows) async {
    final uid     = _client.auth.currentUser!.id;
    final records = rows
        .where((r) => r.isSelected)
        .map((r) => {
              'user_id':      uid,
              'amount':       r.amount,
              'description':  r.description,
              'expense_date': r.date,
              'category':     r.category.dbValue,
              'source':       'import',
            })
        .toList();

    if (records.isEmpty) return;

    await _client.from('expenses').insert(records);
  }
}
