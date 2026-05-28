import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? onboardingExtra;

  const SignUpScreen({super.key, this.onboardingExtra});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Onboarding data stored in provider (primary) or passed via widget (fallback).
  Map<String, dynamic>? get _extra =>
      ref.read(pendingOnboardingDataProvider) ?? widget.onboardingExtra;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final onboardingData = _extra;
      await ref.read(authServiceProvider).signUp(
        email: email,
        password: password,
        name: onboardingData?['name'] as String? ?? '',
        goal: onboardingData?['goal'] as String?,
        habits: (onboardingData?['habits'] as List<dynamic>? ?? []).cast<String>(),
        frequency: onboardingData?['frequency'] as String?,
        timeOfDay: onboardingData?['timeOfDay'] as String?,
      );
      // Clear the temporary onboarding data now that it's been saved
      ref.read(pendingOnboardingDataProvider.notifier).state = null;
      // Mark onboarding as complete locally so the router knows on next cold start
      await OnboardingRepository().setComplete();
      // Update the in-memory provider so the router re-evaluates immediately
      ref.read(onboardingCompleteProvider.notifier).state = true;
      // Force a fresh fetch so the profile screen shows the real name.
      ref.invalidate(profileProvider);
      // Router will auto-redirect to /home via the Supabase auth stream
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          const AnimatedWaveBackground(step: 6),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/onboarding'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OnboardingStepHeader(
                          icon: LucideIcons.lockKeyhole,
                          title: 'Create your\naccount',
                          subtitle: 'Your journey is saved to the cloud.',
                        ),
                        const SizedBox(height: 36),

                        // Email field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: _fieldDecoration('Email address', null),
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: _fieldDecoration(
                            'Password (min. 6 characters)',
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),
                        OnboardingCTAButton(
                          label: 'Create Account',
                          onTap: _isLoading ? null : _submit,
                          color: AppColors.primary,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, Widget? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.25),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }
}
