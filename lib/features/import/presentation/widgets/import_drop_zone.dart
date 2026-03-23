import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ImportDropZone extends StatelessWidget {
  final VoidCallback onFilePicked;

  const ImportDropZone({super.key, required this.onFilePicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilePicked,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            // Dashed border simulation via BoxDecoration isn't native in Flutter;
            // use a CustomPainter for real dashes, or use package:dotted_border
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            _buildUploadIcon(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Drop a file here or\nBrowse',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Maximum file size ${AppConstants.maxFileSizeMb}MB',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFormatBadges(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFB2EAE8),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.upload_file_outlined,
        size: 28,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildFormatBadges() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: AppConstants.importFormats
          .map((fmt) => _FormatBadge(label: fmt))
          .toList(),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String label;
  const _FormatBadge({required this.label});

  IconData get _icon {
    switch (label) {
      case 'PDF': return Icons.picture_as_pdf_outlined;
      case 'XLS': return Icons.grid_on_outlined;
      case 'TXT': return Icons.text_snippet_outlined;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
