import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../features/auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp   = false;
  bool _isLoading  = false;
  bool _obscure    = true;
  String? _errorMsg;

  late final AuthRepository _repo = AuthRepository(
    Supabase.instance.client,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMsg = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    try {
      if (_isSignUp) {
        await _repo.signUpWithEmail(email, password);
      } else {
        await _repo.signInWithEmail(email, password);
      }
      // AuthGate's StreamBuilder will automatically navigate to AppShell
    } on AuthException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (e) {
      setState(() => _errorMsg = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs     = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical:   AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // ── Logo / Brand ──
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        color: cs.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Bachat Karo', style: AppTextStyles.headingLarge.copyWith(color: cs.primary)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Heading ──
              Text(
                _isSignUp ? 'Create account' : 'Welcome back',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isSignUp
                    ? 'Start tracking your expenses today'
                    : 'Sign in to continue to your dashboard',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Error Banner ──
              if (_errorMsg != null) ...[
                InsightBanner(
                  message:         _errorMsg!,
                  icon:            Icons.error_outline,
                  backgroundColor: AppColors.error.withAlpha(isDark ? 40 : 20),
                  textColor:       AppColors.error,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Email Field ──
              Text('EMAIL', style: AppTextStyles.labelUppercase),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller:        _emailController,
                keyboardType:      TextInputType.emailAddress,
                textInputAction:   TextInputAction.next,
                autocorrect:       false,
                style:             AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText:    'you@example.com',
                  prefixIcon:  Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                  hintStyle:   AppTextStyles.bodyLarge.copyWith(color: AppColors.textDisabled),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Password Field ──
              Text('PASSWORD', style: AppTextStyles.labelUppercase),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller:      _passwordController,
                obscureText:     _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted:     (_) => _submit(),
                style:           AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText:   '••••••••',
                  hintStyle:  AppTextStyles.bodyLarge.copyWith(color: AppColors.textDisabled),
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Submit Button ──
              PrimaryButton(
                label:     _isSignUp ? 'Create Account' : 'Sign In',
                onPressed: _isLoading ? null : _submit,
                trailing:  _isLoading
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? AppColors.darkPrimary : AppColors.textOnDark,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward,
                        color: isDark ? AppColors.darkPrimary : AppColors.textOnDark,
                        size: 18,
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Toggle Sign In / Sign Up ──
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp  = !_isSignUp;
                    _errorMsg  = null;
                  }),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: _isSignUp ? 'Sign In' : 'Create one',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
