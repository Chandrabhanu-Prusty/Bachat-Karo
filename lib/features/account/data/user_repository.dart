import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';

class UserRepository {
  final SupabaseClient _client;
  UserRepository(this._client);

  Future<UserModel> fetchProfile(String userId) async {
    final row = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    final email = _client.auth.currentUser!.email!;
    return UserModel.fromJson(row, email);
  }

  Future<void> updateBudget(String userId, double budget) =>
      _client.from('users').update({'monthly_budget': budget}).eq('id', userId);

  Future<void> updatePreferences(
    String userId, {
    bool? notifEnabled,
    String? notifTime,
    String? theme,
  }) {
    final updates = <String, dynamic>{};
    if (notifEnabled != null) updates['notif_enabled'] = notifEnabled;
    if (notifTime != null)    updates['notif_time']    = notifTime;
    if (theme != null)        updates['theme']          = theme;
    return _client.from('users').update(updates).eq('id', userId);
  }
}
