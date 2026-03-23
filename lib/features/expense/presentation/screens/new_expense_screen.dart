import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/category_chip.dart';
import '../widgets/budget_insight_card.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _selectedAccount = 'HDFC Savings';

  String? _amountError;
  String? _categoryError;
  bool    _isSaving = false;

  double get _parsedAmount =>
      double.tryParse(_amountController.text) ?? 0;

  final List<ExpenseCategory> _primaryCategories = [
    ExpenseCategory.food,
    ExpenseCategory.travel,
    ExpenseCategory.shopping,
    ExpenseCategory.bills,
  ];

  static const List<String> _accounts = [
    'HDFC Savings',
    'SBI Current',
    'ICICI Credit',
    'Axis Bank',
    'Cash',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountInput(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDescriptionField(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDateAccountRow(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCategorySection(),
                  if (_categoryError != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _categoryError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  BudgetInsightCard(
                    message: _parsedAmount > 0
                        ? 'Adding ₹${_parsedAmount.toStringAsFixed(0)} to ${_selectedCategory?.label ?? "your expenses"} today.'
                        : 'Enter an amount to see budget impact.',
                  ),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('New Expense', style: AppTextStyles.headingMedium),
    );
  }

  // ── Amount Input ──────────────────────────────────────────────────────────

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text(
          'AMOUNT',
          style: AppTextStyles.labelUppercase,
        ),
        if (_amountError != null) ...[
          const SizedBox(height: 4),
          Text(_amountError!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
                fontSize: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                style: AppTextStyles.amountHero,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTextStyles.amountHero.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() => _amountError = null),
              ),
            ),
          ],
        ),
        Container(
          width: 2,
          height: 28,
          color: AppColors.primary,
        ),
      ],
    );
  }

  // ── Description Field ─────────────────────────────────────────────────────

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT WAS THIS FOR?',
          style: AppTextStyles.labelUppercase,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: TextField(
            controller: _descriptionController,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'e.g. Artisanal Coffee at Third Wave',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDisabled,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Date & Account Row ────────────────────────────────────────────────────

  Widget _buildDateAccountRow() {
    return Row(
      children: [
        Expanded(
          child: _FieldGroup(
            label: 'DATE',
            child: _buildPickerTile(
              icon: Icons.calendar_today_outlined,
              value: _selectedDate.day == DateTime.now().day &&
                      _selectedDate.month == DateTime.now().month
                  ? 'Today'
                  : AppFormatters.dayMonth(_selectedDate),
              onTap: _pickDate,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _FieldGroup(
            label: 'ACCOUNT',
            child: _buildPickerTile(
              icon: Icons.wallet_outlined,
              value: _selectedAccount,
              onTap: _pickAccount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: AppDecorations.filled(
          color: AppColors.surfaceVariant,
          radius: AppRadius.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(value, style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Section ──────────────────────────────────────────────────────

  Widget _buildCategorySection() {
    return _FieldGroup(
      label: 'CATEGORY',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          ..._primaryCategories.map((cat) => CategoryChip(
                category: cat,
                isSelected: _selectedCategory == cat,
                onTap: () => setState(() {
                  _selectedCategory = cat;
                  _categoryError = null;
                }),
              )),
          _MoreChip(onTap: _showMoreCategories),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Save Expense',
        trailing: _isSaving
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnDark,
                ),
              )
            : const Icon(Icons.arrow_forward, color: AppColors.textOnDark, size: 18),
        onPressed: _isSaving ? null : _saveExpense,
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickAccount() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text('Select Account', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.md),
          ..._accounts.map((acc) => ListTile(
                leading: const Icon(Icons.account_balance_outlined,
                    color: AppColors.primary),
                title:
                    Text(acc, style: AppTextStyles.bodyLarge),
                trailing: _selectedAccount == acc
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, acc),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
    if (picked != null) setState(() => _selectedAccount = picked);
  }

  void _showMoreCategories() {
    final remaining = ExpenseCategory.values
        .where((c) => !_primaryCategories.contains(c))
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More Categories', style: AppTextStyles.headingMedium),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: remaining
                  .map((cat) => CategoryChip(
                        category: cat,
                        isSelected: _selectedCategory == cat,
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            _categoryError = null;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    // Validate
    bool valid = true;
    if (_parsedAmount <= 0) {
      setState(() => _amountError = 'Please enter a valid amount.');
      valid = false;
    }
    if (_selectedCategory == null) {
      setState(() => _categoryError = 'Please select a category.');
      valid = false;
    }
    if (!valid) return;

    setState(() => _isSaving = true);

    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    final description = _descriptionController.text.trim().isEmpty
        ? _selectedCategory!.label
        : _descriptionController.text.trim();

    await context.read<AppState>().addExpense(
      amount:      _parsedAmount,
      description: description,
      date:        date,
      category:    _selectedCategory!,
    );

    if (mounted) Navigator.pop(context);
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _FieldGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelUppercase),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _MoreChip extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('More',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
