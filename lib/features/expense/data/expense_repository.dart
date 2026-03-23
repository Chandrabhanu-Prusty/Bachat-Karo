import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';

class ExpenseRepository {
  final SupabaseClient _client;
  ExpenseRepository(this._client);

  String get _uid => _client.auth.currentUser!.id;

  String _p(int n) => n.toString().padLeft(2, '0');

  Future<List<ExpenseModel>> fetchByMonth(int year, int month) async {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final from = '$year-${_p(month)}-01';
    final to   = '$year-${_p(month)}-${_p(daysInMonth)}';

    final res = await _client
        .from('expenses')
        .select()
        .eq('user_id', _uid)
        .gte('expense_date', from)
        .lte('expense_date', to)
        .order('expense_date', ascending: false);

    return (res as List).map((r) => ExpenseModel.fromJson(r)).toList();
  }

  Future<ExpenseModel> create({
    required double amount,
    required String description,
    required DateTime date,
    required ExpenseCategory category,
    String source = 'manual',
  }) async {
    final payload = {
      'user_id':      _uid,
      'amount':       amount,
      'description':  description,
      'expense_date': '${date.year}-${_p(date.month)}-${_p(date.day)}',
      'category':     category.dbValue,
      'source':       source,
    };
    final res = await _client
        .from('expenses')
        .insert(payload)
        .select()
        .single();
    return ExpenseModel.fromJson(res);
  }

  Future<void> delete(String id) =>
      _client.from('expenses').delete().eq('id', id).eq('user_id', _uid);

  Future<ExpenseModel> update(ExpenseModel e) async {
    final res = await _client
        .from('expenses')
        .update(e.toInsertJson())
        .eq('id', e.id)
        .select()
        .single();
    return ExpenseModel.fromJson(res);
  }
}
