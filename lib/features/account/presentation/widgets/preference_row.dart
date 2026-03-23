import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class PreferenceRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const PreferenceRow({
    super.key,
    this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          trailing,
        ],
      ),
    );
  }
}
