import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/utils/formatters.dart';

// ─── AI Scanning Card ─────────────────────────────────────────────────────────

class AiScanningCard extends StatelessWidget {
  final bool isScanning;

  const AiScanningCard({super.key, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.filled(
        color: AppColors.primary,
        radius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.textOnDark, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isScanning ? 'AI Scanning...' : 'AI Ready',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bachat Karo AI is ready to detect currency, dates, and merchant categories automatically.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: isScanning ? null : 1.0,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4ECDC4),
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'SYSTEM READY',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textOnDark.withOpacity(0.6),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Import Session Tile ──────────────────────────────────────────────────────

class ImportSessionTile extends StatelessWidget {
  final ImportSessionModel session;
  final VoidCallback? onMenuTap;

  const ImportSessionTile({
    super.key,
    required this.session,
    this.onMenuTap,
  });

  IconData get _fileIcon {
    final ext = session.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'xls':
      case 'xlsx':
      case 'csv': return Icons.grid_on_outlined;
      default: return Icons.text_snippet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: AppDecorations.filled(
              color: AppColors.surfaceVariant,
              radius: AppRadius.sm,
            ),
            child: Icon(_fileIcon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.fileName,
                  style: AppTextStyles.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Imported ${AppFormatters.dayMonth(session.importedAt)}, ${session.importedAt.year} • ${session.transactionCount} transactions',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: session.statusLabel,
            textColor: session.statusColor,
            backgroundColor: session.statusBackground,
          ),
          if (session.status == ImportStatus.needsReview) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onMenuTap,
              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
