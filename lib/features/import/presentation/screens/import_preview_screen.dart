import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/models.dart';

/// Shown after the Groq LLM has extracted rows from a file or pasted text.
/// The user can review each row, deselect wrong ones, then confirm.
class ImportPreviewScreen extends StatefulWidget {
  final List<ParsedExpenseRow> rows;

  const ImportPreviewScreen({super.key, required this.rows});

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  late List<ParsedExpenseRow> _rows;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    // Make a mutable copy
    _rows = widget.rows.toList();
  }

  int get _selectedCount => _rows.where((r) => r.isSelected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Review ${_rows.length} Expenses',
          style: AppTextStyles.headingMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => _toggleAll(true),
            child: Text(
              'All',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _toggleAll(false),
            child: Text(
              'None',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Info Banner ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.primarySurface,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI extracted ${_rows.length} expenses. Deselect any incorrect rows before importing.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Row List ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              itemCount: _rows.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _buildRow(_rows[i], i),
            ),
          ),
        ],
      ),

      // ── Confirm Button ────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total amount selected
              if (_selectedCount > 0)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedCount expense${_selectedCount == 1 ? '' : 's'} selected',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.currency(
                          _rows
                              .where((r) => r.isSelected)
                              .fold(0.0, (s, r) => s + r.amount),
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedCount == 0 || _isConfirming
                      ? null
                      : _confirm,
                  child: _isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Import $_selectedCount Expense${_selectedCount == 1 ? '' : 's'}',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(ParsedExpenseRow row, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: row.isSelected
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        value: row.isSelected,
        activeColor: AppColors.primary,
        onChanged: (v) => setState(() => row.isSelected = v ?? false),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          row.description,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Icon(row.category.icon, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${row.category.label}  •  ${row.date}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        secondary: Text(
          AppFormatters.currency(row.amount),
          style: AppTextStyles.amountMedium,
        ),
      ),
    );
  }

  void _toggleAll(bool value) {
    setState(() {
      for (final row in _rows) {
        row.isSelected = value;
      }
    });
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    try {
      await context.read<AppState>().confirmImport(_rows);
      if (mounted) {
        // Pop back to the import screen
        Navigator.popUntil(context, (r) => r.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$_selectedCount expense${_selectedCount == 1 ? '' : 's'} imported successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
