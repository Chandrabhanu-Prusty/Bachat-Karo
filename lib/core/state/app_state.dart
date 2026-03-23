import 'package:flutter/material.dart';
import '../../shared/models/models.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/expense/data/expense_repository.dart';
import '../../features/account/data/user_repository.dart';

/// Single source of truth for all in-memory app data.
///
/// Acts as an optimistic cache in front of Supabase repositories.
/// Screens NEVER touch repositories directly — all I/O goes through here.
class AppState extends ChangeNotifier {
  final AuthRepository    _authRepo;
  final ExpenseRepository _expenseRepo;
  final UserRepository    _userRepo;

  AppState({
    required AuthRepository    authRepo,
    required ExpenseRepository expenseRepo,
    required UserRepository    userRepo,
  })  : _authRepo    = authRepo,
        _expenseRepo = expenseRepo,
        _userRepo    = userRepo;

  // ── Loading / Error ───────────────────────────────────────────────────────

  bool      _isLoading  = false;
  bool      get isLoading  => _isLoading;

  String?   _lastError;
  String?   get lastError  => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  // ── Reminder time ─────────────────────────────────────────────────────────

  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay get reminderTime => _reminderTime;

  String get reminderTimeLabel {
    final h = _reminderTime.hourOfPeriod == 0 ? 12 : _reminderTime.hourOfPeriod;
    final m = _reminderTime.minute.toString().padLeft(2, '0');
    final period = _reminderTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void updateReminderTime(TimeOfDay t) {
    _reminderTime = t;
    notifyListeners();
  }

  // ── User ──────────────────────────────────────────────────────────────────

  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // ── Hydration ─────────────────────────────────────────────────────────────

  /// Called by AuthGate when a valid session is detected.
  /// Loads user profile + current month expenses from Supabase.
  Future<void> hydrateFromBackend() async {
    if (_isLoading) return; // guard against double-calling
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final userId = _authRepo.currentUserId;
      final now    = DateTime.now();

      final results = await Future.wait([
        _userRepo.fetchProfile(userId),
        _expenseRepo.fetchByMonth(now.year, now.month),
      ]);

      _user     = results[0] as UserModel;
      _expenses = List<ExpenseModel>.from(results[1] as List);
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by AuthGate on sign-out — wipes all in-memory data.
  void clearSession() {
    _user       = null;
    _expenses   = [];
    _importSessions = [];
    _lastError  = null;
    notifyListeners();
  }

  // ── Expenses ──────────────────────────────────────────────────────────────

  List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  /// All expenses for a given day, sorted newest-first.
  List<ExpenseModel> expensesForDate(DateTime date) {
    return _expenses
        .where((e) =>
            e.date.year  == date.year  &&
            e.date.month == date.month &&
            e.date.day   == date.day)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Optimistic add — UI updates instantly, then persists to Supabase.
  Future<void> addExpense({
    required double          amount,
    required String          description,
    required DateTime        date,
    required ExpenseCategory category,
    String source = 'manual',
  }) async {
    final tempId  = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempExp = ExpenseModel(
      id:          tempId,
      userId:      _user?.id ?? '',
      amount:      amount,
      description: description,
      date:        date,
      category:    category,
      source:      source,
    );

    _expenses.add(tempExp);
    notifyListeners();

    try {
      final saved = await _expenseRepo.create(
        amount:      amount,
        description: description,
        date:        date,
        category:    category,
        source:      source,
      );
      final idx = _expenses.indexWhere((e) => e.id == tempId);
      if (idx != -1) {
        _expenses[idx] = saved;
        notifyListeners();
      }
    } catch (e) {
      _expenses.removeWhere((ex) => ex.id == tempId);
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Optimistic delete — UI updates instantly, then persists to Supabase.
  Future<void> deleteExpense(String id) async {
    final old = _expenses.firstWhere((e) => e.id == id,
        orElse: () => throw StateError('Expense $id not found'));
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await _expenseRepo.delete(id);
    } catch (e) {
      _expenses.add(old); // rollback
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Fetches and merges expenses for a specific month into the local cache.
  Future<void> loadMonth(DateTime month) async {
    try {
      final fetched = await _expenseRepo.fetchByMonth(month.year, month.month);
      _expenses.removeWhere(
        (e) => e.date.year == month.year && e.date.month == month.month,
      );
      _expenses.addAll(fetched);
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    }
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Spend-level map for a given month (date-only keys).
  Map<DateTime, DaySpendLevel> spendLevelsForMonth(DateTime month) {
    final Map<DateTime, double> dailyTotals = {};
    for (final e in _expenses) {
      if (e.date.year == month.year && e.date.month == month.month) {
        final key = DateTime(e.date.year, e.date.month, e.date.day);
        dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
      }
    }
    if (dailyTotals.isEmpty) return {};

    final avg = dailyTotals.values.fold(0.0, (a, b) => a + b) /
        dailyTotals.length;

    return dailyTotals.map((date, total) {
      final DaySpendLevel level;
      if (total == 0) {
        level = DaySpendLevel.none;
      } else if (total > avg * 1.3) {
        level = DaySpendLevel.high;
      } else {
        level = DaySpendLevel.low;
      }
      return MapEntry(date, level);
    });
  }

  /// Totals for the last 7 days (index 0 = 6 days ago, index 6 = today).
  List<double> get weeklyTotals {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return expensesForDate(day).fold(0.0, (sum, e) => sum + e.amount);
    });
  }

  /// Total spent in a given month.
  double monthTotal(DateTime month) {
    return _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Per-category totals for the current month.
  Map<ExpenseCategory, double> get currentMonthByCategory {
    final now = DateTime.now();
    final Map<ExpenseCategory, double> result = {};
    for (final e in _expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        result[e.category] = (result[e.category] ?? 0) + e.amount;
      }
    }
    return result;
  }

  /// Category with the highest spend this month.
  ExpenseCategory? get topCategory {
    final map = currentMonthByCategory;
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Percentage of monthly budget used.
  double get budgetUsedFraction {
    final budget = _user?.monthlyBudget ?? 0;
    if (budget == 0) return 0;
    return (monthTotal(DateTime.now()) / budget).clamp(0.0, 1.0);
  }

  // ── User / Budget ─────────────────────────────────────────────────────────

  void updateNotifications(bool enabled) {
    if (_user == null) return;
    _user = _user!.copyWith(notificationsEnabled: enabled);
    notifyListeners();
    _userRepo.updatePreferences(_user!.id, notifEnabled: enabled);
  }

  Future<void> updateBudget(double newBudget) async {
    if (_user == null) return;
    _user = _user!.copyWith(monthlyBudget: newBudget);
    notifyListeners();
    await _userRepo.updateBudget(_user!.id, newBudget);
  }

  // ── Import Sessions ───────────────────────────────────────────────────────

  List<ImportSessionModel> _importSessions = [];

  List<ImportSessionModel> get importSessions =>
      List.unmodifiable(_importSessions);

  /// Simulate a file import (placeholder until ImportRepository is built).
  void simulateImport(String fileName) {
    final now = DateTime.now();
    if (_user == null) return;
    final newExpenses = [
      ExpenseModel(
        id: '${now.millisecondsSinceEpoch}-1',
        userId: _user!.id,
        amount: 899,
        description: 'Imported: Online Order',
        date: now.subtract(const Duration(days: 2)),
        category: ExpenseCategory.shopping,
        source: 'import',
      ),
      ExpenseModel(
        id: '${now.millisecondsSinceEpoch}-2',
        userId: _user!.id,
        amount: 250,
        description: 'Imported: Auto Rickshaw',
        date: now.subtract(const Duration(days: 3)),
        category: ExpenseCategory.travel,
        source: 'import',
      ),
      ExpenseModel(
        id: '${now.millisecondsSinceEpoch}-3',
        userId: _user!.id,
        amount: 120,
        description: 'Imported: Chai & Snacks',
        date: now.subtract(const Duration(days: 4)),
        category: ExpenseCategory.food,
        source: 'import',
      ),
    ];
    _expenses.addAll(newExpenses);
    _importSessions.insert(
      0,
      ImportSessionModel(
        id: 'imp_${now.millisecondsSinceEpoch}',
        fileName: fileName,
        importedAt: now,
        transactionCount: newExpenses.length,
        status: ImportStatus.verified,
      ),
    );
    notifyListeners();
  }
}
