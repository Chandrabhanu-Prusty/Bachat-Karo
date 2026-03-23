import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── Expense ──────────────────────────────────────────────────────────────────

enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  entertainment,
  health,
  education,
  personalCare,
  rent,
  others;

  /// Database column value — maps enum name → stored string.
  /// personalCare → 'personalCare' (preserved exactly)
  String get dbValue => name;

  /// Reverse map from DB string → enum value.
  static ExpenseCategory fromDb(String v) =>
      ExpenseCategory.values.firstWhere(
        (e) => e.name == v,
        orElse: () => others,
      );

  String get label {
    switch (this) {
      case food: return 'Food & Drinks';
      case travel: return 'Travel';
      case shopping: return 'Shopping';
      case bills: return 'Bills';
      case entertainment: return 'Entertainment';
      case health: return 'Health';
      case education: return 'Education';
      case personalCare: return 'Personal Care';
      case rent: return 'Rent';
      case others: return 'Others';
    }
  }

  /// Short label for category chips
  String get shortLabel {
    switch (this) {
      case food: return 'Food';
      case travel: return 'Travel';
      case shopping: return 'Shopping';
      case bills: return 'Bills';
      case entertainment: return 'Entertainment';
      case health: return 'Health';
      case education: return 'Education';
      case personalCare: return 'Personal Care';
      case rent: return 'Rent';
      case others: return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case food: return Icons.restaurant_outlined;
      case travel: return Icons.directions_car_outlined;
      case shopping: return Icons.shopping_bag_outlined;
      case bills: return Icons.receipt_outlined;
      case entertainment: return Icons.movie_outlined;
      case health: return Icons.favorite_border;
      case education: return Icons.school_outlined;
      case personalCare: return Icons.face_outlined;
      case rent: return Icons.home_outlined;
      case others: return Icons.more_horiz;
    }
  }

  Color get iconBackground {
    switch (this) {
      case food: return AppColors.catFood;
      case travel: return AppColors.catTravel;
      case shopping: return AppColors.catShopping;
      case bills: return AppColors.catBills;
      default: return AppColors.catOthers;
    }
  }

  Color get iconColor {
    switch (this) {
      case travel: return AppColors.textOnDark;
      case shopping: return AppColors.textOnDark;
      default: return AppColors.primary;
    }
  }
}

class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory category;
  final String? source; // 'manual' | 'import'

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.source = 'manual',
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
        id:          j['id'] as String,
        userId:      j['user_id'] as String,
        amount:      (j['amount'] as num).toDouble(),
        description: j['description'] as String,
        date:        DateTime.parse(j['expense_date'] as String),
        category:    ExpenseCategory.fromDb(j['category'] as String),
        source:      j['source'] as String? ?? 'manual',
      );

  /// JSON for INSERT — user_id is added by the repository, NOT here.
  Map<String, dynamic> toInsertJson() => {
        'amount':       amount,
        'description':  description,
        'expense_date': '${date.year}-${_p(date.month)}-${_p(date.day)}',
        'category':     category.dbValue,
        'source':       source ?? 'manual',
      };

  ExpenseModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    DateTime? date,
    ExpenseCategory? category,
    String? source,
  }) =>
      ExpenseModel(
        id:          id          ?? this.id,
        userId:      userId      ?? this.userId,
        amount:      amount      ?? this.amount,
        description: description ?? this.description,
        date:        date        ?? this.date,
        category:    category    ?? this.category,
        source:      source      ?? this.source,
      );
}

/// Zero-padded two-digit helper used in date formatting.
String _p(int n) => n.toString().padLeft(2, '0');

// ─── Daily Summary ────────────────────────────────────────────────────────────

enum DaySpendLevel { none, low, high }

class DailySummaryModel {
  final DateTime date;
  final double totalSpent;
  final List<ExpenseModel> expenses;
  final DaySpendLevel spendLevel;

  const DailySummaryModel({
    required this.date,
    required this.totalSpent,
    required this.expenses,
    required this.spendLevel,
  });
}

// ─── Import Session ───────────────────────────────────────────────────────────

enum ImportStatus { verified, needsReview, pending }

class ImportSessionModel {
  final String id;
  final String fileName;
  final DateTime importedAt;
  final int transactionCount;
  final ImportStatus status;

  const ImportSessionModel({
    required this.id,
    required this.fileName,
    required this.importedAt,
    required this.transactionCount,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case ImportStatus.verified: return 'VERIFIED';
      case ImportStatus.needsReview: return 'NEEDS REVIEW';
      case ImportStatus.pending: return 'PENDING';
    }
  }

  Color get statusColor {
    switch (status) {
      case ImportStatus.verified: return AppColors.success;
      case ImportStatus.needsReview: return AppColors.accent;
      case ImportStatus.pending: return AppColors.warning;
    }
  }

  Color get statusBackground {
    switch (status) {
      case ImportStatus.verified: return AppColors.primarySurface;
      case ImportStatus.needsReview: return AppColors.accentLight;
      case ImportStatus.pending: return const Color(0xFFFFF3CD);
    }
  }
}

// ─── Insight Nudge ────────────────────────────────────────────────────────────

enum NudgeType { warning, optimization, positive }

class NudgeModel {
  final String id;
  final String title;
  final String body;
  final ExpenseCategory category;
  final NudgeType type;

  const NudgeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
  });
}

// ─── User / Account ───────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final bool isPremium;
  final DateTime joinedAt;
  final double monthlyBudget;
  final String primaryAccount;
  final String primaryAccountLast4;
  final String theme;
  final String reminderTime;
  final bool notificationsEnabled;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.isPremium = false,
    required this.joinedAt,
    required this.monthlyBudget,
    required this.primaryAccount,
    required this.primaryAccountLast4,
    this.theme = 'Light',
    this.reminderTime = '9 PM',
    this.notificationsEnabled = true,
  });

  /// Builds a [UserModel] from a Supabase `users` row + the auth email.
  factory UserModel.fromJson(Map<String, dynamic> row, String email) =>
      UserModel(
        id:                  row['id'] as String,
        displayName:         (row['display_name'] as String?) ??
                             email.split('@').first,
        email:               email,
        isPremium:           false,
        joinedAt:            DateTime.parse(row['created_at'] as String),
        monthlyBudget:       (row['monthly_budget'] as num?)?.toDouble() ?? 0.0,
        primaryAccount:      '',
        primaryAccountLast4: '',
        theme:               (row['theme'] as String?) ?? 'Light',
        reminderTime:        (row['notif_time'] as String?) ?? '21:00',
        notificationsEnabled: (row['notif_enabled'] as bool?) ?? true,
      );

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    bool? isPremium,
    DateTime? joinedAt,
    double? monthlyBudget,
    String? primaryAccount,
    String? primaryAccountLast4,
    String? theme,
    String? reminderTime,
    bool? notificationsEnabled,
  }) =>
      UserModel(
        id:                  id                  ?? this.id,
        displayName:         displayName         ?? this.displayName,
        email:               email               ?? this.email,
        isPremium:           isPremium           ?? this.isPremium,
        joinedAt:            joinedAt            ?? this.joinedAt,
        monthlyBudget:       monthlyBudget       ?? this.monthlyBudget,
        primaryAccount:      primaryAccount      ?? this.primaryAccount,
        primaryAccountLast4: primaryAccountLast4 ?? this.primaryAccountLast4,
        theme:               theme               ?? this.theme,
        reminderTime:        reminderTime        ?? this.reminderTime,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}

