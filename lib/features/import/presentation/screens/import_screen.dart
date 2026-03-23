import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/import_drop_zone.dart';
import '../widgets/ai_scanning_card.dart';
import '../widgets/import_session_tile.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xxl),
            ImportDropZone(onFilePicked: _handleFilePick),
            const SizedBox(height: AppSpacing.lg),
            AiScanningCard(isScanning: _isScanning),
            const SizedBox(height: AppSpacing.xxl),
            _buildRecentImports(state),
            const SizedBox(height: AppSpacing.xl),
            _buildProTip(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import Hub', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Upload your notes, text files, or bank statements to sync your history. '
          'Our AI will automatically categorize your past expenses into your new ledger.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRecentImports(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Last Imports',
          actionLabel: 'View All',
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        ...(state.importSessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ImportSessionTile(session: session),
            ))),
      ],
    );
  }

  Widget _buildProTip() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.filled(
        color: AppColors.accentLight,
        radius: AppRadius.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Pro Tip\n',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  TextSpan(
                    text:
                        'You can drag and drop multiple files at once. Bachat Karo handles parallel processing to save you time.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFilePick() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AppState>().simulateImport('Statement_${DateTime.now().millisecondsSinceEpoch}.pdf');
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Import complete — 3 transactions added!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}
