import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/auth_providers.dart';

/// Opens the Progressive Onboarding / Lazy Login sheet for Family Sharing.
Future<void> showFamilySharingAuthSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FamilySharingAuthSheet(),
    );

class FamilySharingAuthSheet extends ConsumerStatefulWidget {
  const FamilySharingAuthSheet({super.key});

  @override
  ConsumerState<FamilySharingAuthSheet> createState() =>
      _FamilySharingAuthSheetState();
}

class _FamilySharingAuthSheetState
    extends ConsumerState<FamilySharingAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegister) {
        await repo.registerWithEmail(email: email, password: password);
      } else {
        await repo.signInWithEmail(email: email, password: password);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegister ? 'Account created successfully!' : 'Signed in successfully!',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'user-not-found' => 'No account found with this email.',
          'wrong-password' => 'Incorrect password.',
          'email-already-in-use' => 'An account already exists with this email.',
          'weak-password' => 'Password should be at least 6 characters.',
          'invalid-email' => 'Please enter a valid email address.',
          _ => e.message ?? 'Authentication error occurred.',
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final credential = await repo.signInWithGoogle();
      if (credential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final credential = await repo.signInWithApple();
      if (credential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Apple!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple Sign-In failed: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAppleSupported = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAMILY SHARING',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.accent,
                            fontSize: AppSpacing.fontXs,
                          ),
                        ),
                        Text(
                          'Caregiver & Family Mode',
                          style: AppTextStyles.headlineOnLight.copyWith(
                            fontSize: AppSpacing.fontLg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.inkMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.gapMd,

              if (user != null) ...[
                // User signed in view
                _buildSignedInContent(user),
              ] else ...[
                // Guest / Progressive onboarding view
                _buildGuestContent(isAppleSupported),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignedInContent(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.tileMint,
                child: Text(
                  (user.displayName?.isNotEmpty == true
                          ? user.displayName![0]
                          : user.email?.isNotEmpty == true
                              ? user.email![0]
                              : 'U')
                      .toUpperCase(),
                  style: AppTextStyles.headline.copyWith(color: Colors.white),
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Family Account',
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email ?? user.uid,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusChip(
                label: 'Cloud Active',
                icon: Icons.check_circle_rounded,
                background: AppColors.tileMint,
                foreground: Colors.white,
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,
        Text(
          'Your account is connected. You can link caregivers or family members to view your medication adherence and get notified in real time.',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        AppSpacing.gapXl,
        PillButton(
          label: 'Sign Out of Family Sharing',
          tone: PillButtonTone.moss,
          loading: _isLoading,
          onPressed: _handleSignOut,
        ),
      ],
    );
  }

  Widget _buildGuestContent(bool isAppleSupported) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Keep family members and caregivers in the loop. Link securely to monitor adherence and share dose reminders.',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapLg,

          // Social Login Buttons
          _SocialAuthButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Continue with Google',
            onPressed: _isLoading ? null : _handleGoogleAuth,
          ),
          if (isAppleSupported) ...[
            AppSpacing.gapSm,
            _SocialAuthButton(
              icon: Icons.apple_rounded,
              label: 'Continue with Apple',
              isDark: true,
              onPressed: _isLoading ? null : _handleAppleAuth,
            ),
          ],
          AppSpacing.gapMd,

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'or with email',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: AppSpacing.fontXs,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          AppSpacing.gapMd,

          // Switch between Login and Register
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeTab(
                    label: 'Sign In',
                    active: !_isRegister,
                    onTap: () => setState(() => _isRegister = false),
                  ),
                ),
                Expanded(
                  child: _ModeTab(
                    label: 'Create Account',
                    active: _isRegister,
                    onTap: () => setState(() => _isRegister = true),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,

          // Email & Password Fields
          AppTextField(
            label: 'Email',
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          AppTextField(
            label: 'Password',
            hint: _isRegister ? 'At least 6 characters' : 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.inkMuted,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (_isRegister && v.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 18),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          PillButton(
            label: _isRegister ? 'Create Account' : 'Sign In',
            loading: _isLoading,
            onPressed: _handleEmailAuth,
          ),
          AppSpacing.gapMd,

          // Offline-first reassurance note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.offline_bolt_outlined,
                color: AppColors.tileMint,
                size: 16,
              ),
              AppSpacing.gapXs,
              Expanded(
                child: Text(
                  'Dosey remains 100% offline-first. Your local medicines and reminders stay safe on your device.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: AppSpacing.fontXs,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDark = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.black : Colors.white,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: AppSpacing.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isDark ? Colors.transparent : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isDark ? Colors.white : AppColors.ink,
              ),
              AppSpacing.gapSm,
              Text(
                label,
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSpacing.animFast,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyOnLight.copyWith(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? AppColors.ink : AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
