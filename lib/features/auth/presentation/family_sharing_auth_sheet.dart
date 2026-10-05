import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const FractionallySizedBox(
        heightFactor: AppSpacing.moreSheetHeightFactor,
        child: FamilySharingAuthSheet(),
      ),
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
  final _shareCodeFocusNode = FocusNode();

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
  void initState() {
    super.initState();
    _shareCodeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _shareCodeController.dispose();
    _shareCodeFocusNode.dispose();
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
          const SnackBar(
            content: Text(
              'Connection request sent! Waiting for your family member to accept.',
            ),
          ),
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

  Future<void> _handleAcceptShare(FamilyShare share) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.acceptShare(share.id);
      ref.invalidate(patientSharesProvider);
      ref.invalidate(caregiverSharesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Link accepted! ${share.caregiverName ?? "Caregiver"} is now linked.',
            ),
          ),
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

  Future<void> _handleDeclineShare(FamilyShare share) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.declineShare(share.id);
      ref.invalidate(patientSharesProvider);
      ref.invalidate(caregiverSharesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link request declined.')),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.tileMint,
                child: Text(
                  (user.displayName?.isNotEmpty == true
                          ? user.displayName![0]
                          : user.email?.isNotEmpty == true
                              ? user.email![0]
                              : 'U')
                      .toUpperCase(),
                  style: AppTextStyles.headline.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Family Account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email ?? user.uid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              const StatusChip(
                label: 'Cloud Active',
                icon: Icons.check_circle_rounded,
                background: AppColors.tileMint,
                foreground: Colors.white,
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Mode switch tabs: 0 = My Share Code, 1 = Enter Family Code
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
                  label: 'My Code',
                  icon: Icons.qr_code_2_rounded,
                  active: _activeFamilyTab == 0,
                  onTap: () => setState(() => _activeFamilyTab = 0),
                ),
              ),
              Expanded(
                child: _ModeTab(
                  label: 'Enter Code',
                  icon: Icons.vpn_key_rounded,
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

        AppSpacing.gapLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(
                Icons.logout_rounded,
                size: 16,
                color: AppColors.inkMuted,
              ),
              label: Text(
                'Sign Out',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _isLoading ? null : _handleSignOut,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '•',
                style: TextStyle(color: AppColors.inkMuted.withValues(alpha: 0.5)),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _handleDeleteAccount,
              child: Text(
                'Delete Account',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.fontSm,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                  fontSize: AppSpacing.fontXs,
                ),
              ),
            ],
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
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
                      'Share Your Doses & Reminders',
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Let family members monitor your medication adherence',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          _buildStepRow(
            stepNumber: '1',
            title: 'Generate your 6-character code below',
            subtitle: 'Your unique code connects caregiver devices.',
            color: AppColors.accent,
          ),
          AppSpacing.gapSm,
          _buildStepRow(
            stepNumber: '2',
            title: 'Send it to your caregiver or family member',
            subtitle: 'They enter this code in their Dosey app.',
            color: AppColors.accent,
          ),
          AppSpacing.gapSm,
          _buildStepRow(
            stepNumber: '3',
            title: 'Approve incoming link requests',
            subtitle: 'Review and accept requests from your family members.',
            color: AppColors.accent,
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
                  label: 'Generate My Family Share Code',
                  trailingIcon: Icons.vpn_key_rounded,
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
                label: 'Generate My Family Share Code',
                trailingIcon: Icons.vpn_key_rounded,
                tone: PillButtonTone.accent,
                loading: _isLoading,
                onPressed: () => _handleGenerateShareCode(user),
              ),
            ),
          ],

          // Incoming Link Requests (Pending Approval)
          patientSharesAsync.when(
            data: (shares) {
              final pending = shares.where((s) => s.isPending).toList();
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapMd,
                  const Divider(),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        'Incoming Link Requests (${pending.length})',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapXs,
                  ...pending.map(
                    (share) => Container(
                      margin: const EdgeInsets.only(top: AppSpacing.xs),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.isDark ? AppColors.cream : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    AppColors.warning.withValues(alpha: 0.2),
                                child: Text(
                                  (share.caregiverName?.isNotEmpty == true
                                          ? share.caregiverName![0]
                                          : 'C')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                              AppSpacing.gapSm,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      share.caregiverName ?? 'Family Caregiver',
                                      style: AppTextStyles.bodyOnLight.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Wants to connect using code ${share.shareCode}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.inkMuted,
                                        fontSize: AppSpacing.fontXs,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapSm,
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  label: const Text(
                                    'Decline',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: AppSpacing.fontSm,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppColors.error.withValues(alpha: 0.5),
                                    ),
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleDeclineShare(share),
                                ),
                              ),
                              AppSpacing.gapSm,
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Accept',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppSpacing.fontSm,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tileMint,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleAcceptShare(share),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          // Linked Caregivers list (Accepted)
          patientSharesAsync.when(
            data: (shares) {
              final accepted = shares.where((s) => s.isAccepted).toList();
              if (accepted.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapMd,
                  const Divider(),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 16,
                        color: AppColors.tileMint,
                      ),
                      AppSpacing.gapXs,
                      Text(
                        'Linked Caregivers (${accepted.length})',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapXs,
                  ...accepted.map(
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
                        style: AppTextStyles.bodyOnLight.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Active sync • Code: ${share.shareCode}',
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
                        tooltip: 'Unlink',
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
        color: AppColors.isDark ? AppColors.cream : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.isDark
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.isDark ? 0.3 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'YOUR 6-CHARACTER SHARE CODE',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((char) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 22,
                    letterSpacing: 0,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.copy_rounded, size: 15, color: AppColors.ink),
                  label: Text(
                    'Copy Code',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: AppSpacing.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.divider),
                    backgroundColor: AppColors.isDark
                        ? AppColors.creamLight
                        : Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code "$code" copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 15, color: Colors.white),
                  label: const Text(
                    'Share Code',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Here is my Dosey family share code: $code\n\nEnter it in your Dosey app under Settings > Caregiver & Family Mode to link our accounts.',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Share this code with your family member. Valid for 7 days.',
            style: AppTextStyles.caption.copyWith(
              fontSize: AppSpacing.fontXs,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverCodeInput() {
    final text = _shareCodeController.text.toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _shareCodeFocusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Visual 6-box display
              Row(
                children: List.generate(6, (index) {
                  final char = index < text.length ? text[index] : '';
                  final isFocused = _shareCodeFocusNode.hasFocus &&
                      (index == text.length || (index == 5 && text.length == 6));
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.isDark ? AppColors.cream : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: isFocused
                              ? AppColors.tileMint
                              : (char.isNotEmpty ? AppColors.ink : AppColors.divider),
                          width: isFocused ? 2.0 : 1.2,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.tileMint.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        char,
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Invisible real TextField on top
              Opacity(
                opacity: 0.0,
                child: TextField(
                  focusNode: _shareCodeFocusNode,
                  controller: _shareCodeController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(
                Icons.content_paste_rounded,
                size: 16,
                color: AppColors.tileMint,
              ),
              label: Text(
                'Paste Code',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.tileMint,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                final data = await Clipboard.getData('text/plain');
                final rawText = data?.text?.trim().toUpperCase() ?? '';
                final cleaned = rawText.replaceAll(RegExp(r'[^A-Z0-9]'), '');
                if (cleaned.isNotEmpty) {
                  final code = cleaned.length > 6 ? cleaned.substring(0, 6) : cleaned;
                  _shareCodeController.text = code;
                  _shareCodeController.selection =
                      TextSelection.collapsed(offset: code.length);
                }
              },
            ),
            if (text.isNotEmpty) ...[
              AppSpacing.gapSm,
              TextButton.icon(
                icon: Icon(
                  Icons.clear_rounded,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
                label: Text(
                  'Clear',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  _shareCodeController.clear();
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCaregiverLinkCard(
    User user,
    AsyncValue<List<FamilyShare>> caregiverSharesAsync,
  ) {
    final hasValidCode = _shareCodeController.text.trim().length == 6;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tileMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group_add_rounded,
                  color: AppColors.tileMint,
                  size: 20,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link to a Family Member',
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Enter their 6-character code to link profiles',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          _buildStepRow(
            stepNumber: '1',
            title: 'Ask your family member for their 6-character code',
            subtitle: 'Found under "My Share Code" on their phone.',
            color: AppColors.tileMint,
          ),
          AppSpacing.gapSm,
          _buildStepRow(
            stepNumber: '2',
            title: 'Enter or paste the 6-character code below',
            subtitle: 'Tap the boxes or use the Paste button.',
            color: AppColors.tileMint,
          ),
          AppSpacing.gapSm,
          _buildStepRow(
            stepNumber: '3',
            title: 'Wait for family member approval',
            subtitle: 'They must accept your link request to start sync.',
            color: AppColors.tileMint,
          ),
          AppSpacing.gapMd,
          _buildCaregiverCodeInput(),
          AppSpacing.gapSm,
          PillButton(
            label: 'Request Link to Family Member',
            trailingIcon: Icons.arrow_forward_rounded,
            tone: hasValidCode ? PillButtonTone.accent : PillButtonTone.moss,
            loading: _isLoading,
            onPressed: hasValidCode ? () => _handleRedeemShareCode(user) : null,
          ),

          // Caregiver Shares Lists: Pending Approvals & Connected Members
          caregiverSharesAsync.when(
            data: (shares) {
              final pending = shares.where((s) => s.isPending).toList();
              final accepted = shares.where((s) => s.isAccepted).toList();
              if (pending.isEmpty && accepted.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pending.isNotEmpty) ...[
                    AppSpacing.gapMd,
                    const Divider(),
                    AppSpacing.gapXs,
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          'Pending Approval (${pending.length})',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapXs,
                    ...pending.map(
                      (share) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.warning,
                          child: Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          share.patientName ?? 'Family Member',
                          style: AppTextStyles.bodyOnLight.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Awaiting approval • Code: ${share.shareCode}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: AppSpacing.fontXs,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(familyShareRepositoryProvider)
                                .declineShare(share.id);
                            ref.invalidate(caregiverSharesProvider);
                          },
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.inkMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (accepted.isNotEmpty) ...[
                    AppSpacing.gapMd,
                    const Divider(),
                    AppSpacing.gapXs,
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.tileMint,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          'Connected Family Members (${accepted.length})',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapXs,
                    ...accepted.map(
                      (share) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.accent,
                          child: Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          share.patientName ?? 'Family Member',
                          style: AppTextStyles.bodyOnLight.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Active sync • Code: ${share.shareCode}',
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
                          tooltip: 'Unlink',
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
              isApple: true,
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
    this.isApple = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isApple;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppColors.isDark;

    final Color buttonBgColor;
    final Color textColor;
    final Color borderColor;

    if (isApple) {
      if (isDarkMode) {
        buttonBgColor = Colors.white;
        textColor = Colors.black;
        borderColor = Colors.transparent;
      } else {
        buttonBgColor = Colors.black;
        textColor = Colors.white;
        borderColor = Colors.transparent;
      }
    } else {
      // Google button
      if (isDarkMode) {
        buttonBgColor = AppColors.creamLight;
        textColor = AppColors.ink;
        borderColor = AppColors.divider;
      } else {
        buttonBgColor = Colors.white;
        textColor = AppColors.ink;
        borderColor = AppColors.divider;
      }
    }

    return Material(
      color: buttonBgColor,
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
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: textColor,
              ),
              AppSpacing.gapSm,
              Text(
                label,
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
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
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSpacing.animFast,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? (AppColors.isDark ? AppColors.sand : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppColors.isDark ? 0.25 : 0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
                color: active
                    ? (AppColors.isDark ? AppColors.ink : AppColors.accent)
                    : AppColors.inkMuted,
              ),
              AppSpacing.gapXs,
            ],
            Text(
              label,
              style: AppTextStyles.bodyOnLight.copyWith(
                fontSize: AppSpacing.fontSm,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.ink : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
