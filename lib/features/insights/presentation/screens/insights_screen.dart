import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/nudge_card.dart';
import '../widgets/focus_donut_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final weeklyTotals = state.weeklyTotals;
    final byCategory = state.currentMonthByCategory;
    final topCat = state.topCategory;
    final nudges = _buildNudges(state);

    // Compute top category percentage
    final monthTotal = byCategory.values.fold(0.0, (a, b) => a + b);
    final topCatTotal = topCat != null ? (byCategory[topCat] ?? 0) : 0.0;
    final topCatPercent = monthTotal > 0
        ? ((topCatTotal / monthTotal) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.xl),
                WeeklyBarChart(dailyAmounts: weeklyTotals),
                const SizedBox(height: AppSpacing.lg),
                if (topCat != null)
                  FocusDonutCard(
                    focusCategory: topCat.label,
                    percentage: topCatPercent,
                    label:
                        '${topCat.label} accounts for $topCatPercent% of your spending this month.',
                  ),
                const SizedBox(height: AppSpacing.xxl),
                _buildBudgetProgress(state),
                const SizedBox(height: AppSpacing.xxl),
                _buildNudgesSection(nudges),
                const SizedBox(height: AppSpacing.xl),
                _buildSubscriptionAuditBanner(),
                const SizedBox(height: AppSpacing.xxl),
                _buildAiAdvisorQuote(state),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppSpacing.screenH,
          bottom: AppSpacing.md,
        ),
        title: Text('Financial Pulse', style: AppTextStyles.headingMedium),
        collapseMode: CollapseMode.pin,
        background: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenH,
              bottom: 52,
            ),
            child: Text('MONTHLY OVERVIEW', style: AppTextStyles.labelUppercase),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(AppState state) {
    final spent    = state.monthTotal(DateTime.now());
    final budget   = state.user?.monthlyBudget ?? 0.0;
    final fraction = state.budgetUsedFraction;
    final overBudget = budget > 0 && spent > budget;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget', style: AppTextStyles.headingSmall),
              Text(
                '${AppFormatters.currency(spent)} / ${AppFormatters.currency(budget)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: overBudget ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              color: overBudget ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            overBudget
                ? '⚠️ Over budget by ${AppFormatters.currency(spent - budget)}'
                : '${AppFormatters.currency(budget - spent)} remaining this month',
            style: AppTextStyles.bodySmall.copyWith(
              color: overBudget ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNudgesSection(List<NudgeModel> nudges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Intelligent Nudges',
          actionLabel: 'View History',
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        ...nudges.map((nudge) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: NudgeCard(nudge: nudge),
            )),
      ],
    );
  }

  Widget _buildSubscriptionAuditBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.textOnDark, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'SUBSCRIPTION AUDIT',
            style: AppTextStyles.labelUppercase.copyWith(
              color: AppColors.textOnDark,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward,
            color: AppColors.textOnDark,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildAiAdvisorQuote(AppState state) {
    final budgetFrac = state.budgetUsedFraction;
    final quote = budgetFrac < 0.5
        ? '"Great discipline! You\'re on track to save significantly this month. Keep going!"'
        : budgetFrac < 0.85
            ? '"You\'re using your budget well. A few mindful choices and you\'ll finish the month under budget."'
            : '"You\'re close to your budget limit. Consider pausing non-essential spending for the rest of the month."';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote,
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 30,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI FINANCIAL ADVISOR',
                style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dynamic Nudge Generation ───────────────────────────────────────────────

  List<NudgeModel> _buildNudges(AppState state) {
    final nudges = <NudgeModel>[];
    final byCategory = state.currentMonthByCategory;
    if (byCategory.isEmpty) {
      return [
        const NudgeModel(
          id: 'n0',
          title: 'Getting Started',
          body: 'Add your first expense to start seeing personalized insights.',
          category: ExpenseCategory.others,
          type: NudgeType.positive,
        )
      ];
    }

    // Top spending category warning
    final topCat = state.topCategory;
    if (topCat != null) {
      final total = byCategory[topCat] ?? 0;
      nudges.add(NudgeModel(
        id: 'n1',
        title: '${topCat.label} is your top expense',
        body:
            'You\'ve spent ₹${total.toStringAsFixed(0)} on ${topCat.label} this month. This is your highest category.',
        category: topCat,
        type: NudgeType.warning,
      ));
    }

    // Travel tip
    final travelTotal = byCategory[ExpenseCategory.travel] ?? 0;
    if (travelTotal > 500) {
      nudges.add(NudgeModel(
        id: 'n2',
        title: 'Commute Optimization',
        body:
            'You spent ₹${travelTotal.toStringAsFixed(0)} on travel. A weekly pass could save you ₹850/month.',
        category: ExpenseCategory.travel,
        type: NudgeType.optimization,
      ));
    }

    // Positive nudge if under budget
    if (state.budgetUsedFraction < 0.7) {
      nudges.add(const NudgeModel(
        id: 'n3',
        title: 'Savings Streak',
        body:
            'You\'re under 70% of your monthly budget. Great financial discipline!',
        category: ExpenseCategory.others,
        type: NudgeType.positive,
      ));
    }

    return nudges.isEmpty
        ? [
            const NudgeModel(
              id: 'n_default',
              title: 'On Track',
              body: 'Your spending looks healthy this month. Keep it up!',
              category: ExpenseCategory.others,
              type: NudgeType.positive,
            )
          ]
        : nudges;
  }
}
