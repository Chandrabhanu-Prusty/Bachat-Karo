import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches or generates AI spending suggestions via the
/// `generate-suggestions` Supabase Edge Function (Groq llama-3.3-70b-versatile).
///
/// Suggestions are cached in the `ai_suggestions` Supabase table.
/// They are only regenerated when the cache is older than [_cacheDays] days,
/// so we never call Groq on every app open.
class InsightsRepository {
  final SupabaseClient _client;
  static const int _cacheDays = 7;

  InsightsRepository(this._client);

  /// Returns the user's 3 AI-generated saving suggestions.
  ///
  /// If a fresh cache exists (≤ [_cacheDays] days old) the cached list is
  /// returned without calling Groq. Otherwise the Edge Function is invoked and
  /// the new suggestions are cached automatically by the function.
  Future<List<String>> getSuggestions({
    required Map<String, dynamic> summaryData,
  }) async {
    final uid = _client.auth.currentUser!.id;

    // 1. Check cache
    final cached = await _client
        .from('ai_suggestions')
        .select()
        .eq('user_id', uid)
        .maybeSingle();

    if (cached != null) {
      final generatedAt = DateTime.parse(cached['generated_at'] as String);
      final age         = DateTime.now().difference(generatedAt);

      if (age.inDays < _cacheDays) {
        // Fresh cache — return without calling Groq
        return List<String>.from(cached['suggestions'] as List);
      }
    }

    // 2. Generate fresh suggestions via Edge Function
    final response = await _client.functions.invoke(
      'generate-suggestions',
      body: {
        'userId':      uid,
        'summaryData': summaryData,
      },
    );

    final data = response.data as Map<String, dynamic>?;
    if (data == null || data['success'] != true) {
      throw Exception(data?['error'] ?? 'Failed to generate suggestions');
    }

    return List<String>.from(data['suggestions'] as List);
  }

  /// Force-refreshes suggestions regardless of cache age.
  /// Call this when the user manually taps a "Refresh" button.
  Future<List<String>> refreshSuggestions({
    required Map<String, dynamic> summaryData,
  }) async {
    final uid = _client.auth.currentUser!.id;

    final response = await _client.functions.invoke(
      'generate-suggestions',
      body: {
        'userId':      uid,
        'summaryData': summaryData,
      },
    );

    final data = response.data as Map<String, dynamic>?;
    if (data == null || data['success'] != true) {
      throw Exception(data?['error'] ?? 'Failed to generate suggestions');
    }

    return List<String>.from(data['suggestions'] as List);
  }
}
