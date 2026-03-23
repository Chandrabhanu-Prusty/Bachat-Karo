import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class WeeklyBarChart extends StatelessWidget {
  /// 7 values — Mon through Sun
  final List<double> dailyAmounts;
  final int highlightIndex; // defaults to Wednesday (index 2)

  const WeeklyBarChart({
    super.key,
    required this.dailyAmounts,
    this.highlightIndex = 2,
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    assert(dailyAmounts.length == 7, 'dailyAmounts must have exactly 7 values');

    final maxAmount = dailyAmounts.reduce((a, b) => a > b ? a : b);
    final percentChange = 4; // Mock: replace with computed value

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(percentChange),
          const SizedBox(height: AppSpacing.xl),
          _buildBars(maxAmount),
          const SizedBox(height: AppSpacing.sm),
          _buildDayLabels(),
        ],
      ),
    );
  }

  Widget _buildChartHeader(int percentChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Weekly Momentum', style: AppTextStyles.headingSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F4F0),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                size: 12,
                color: AppColors.success,
              ),
              const SizedBox(width: 2),
              Text(
                '$percentChange% vs LW',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBars(double maxAmount) {
    const chartHeight = 80.0;
    const barWidth = 28.0;

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final ratio = maxAmount > 0 ? dailyAmounts[i] / maxAmount : 0.0;
          final barHeight = (ratio * chartHeight).clamp(8.0, chartHeight);
          final isHighlight = i == highlightIndex;

          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + i * 40),
            curve: Curves.easeOutCubic,
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: isHighlight ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        return SizedBox(
          width: 28,
          child: Center(
            child: Text(
              _dayLabels[i],
              style: AppTextStyles.label.copyWith(
                color: i == highlightIndex
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: i == highlightIndex
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }),
    );
  }
}
