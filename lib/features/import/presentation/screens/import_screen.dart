import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../screens/import_preview_screen.dart';
import '../widgets/ai_scanning_card.dart';
import '../widgets/import_session_tile.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isScanning = false;
  String _scanningMessage = 'Reading file...';

  // Text paste controller
  final TextEditingController _pasteController = TextEditingController();
  bool _showPasteBox = false;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BachatAppBar(
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
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

            // ── File Upload Area ─────────────────────────────────────────
            _buildUploadCard(),
            const SizedBox(height: AppSpacing.lg),

            // ── OR Paste Text ────────────────────────────────────────────
            _buildPasteToggle(),
            if (_showPasteBox) ...[
              const SizedBox(height: AppSpacing.md),
              _buildPasteBox(),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ── AI Scanning Status Card ──────────────────────────────────
            AiScanningCard(
              isScanning: _isScanning,
              message: _scanningMessage,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Recent Imports ────────────────────────────────────────────
            if (state.importSessions.isNotEmpty) ...[
              _buildRecentImports(state),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── Pro Tip ───────────────────────────────────────────────────
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
          'Upload your notes, text files, or Excel sheets. '
          'Our AI (Groq) will automatically extract and categorise your expenses.',
          style: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── File Upload Card ────────────────────────────────────────────────────────

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _isScanning ? null : _handleFilePick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isScanning ? AppColors.primary : AppColors.border,
            width: _isScanning ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.upload_file_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isScanning ? 'Processing...' : 'Tap to Upload File',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Supports: .txt  .csv  .xlsx  .xls  .docx',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Max 25 MB',
              style: AppTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }

  // ── Paste Toggle ────────────────────────────────────────────────────────────

  Widget _buildPasteToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showPasteBox = !_showPasteBox),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _showPasteBox ? 'Hide paste box' : 'Or paste expenses as text',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 60,
            height: 1,
            color: AppColors.border,
          ),
        ],
      ),
    );
  }

  // ── Paste Box ───────────────────────────────────────────────────────────────

  Widget _buildPasteBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pasteController,
          maxLines: 7,
          enabled: !_isScanning,
          decoration: InputDecoration(
            hintText:
                'Paste your expense notes here...\n\n'
                'e.g.\n'
                'Jan 5 - Zomato biryani 320\n'
                'Jan 6 - Metro card 200\n'
                'Jan 7 - Amazon order 1299',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isScanning ? null : _handlePaste,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Extract Expenses with AI'),
            style: ElevatedButton.styleFrom(
              textStyle: AppTextStyles.button,
            ),
          ),
        ),
      ],
    );
  }

  // ── Recent Imports ──────────────────────────────────────────────────────────

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
        ...state.importSessions.map(
          (session) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ImportSessionTile(session: session),
          ),
        ),
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
                    text: 'AI Powered\n',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Groq AI reads messy notes and auto-categorises each expense. '
                        'It handles date formats, currency symbols, typos and abbreviations.',
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _handleFilePick() async {
    setState(() {
      _isScanning = true;
      _scanningMessage = 'Uploading file...';
    });

    try {
      final rows = await context.read<AppState>().importRepo.importFromFile();

      if (!mounted) return;

      if (rows.isEmpty) {
        _showError('No expenses found in the file. Try a different file or paste text instead.');
        return;
      }

      setState(() => _scanningMessage = 'Extraction complete!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      _openPreview(rows);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _handlePaste() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      _showError('Please paste some expense notes first.');
      return;
    }

    setState(() {
      _isScanning = true;
      _scanningMessage = 'Analysing your notes with AI...';
    });

    try {
      final rows =
          await context.read<AppState>().importRepo.importFromText(text);

      if (!mounted) return;

      if (rows.isEmpty) {
        _showError(
            'No expenses could be extracted. Please check your text format.');
        return;
      }

      setState(() => _scanningMessage = 'Extraction complete!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      _openPreview(rows);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _openPreview(List<ParsedExpenseRow> rows) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImportPreviewScreen(rows: rows),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
