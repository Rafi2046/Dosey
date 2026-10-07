import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/pill_button.dart';
import '../../family_sharing/domain/family_share.dart';
import '../../family_sharing/presentation/family_member_adherence_screen.dart';
import '../../family_sharing/providers/family_share_providers.dart';
import '../../family_sharing/providers/shared_adherence_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../settings/presentation/widgets/name_sheet.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../../../core/localization/l10n.dart';

/// Opens the Progressive Onboarding / Lazy Login sheet for Family Sharing.
Future<void> showFamilySharingAuthSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        child: const FamilySharingAuthSheet(),
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
    if (!await ensureOnline(context) || !mounted) return;

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
          _successMessage = context.l10n.fsResetEmailSent(email);
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
                  ? context.l10n.fsAccountCreated
                  : context.l10n.fsSignedIn,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e, l10n: context.l10n);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    if (!await ensureOnline(context) || !mounted) return;
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
          SnackBar(content: Text(context.l10n.fsSignedInGoogle)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e, l10n: context.l10n);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleAuth() async {
    if (!await ensureOnline(context) || !mounted) return;
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
          SnackBar(content: Text(context.l10n.fsSignedInApple)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e, l10n: context.l10n);
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
          SnackBar(content: Text(context.l10n.fsSignedOut)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (!await ensureOnline(context) || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.fsDeleteAccountTitle),
        content: Text(
          context.l10n.fsDeleteAccountBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.fsDeleteAccount),
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
          SnackBar(content: Text(context.l10n.fsAccountDeleted)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AuthRepository.formatAuthError(e, l10n: context.l10n);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEditProfileName(User user) async {
    if (!await ensureOnline(context) || !mounted) return;
    final localName = ref.read(userNameProvider).value;
    final currentName = user.displayName ?? localName ?? '';
    final entered = await showNameSheet(
      context,
      current: currentName,
      label: context.l10n.fsYourDisplayName,
      hint: context.l10n.fsDisplayNameHint,
    );

    if (entered == null) return;
    final sanitized = entered.trim();
    if (sanitized.isEmpty || sanitized == currentName) return;

    try {
      await user.updateDisplayName(sanitized);
      await ref.read(userNameProvider.notifier).set(sanitized);
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.updatePatientName(
        patientUid: user.uid,
        newName: sanitized,
      );
      ref.invalidate(patientSharesProvider);
      ref.invalidate(caregiverSharesProvider);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.fsNameUpdated(sanitized)),
            backgroundColor: AppColors.tileMoss,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.fsNameUpdateFailed('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGenerateShareCode(User user) async {
    if (!await ensureOnline(context) || !mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final localName = ref.read(userNameProvider).value;
      final effectiveName = (localName != null && localName.trim().isNotEmpty)
          ? localName.trim()
          : (user.displayName ?? user.email?.split('@').first);
      final repo = ref.read(familyShareRepositoryProvider);
      final share = await repo.createOrGetShareCode(
        patientUid: user.uid,
        patientName: effectiveName,
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
        _errorMessage = context.l10n.fsEnterSixCharCode;
      });
      return;
    }
    if (!await ensureOnline(context) || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final localName = ref.read(userNameProvider).value;
      final effectiveName = (localName != null && localName.trim().isNotEmpty)
          ? localName.trim()
          : (user.displayName ?? user.email?.split('@').first);
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.redeemShareCode(
        shareCode: code,
        caregiverUid: user.uid,
        caregiverName: effectiveName,
      );
      _shareCodeController.clear();
      ref.invalidate(caregiverSharesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.fsRequestSent,
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
    if (!await ensureOnline(context) || !mounted) return;
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
              context.l10n.fsLinkAccepted(share.caregiverName ?? context.l10n.fsCaregiver),
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
    if (!await ensureOnline(context) || !mounted) return;
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
          SnackBar(content: Text(context.l10n.fsRequestDeclined)),
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

  Future<void> _handleManualSyncSchedule(User user) async {
    if (!await ensureOnline(context) || !mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final occurrences = await ref.read(todayScheduleProvider.future);
      if (occurrences.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.fsNothingToSync),
            ),
          );
        }
        return;
      }
      final localName = ref.read(userNameProvider).value;
      final effectiveName = (localName != null && localName.trim().isNotEmpty)
          ? localName.trim()
          : (user.displayName ?? user.email?.split('@').first);
      final repo = ref.read(sharedAdherenceRepositoryProvider);
      await repo.syncTodaySchedule(
        patientUid: user.uid,
        patientName: effectiveName,
        occurrences: occurrences,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.fsSynced(occurrences.length),
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    // Signed in, but the email isn't confirmed yet.
    final unverified = user == null ? ref.watch(signedInUserProvider) : null;
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
                          context.l10n.fsOverline,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.accent,
                            fontSize: AppSpacing.fontXs,
                          ),
                        ),
                        Text(
                          context.l10n.fsTitle,
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
                            color: AppColors.successText,
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
              ] else if (unverified != null) ...[
                _buildVerifyEmailContent(unverified),
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
    final localName = ref.watch(userNameProvider).value;
    final displayName = user.displayName ?? localName ?? context.l10n.fsFamilyAccount;

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
                radius: 18,
                backgroundColor: AppColors.tileMint,
                child: Text(
                  (displayName.isNotEmpty ? displayName[0] : 'U').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSpacing.fontMd,
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyOnLight.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: AppSpacing.fontSm,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        InkWell(
                          onTap: () => _handleEditProfileName(user),
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      user.email ?? user.uid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: AppSpacing.fontXs,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tileMint.withValues(
                    alpha: AppColors.isDark ? 0.22 : 0.15,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 11,
                      color: AppColors.successText,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.fsCloudActive,
                      style: TextStyle(
                        fontSize: AppSpacing.fontXs,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapSm,

        // Mode switch tabs: 0 = My Share Code, 1 = Enter Family Code
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ModeTab(
                  label: context.l10n.fsMyCode,
                  icon: Icons.qr_code_2_rounded,
                  active: _activeFamilyTab == 0,
                  onTap: () => setState(() => _activeFamilyTab = 0),
                ),
              ),
              Expanded(
                child: _ModeTab(
                  label: context.l10n.fsEnterCode,
                  icon: Icons.vpn_key_rounded,
                  active: _activeFamilyTab == 1,
                  onTap: () => setState(() => _activeFamilyTab = 1),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapSm,

        if (_activeFamilyTab == 0) ...[
          // PATIENT MODE: Share my adherence
          _buildPatientShareCard(user, patientSharesAsync),
        ] else ...[
          // CAREGIVER MODE: Monitor family
          _buildCaregiverLinkCard(user, caregiverSharesAsync),
        ],

        AppSpacing.gapMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(
                Icons.logout_rounded,
                size: 15,
                color: AppColors.inkMuted,
              ),
              label: Text(
                context.l10n.fsSignOut,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.fontSm,
                ),
              ),
              onPressed: _isLoading ? null : _handleSignOut,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '•',
                style: TextStyle(color: AppColors.inkMuted.withValues(alpha: 0.5)),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _handleDeleteAccount,
              child: Text(
                context.l10n.fsDeleteAccount,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                  fontSize: AppSpacing.fontSm,
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
          width: 17,
          height: 17,
          margin: const EdgeInsets.only(top: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSpacing.fontXs,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
    return Material(
      color: AppColors.creamLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.fsShareTitle,
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppSpacing.fontSm,
                      ),
                    ),
                    Text(
                      context.l10n.fsShareSubtitle,
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
          _buildStepRow(
            stepNumber: '1',
            title: context.l10n.fsStepGenerateTitle,
            subtitle: context.l10n.fsStepGenerateBody,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStepRow(
            stepNumber: '2',
            title: context.l10n.fsStepSendTitle,
            subtitle: context.l10n.fsStepSendBody,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStepRow(
            stepNumber: '3',
            title: context.l10n.fsStepApproveTitle,
            subtitle: context.l10n.fsStepApproveBody,
            color: AppColors.accent,
          ),
          AppSpacing.gapSm,

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
                  label: context.l10n.fsGenerateCode,
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
                label: context.l10n.fsGenerateCode,
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
                        context.l10n.fsIncomingRequests(pending.length),
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
                                      share.caregiverName ?? context.l10n.fsFamilyCaregiver,
                                      style: AppTextStyles.bodyOnLight.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.fsWantsToConnect(share.shareCode),
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
                                  label: Text(
                                    context.l10n.fsDecline,
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
                                      vertical: AppSpacing.sm,
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
                                  label: Text(
                                    context.l10n.fsAccept,
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
                                      vertical: AppSpacing.sm,
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
                        context.l10n.fsLinkedCaregivers(accepted.length),
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
                        share.caregiverName ?? context.l10n.fsCaregiver,
                        style: AppTextStyles.bodyOnLight.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        context.l10n.fsActiveSyncCode(share.shareCode),
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
                        tooltip: context.l10n.fsUnlink,
                        onPressed: () async {
                          final confirmed = await confirmDelete(
                            context,
                            title: context.l10n.fsUnlinkCaregiverTitle,
                            body:
                                context.l10n.fsUnlinkCaregiverBody(share.caregiverName ?? context.l10n.fsThisCaregiver),
                            confirmLabel: context.l10n.fsUnlink,
                          );
                          if (confirmed) {
                            await ref
                                .read(familyShareRepositoryProvider)
                                .revokeShare(share.id);
                            ref.invalidate(patientSharesProvider);
                          }
                        },
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  PillButton(
                    label: context.l10n.fsSyncNow,
                    trailingIcon: Icons.cloud_upload_rounded,
                    tone: PillButtonTone.moss,
                    loading: _isLoading,
                    onPressed: () => _handleManualSyncSchedule(user),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
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
            context.l10n.fsYourCodeLabel,
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
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: AppColors.divider),
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: AppSpacing.fontXl,
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
                    context.l10n.fsCopyCode,
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.fsCodeCopied(code)),
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 15, color: Colors.white),
                  label: Text(
                    context.l10n.fsShareCode,
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
                  ),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            context.l10n.fsShareMessage(code),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            context.l10n.fsCodeValidity,
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
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
                          fontSize: AppSpacing.fontXl,
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
                context.l10n.fsPasteCode,
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
                  context.l10n.clear,
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

    return Material(
      color: AppColors.creamLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.tileMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: AppColors.tileMint,
                  size: 18,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.fsLinkTitle,
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppSpacing.fontSm,
                      ),
                    ),
                    Text(
                      context.l10n.fsLinkSubtitle,
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
          _buildStepRow(
            stepNumber: '1',
            title: context.l10n.fsStepAskTitle,
            subtitle: context.l10n.fsStepAskBody,
            color: AppColors.tileMint,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStepRow(
            stepNumber: '2',
            title: context.l10n.fsStepEnterTitle,
            subtitle: context.l10n.fsStepEnterBody,
            color: AppColors.tileMint,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStepRow(
            stepNumber: '3',
            title: context.l10n.fsStepWaitTitle,
            subtitle: context.l10n.fsStepWaitBody,
            color: AppColors.tileMint,
          ),
          AppSpacing.gapSm,
          _buildCaregiverCodeInput(),
          AppSpacing.gapSm,
          PillButton(
            label: context.l10n.fsSendRequest,
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
                          context.l10n.fsPendingApproval(pending.length),
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
                          share.patientName ?? context.l10n.fsFamilyMember,
                          style: AppTextStyles.bodyOnLight.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n.fsAwaitingApproval(share.shareCode),
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
                            context.l10n.cancel,
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
                          context.l10n.fsConnectedMembers(accepted.length),
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
                          share.patientName ?? context.l10n.fsFamilyMember,
                          style: AppTextStyles.bodyOnLight.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n.fsActiveSyncTap,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: AppSpacing.fontXs,
                            color: AppColors.tileMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.link_off_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              tooltip: context.l10n.fsUnlink,
                              onPressed: () async {
                                final confirmed = await confirmDelete(
                                  context,
                                  title: context.l10n.fsRemoveMemberTitle,
                                  body:
                                      context.l10n.fsStopMonitoring(share.patientName ?? context.l10n.fsThisMember),
                                  confirmLabel: context.l10n.fsRemove,
                                );
                                if (confirmed) {
                                  await ref
                                      .read(familyShareRepositoryProvider)
                                      .revokeShare(share.id);
                                  ref.invalidate(caregiverSharesProvider);
                                }
                              },
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.inkMuted,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  FamilyMemberAdherenceScreen(share: share),
                            ),
                          );
                        },
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
    ),
  );
}

  Widget _buildGuestContent(bool isAppleSupported) {
    if (_isResetMode) {
      return _buildResetPasswordContent();
    }

    return Form(
      key: _formKey,
      // A fixed field clears its error as soon as it is valid again.
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.fsIntro,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapLg,

          // Social Login Buttons
          _SocialAuthButton(
            icon: Icons.g_mobiledata_rounded,
            label: context.l10n.fsContinueGoogle,
            onPressed: _isLoading ? null : _handleGoogleAuth,
          ),
          if (isAppleSupported) ...[
            AppSpacing.gapSm,
            _SocialAuthButton(
              icon: Icons.apple_rounded,
              label: context.l10n.fsContinueApple,
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
                  context.l10n.fsOrEmail,
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
                    label: context.l10n.fsSignIn,
                    active: !_isRegister,
                    onTap: () => setState(() => _isRegister = false),
                  ),
                ),
                Expanded(
                  child: _ModeTab(
                    label: context.l10n.fsCreateAccount,
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
              label: context.l10n.fsNameOptional,
              hint: context.l10n.fsFullNameHint,
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
            ),
          ],

          // Email & Password Fields
          AppTextField(
            label: context.l10n.email,
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.l10n.fsEmailRequired;
              if (!v.contains('@')) return context.l10n.fsEmailInvalid;
              return null;
            },
          ),
          AppTextField(
            label: context.l10n.fsPassword,
            hint: _isRegister ? context.l10n.fsPasswordNewHint : context.l10n.fsPasswordHint,
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
              if (v == null || v.isEmpty) return context.l10n.fsPasswordRequired;
              if (_isRegister && v.length < 6) {
                return context.l10n.fsPasswordTooShort;
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
                  context.l10n.fsForgotPassword,
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
            label: _isRegister ? context.l10n.fsCreateAccount : context.l10n.fsSignIn,
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
                  context.l10n.fsOfflineFirst,
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

  Future<void> _runVerifyAction(
    Future<void> Function() action, {
    bool needsInternet = true,
  }) async {
    if (needsInternet && (!await ensureOnline(context) || !mounted)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = AuthRepository.formatAuthError(e, l10n: context.l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Email/password accounts confirm their address before family sharing
  /// opens, so nobody can link to a family using someone else's email.
  Widget _buildVerifyEmailContent(User user) {
    final repo = ref.read(authRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_unread_rounded,
          color: AppColors.accent,
          size: 48,
        ),
        AppSpacing.gapMd,
        Text(
          context.l10n.fsVerifyTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineOnLight.copyWith(
            fontSize: AppSpacing.fontLg,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          context.l10n.fsVerifyBody(user.email ?? context.l10n.fsYourEmail),
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        AppSpacing.gapLg,
        PillButton(
          label: context.l10n.fsIveVerified,
          loading: _isLoading,
          onPressed: () => _runVerifyAction(() async {
            final verified = await repo.reloadAndCheckVerified();
            if (!verified && mounted) {
              setState(
                () => _errorMessage =
                    context.l10n.fsNotVerifiedYet,
              );
            }
          }),
        ),
        AppSpacing.gapSm,
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => _runVerifyAction(() async {
                    await repo.sendEmailVerification();
                    if (mounted) {
                      setState(
                        () => _successMessage =
                            context.l10n.fsVerificationSent(user.email ?? ''),
                      );
                    }
                  }),
            child: Text(
              context.l10n.fsResendEmail,
              style: AppTextStyles.caption.copyWith(color: AppColors.accent),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () => _runVerifyAction(repo.signOut, needsInternet: false),
            child: Text(
              context.l10n.fsUseAnotherAccount,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordContent() {
    return Form(
      key: _formKey,
      // A fixed field clears its error as soon as it is valid again.
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
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
                context.l10n.fsResetTitle,
                style: AppTextStyles.headlineOnLight.copyWith(
                  fontSize: AppSpacing.fontLg,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            context.l10n.fsResetBody,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          AppSpacing.gapLg,
          AppTextField(
            label: context.l10n.email,
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.l10n.fsEmailRequired;
              if (!v.contains('@')) return context.l10n.fsEmailInvalid;
              return null;
            },
          ),
          AppSpacing.gapMd,
          PillButton(
            label: context.l10n.fsSendResetLink,
            loading: _isLoading,
            onPressed: _handleEmailAuth,
          ),
          AppSpacing.gapSm,
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isResetMode = false),
              child: Text(
                context.l10n.fsBackToSignIn,
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
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
