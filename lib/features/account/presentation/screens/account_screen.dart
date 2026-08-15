import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/preference_row.dart';
import '../widgets/profile_avatar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    // Show loading spinner while user profile is loading
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Account', style: AppTextStyles.headingMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            _buildProfileHeader(
                user.displayName, user.email, user.isPremium, user.joinedAt),
            const SizedBox(height: AppSpacing.xxl),
            _buildFinancialSettings(context, state, user),
            const SizedBox(height: AppSpacing.lg),
            _buildAiInsightBanner(state),
            const SizedBox(height: AppSpacing.lg),
            _buildAppPreferences(context, state, user.notificationsEnabled,
                user.theme, user.reminderTime),
            const SizedBox(height: AppSpacing.lg),
            _buildSupportSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildLogoutButton(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildVersionFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
      String displayName, String email, bool isPremium, DateTime joinedAt) {
    return Column(
      children: [
        ProfileAvatar(
          imageUrl: null,
          initials: displayName.split(' ').map((w) => w[0]).take(2).join(),
          onEditTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        Text(displayName, style: AppTextStyles.headingLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPremium)
              StatusBadge(
                label: 'PREMIUM MEMBER',
                textColor: AppColors.primary,
                backgroundColor: AppColors.primarySurface,
              ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(
              label: 'JOINED ${joinedAt.year}',
              textColor: AppColors.textSecondary,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ],
        ),
      ],
    );
  }

  // ── Financial Settings Card ───────────────────────────────────────────────

  Widget _buildFinancialSettings(
      BuildContext context, AppState state, UserModel user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Financial Settings', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'MONTHLY BUDGET',
            style: AppTextStyles.labelUppercase,
          ),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () => _editBudget(context, state, user),
            child: Row(
              children: [
                Text(
                  AppFormatters.currency(user.monthlyBudget),
                  style: AppTextStyles.amountLarge,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          Text('PRIMARY ACCOUNT', style: AppTextStyles.labelUppercase),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.primaryAccount.isNotEmpty ? user.primaryAccount : '—',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 2),
          Text(
            user.primaryAccountLast4.isNotEmpty
                ? '**** ${user.primaryAccountLast4}'
                : 'No account linked yet',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  'Manage Accounts',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Insight Banner ─────────────────────────────────────────────────────

  Widget _buildAiInsightBanner(AppState state) {
    final fraction = state.budgetUsedFraction;
    final message = fraction < 0.5
        ? "You've used less than half your budget — great discipline this month!"
        : fraction < 0.85
            ? "You've used ${(fraction * 100).round()}% of your budget. Pace yourself for the rest of the month."
            : "⚠️ You're at ${(fraction * 100).round()}% of your budget. Limit non-essential expenses now.";

    return InsightBanner(
      message: message,
      backgroundColor: AppColors.accent,
    );
  }

  // ── App Preferences ───────────────────────────────────────────────────────

  Widget _buildAppPreferences(BuildContext context, AppState state,
      bool notificationsEnabled, String theme, String reminderTime) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('App Preferences', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── Daily reminder time ──────────────────────────────────────────
          PreferenceRow(
            icon: Icons.alarm_outlined,
            label: 'Daily Reminder',
            trailing: GestureDetector(
              onTap: () => _pickReminderTime(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  state.reminderTimeLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          PreferenceRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (val) => state.updateNotifications(val),
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Support & Legal ───────────────────────────────────────────────────────

  Widget _buildSupportSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Support & Legal', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PreferenceRow(
            label: 'Help Center',
            trailing: const Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onTap: () {},
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          PreferenceRow(
            label: 'Privacy Policy',
            trailing: const Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Logout',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildVersionFooter() {
    return Column(
      children: [
        Text(
          'BACHAT KARO',
          style: AppTextStyles.labelUppercase.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'VERSION 1.0.0 • AI EXPENSE TRACKER',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textDisabled,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickReminderTime(BuildContext context, AppState state) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: state.reminderTime,
      helpText: 'SET REMINDER TIME',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) state.updateReminderTime(picked);
  }

  Future<void> _editBudget(
      BuildContext context, AppState state, UserModel user) async {
    final controller = TextEditingController(
      text: user.monthlyBudget.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: '25000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            child: Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      state.updateBudget(result);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content:
            const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await Supabase.instance.client.auth.signOut();
      // AuthGate's StreamBuilder will navigate to LoginScreen automatically
    }
  }
}
