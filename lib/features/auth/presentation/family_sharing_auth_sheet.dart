import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../family_sharing/domain/family_share.dart';
import '../../family_sharing/providers/family_share_providers.dart';
import '../data/auth_repository.dart';
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
  final _nameController = TextEditingController();
  final _shareCodeController = TextEditingController();

  bool _isRegister = false;
  bool _isResetMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Family sharing active tab when signed in: 0 = Share My Doses, 1 = Caregiver Mode
  int _activeFamilyTab = 0;
  FamilyShare? _activeShare;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _shareCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isResetMode) {
        await repo.sendPasswordResetEmail(email);
        setState(() {
          _successMessage = 'Password reset email sent to $email!';
          _isResetMode = false;
        });
        return;
      }

      if (_isRegister) {
        await repo.registerWithEmail(
          email: email,
          password: password,
          displayName: _nameController.text.trim(),
        );
      } else {
        await repo.signInWithEmail(email: email, password: password);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegister
                  ? 'Account created successfully!'
                  : 'Signed in successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e);
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
      _successMessage = null;
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
        _errorMessage = AuthRepository.formatAuthError(e);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
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
        _errorMessage = AuthRepository.formatAuthError(e);
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
          const SnackBar(content: Text('Signed out successfully.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your cloud account and unlink all family members. Your local medicine data on this device will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted.')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGenerateShareCode(User user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(familyShareRepositoryProvider);
      final share = await repo.createOrGetShareCode(
        patientUid: user.uid,
        patientName: user.displayName ?? user.email?.split('@').first,
      );
      setState(() {
        _activeShare = share;
      });
      ref.invalidate(patientSharesProvider);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRedeemShareCode(User user) async {
    final code = _shareCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a 6-character share code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.redeemShareCode(
        shareCode: code,
        caregiverUid: user.uid,
        caregiverName: user.displayName ?? user.email?.split('@').first,
      );
      _shareCodeController.clear();
      ref.invalidate(caregiverSharesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Linked as caregiver successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.tileMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: AppColors.tileMint.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.tileMint,
                        size: 18,
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.tileMoss,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
    final patientSharesAsync = ref.watch(patientSharesProvider);
    final caregiverSharesAsync = ref.watch(caregiverSharesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Info Card
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

        // Mode switch tabs: 0 = Share My Doses, 1 = Caregiver Mode
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
                  label: 'Share My Doses',
                  active: _activeFamilyTab == 0,
                  onTap: () => setState(() => _activeFamilyTab = 0),
                ),
              ),
              Expanded(
                child: _ModeTab(
                  label: 'Caregiver Mode',
                  active: _activeFamilyTab == 1,
                  onTap: () => setState(() => _activeFamilyTab = 1),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        if (_activeFamilyTab == 0) ...[
          // PATIENT MODE: Share my adherence
          _buildPatientShareCard(user, patientSharesAsync),
        ] else ...[
          // CAREGIVER MODE: Monitor family
          _buildCaregiverLinkCard(user, caregiverSharesAsync),
        ],

        AppSpacing.gapXl,
        PillButton(
          label: 'Sign Out of Family Sharing',
          tone: PillButtonTone.moss,
          loading: _isLoading,
          onPressed: _handleSignOut,
        ),
        AppSpacing.gapSm,
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _handleDeleteAccount,
            child: Text(
              'Delete Account / Disconnect Cloud',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientShareCard(
    User user,
    AsyncValue<List<FamilyShare>> patientSharesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.qr_code_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              AppSpacing.gapSm,
              Text(
                'Share Your Medication Schedule',
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Generate a secure 6-character code to share your adherence with a family member or caregiver.',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapMd,

          if (_activeShare != null) ...[
            _buildShareCodeDisplay(_activeShare!.shareCode),
          ] else ...[
            patientSharesAsync.when(
              data: (shares) {
                final unclaimed = shares.where((s) => !s.isClaimed).toList();
                if (unclaimed.isNotEmpty) {
                  return _buildShareCodeDisplay(unclaimed.first.shareCode);
                }
                return PillButton(
                  label: 'Generate Family Share Code',
                  tone: PillButtonTone.accent,
                  loading: _isLoading,
                  onPressed: () => _handleGenerateShareCode(user),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => PillButton(
                label: 'Generate Family Share Code',
                tone: PillButtonTone.accent,
                loading: _isLoading,
                onPressed: () => _handleGenerateShareCode(user),
              ),
            ),
          ],

          // Linked Caregivers list
          patientSharesAsync.when(
            data: (shares) {
              final claimed = shares.where((s) => s.isClaimed).toList();
              if (claimed.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapMd,
                  const Divider(),
                  AppSpacing.gapXs,
                  Text(
                    'Linked Caregivers (${claimed.length})',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  AppSpacing.gapXs,
                  ...claimed.map(
                    (share) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.tileMint,
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      title: Text(
                        share.caregiverName ?? 'Caregiver',
                        style: AppTextStyles.bodyOnLight,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.link_off_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () async {
                          await ref
                              .read(familyShareRepositoryProvider)
                              .revokeShare(share.id);
                          ref.invalidate(patientSharesProvider);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCodeDisplay(String code) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.tileMint.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            'YOUR SHARE CODE',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.inkMuted,
              letterSpacing: 1.5,
            ),
          ),
          AppSpacing.gapXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: AppTextStyles.headline.copyWith(
                  fontSize: 28,
                  letterSpacing: 6,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppSpacing.gapSm,
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Code "$code" copied to clipboard!'),
                    ),
                  );
                },
              ),
            ],
          ),
          Text(
            'Share this code with your caregiver. Valid for 7 days.',
            style: AppTextStyles.caption.copyWith(
              fontSize: AppSpacing.fontXs,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverLinkCard(
    User user,
    AsyncValue<List<FamilyShare>> caregiverSharesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.tileMint,
                size: 20,
              ),
              AppSpacing.gapSm,
              Text(
                'Monitor a Family Member',
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Enter the 6-character code given to you by your patient or family member.',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapMd,
          AppTextField(
            label: 'Family Share Code',
            hint: 'e.g. 8K2P9A',
            controller: _shareCodeController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          AppSpacing.gapSm,
          PillButton(
            label: 'Link to Family Member',
            tone: PillButtonTone.moss,
            loading: _isLoading,
            onPressed: () => _handleRedeemShareCode(user),
          ),

          // Monitored Patients list
          caregiverSharesAsync.when(
            data: (shares) {
              if (shares.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapMd,
                  const Divider(),
                  AppSpacing.gapXs,
                  Text(
                    'Monitored Patients (${shares.length})',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  AppSpacing.gapXs,
                  ...shares.map(
                    (share) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.favorite, size: 16, color: Colors.white),
                      ),
                      title: Text(
                        share.patientName ?? 'Family Member',
                        style: AppTextStyles.bodyOnLight,
                      ),
                      subtitle: Text(
                        'Code: ${share.shareCode}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppSpacing.fontXs,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.link_off_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () async {
                          await ref
                              .read(familyShareRepositoryProvider)
                              .revokeShare(share.id);
                          ref.invalidate(caregiverSharesProvider);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestContent(bool isAppleSupported) {
    if (_isResetMode) {
      return _buildResetPasswordContent();
    }

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

          // Name field if registering
          if (_isRegister) ...[
            AppTextField(
              label: 'Your Name (Optional)',
              hint: 'John Doe',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
            ),
          ],

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

          if (!_isRegister) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isResetMode = true),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          AppSpacing.gapSm,

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

  Widget _buildResetPasswordContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _isResetMode = false),
              ),
              AppSpacing.gapXs,
              Text(
                'Reset Password',
                style: AppTextStyles.headlineOnLight.copyWith(
                  fontSize: AppSpacing.fontLg,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            'Enter your registered email address and we will send you a password reset link.',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapLg,
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
          AppSpacing.gapMd,
          PillButton(
            label: 'Send Reset Link',
            loading: _isLoading,
            onPressed: _handleEmailAuth,
          ),
          AppSpacing.gapSm,
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isResetMode = false),
              child: Text(
                'Back to Sign In',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ),
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
