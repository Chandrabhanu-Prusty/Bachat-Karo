import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final VoidCallback? onEditTap;
  final double size;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.onEditTap,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceVariant,
            border: Border.all(
              color: AppColors.surface,
              width: 3,
            ),
            boxShadow: AppShadows.card,
          ),
          child: imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
        if (onEditTap != null)
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 12,
                color: AppColors.textOnDark,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: AppTextStyles.headingMedium.copyWith(
          color: AppColors.primary,
          fontSize: size * 0.28,
        ),
      ),
    );
  }
}
