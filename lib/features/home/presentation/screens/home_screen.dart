import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/expense_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final expenses = state.expensesForDate(_selectedDate);
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final spendLevels = state.spendLevelsForMonth(_displayedMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BachatAppBar(
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _buildMonthHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildCalendarCard(spendLevels),
            const SizedBox(height: AppSpacing.xxl),
            _buildDailySummaryHeader(totalSpent),
            const SizedBox(height: AppSpacing.lg),
            _buildExpenseList(expenses, state),
            const SizedBox(height: 100), // FAB clearance
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCIAL OVERVIEW',
            style: AppTextStyles.labelUppercase,
          ),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: _pickMonth,
            child: Row(
              children: [
                Text(
                  AppFormatters.monthYear(_displayedMonth),
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(Map<DateTime, DaySpendLevel> spendLevels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CalendarGrid(
              month: _displayedMonth,
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
              spendLevels: spendLevels,
            ),
            const SizedBox(height: AppSpacing.md),
            const InsightBanner(
              message:
                  'Tap any date to see your spending. Green dots = low spend, red dots = high spend.',
              backgroundColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryHeader(double totalSpent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Summary', style: AppTextStyles.headingLarge),
              const SizedBox(height: 2),
              Text(
                AppFormatters.fullDate(_selectedDate),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL SPENT',
                style: AppTextStyles.labelUppercase,
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatters.currency(totalSpent),
                style: AppTextStyles.amountLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseModel> expenses, AppState state) {
    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 48, color: AppColors.textDisabled),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No expenses on this day.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap + to add one.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return ExpenseListItem(
          expense: expenses[index],
          onDelete: () => state.deleteExpense(expenses[index].id),
        );
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    // Build list of last 12 months
    final months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - i),
    );

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: months.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(AppFormatters.monthYear(months[i]),
              style: AppTextStyles.bodyLarge),
          onTap: () => Navigator.pop(context, months[i]),
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _displayedMonth = picked;
        _selectedDate = DateTime(picked.year, picked.month, 1);
      });
      // Fetch real expenses for the selected month from Supabase
      if (mounted) {
        context.read<AppState>().loadMonth(picked);
      }
    }
  }
}
