import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class NudgeCard extends StatelessWidget {
  final NudgeModel nudge;

  const NudgeCard({super.key, required this.nudge});

  Color get _leftBorderColor {
    switch (nudge.type) {
      case NudgeType.warning: return AppColors.accent;
      case NudgeType.optimization: return AppColors.primary;
      case NudgeType.positive: return AppColors.success;
    }
  }

  Color get _cardColor {
    switch (nudge.type) {
      case NudgeType.positive: return AppColors.primary;
      default: return AppColors.surface;
    }
  }

  bool get _isDark => nudge.type == NudgeType.positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: _isDark
            ? null
            : Border(
                left: BorderSide(color: _leftBorderColor, width: 3),
              ),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIconWidget(
            icon: nudge.category.icon,
            iconColor: _isDark
                ? AppColors.primary
                : nudge.category.iconColor,
            backgroundColor: _isDark
                ? AppColors.textOnDark.withOpacity(0.15)
                : nudge.category.iconBackground,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nudge.title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: _isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildBodyWithHighlight(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWithHighlight() {
    // Bold the percentage/number portions of the nudge text
    // For a production app, pass structured data instead of parsing strings
    final baseStyle = AppTextStyles.bodySmall.copyWith(
      color: _isDark
          ? AppColors.textOnDark.withOpacity(0.85)
          : AppColors.textSecondary,
      height: 1.5,
    );

    return Text(nudge.body, style: baseStyle);
  }
}
