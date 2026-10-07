import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/surface_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../../settings/presentation/widgets/name_sheet.dart';
import '../domain/family_share.dart';
import '../domain/shared_adherence_dose.dart';
import '../domain/remote_prescription_sync_service.dart';
import '../providers/family_share_providers.dart';
import '../providers/shared_adherence_providers.dart';
import 'remote_medicine_manage_screen.dart';

class FamilyMemberAdherenceScreen extends ConsumerStatefulWidget {
  const FamilyMemberAdherenceScreen({
    super.key,
    required this.share,
  });

  final FamilyShare share;

  @override
  ConsumerState<FamilyMemberAdherenceScreen> createState() =>
      _FamilyMemberAdherenceScreenState();
}

class _FamilyMemberAdherenceScreenState
    extends ConsumerState<FamilyMemberAdherenceScreen> {
  bool _isSendingNudge = false;
  final Set<String> _nudgedDoses = {};
  FamilyShare? _localShare;

  String _imageForForm(String? form) {
    switch (form?.toLowerCase()) {
      case 'injection':
        return AppImages.medInjection;
      case 'capsule':
        return AppImages.medCapsule;
      case 'tablet':
      default:
        return AppImages.medTablet;
    }
  }

  Future<void> _handleEditPatientName(FamilyShare currentShare) async {
    if (!await ensureOnline(context) || !mounted) return;
    final currentName = currentShare.patientName ?? '';
    final entered = await showNameSheet(
      context,
      current: currentName,
      label: 'Edit Family Member Name',
      hint: 'e.g. Dad, Mom, Rahat',
    );

    if (entered == null) return;
    final sanitized = entered.trim();
    if (sanitized.isEmpty || sanitized == currentName) return;

    setState(() {
      _localShare = currentShare.copyWith(patientName: sanitized);
    });

    try {
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.updatePatientName(
        patientUid: currentShare.patientUid,
        newName: sanitized,
      );
      ref.invalidate(caregiverSharesProvider);
      ref.invalidate(patientSharesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated name to "$sanitized"'),
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
            content: Text('Failed to update name: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveMember(
    FamilyShare currentShare,
    String patientName,
  ) async {
    if (!await ensureOnline(context) || !mounted) return;
    final confirmed = await confirmDelete(
      context,
      title: 'Remove Family Member',
      body:
          'Are you sure you want to stop monitoring $patientName? You will no longer receive their adherence updates.',
      confirmLabel: 'Remove',
    );

    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(familyShareRepositoryProvider);
      await repo.revokeShare(currentShare.id);
      ref.invalidate(caregiverSharesProvider);
      ref.invalidate(patientSharesProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $patientName from monitored family members.'),
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
            content: Text('Failed to remove member: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSendDoseNudge(SharedAdherenceDose dose, User? user) async {
    if (user == null) return;
    final doseKey = '${dose.medicineName}_${dose.time}';
    if (_nudgedDoses.contains(doseKey)) return;
    if (!await ensureOnline(context) || !mounted) return;

    try {
      final repo = ref.read(remotePrescriptionRepositoryProvider);
      await repo.sendTargetedDoseNudge(
        patientUid: widget.share.patientUid,
        caregiverUid: user.uid,
        caregiverName: user.displayName ?? user.email?.split('@').first,
        medicineName: dose.medicineName,
        scheduledTime: dose.time,
      );

      setState(() {
        _nudgedDoses.add(doseKey);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 Sent reminder for ${dose.medicineName} (${dose.time})!',
            ),
            backgroundColor: AppColors.moss,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSendNudge(User? user, String patientName) async {
    if (user == null) return;
    if (!await ensureOnline(context) || !mounted) return;
    setState(() => _isSendingNudge = true);
    try {
      final repo = ref.read(sharedAdherenceRepositoryProvider);
      await repo.sendGentleReminder(
        patientUid: widget.share.patientUid,
        caregiverUid: user.uid,
        caregiverName: user.displayName ?? user.email?.split('@').first,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 Gentle reminder sent to $patientName\'s phone!',
            ),
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
            content: Text('$e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingNudge = false);
    }
  }

  void _openManageMedicines(FamilyShare currentShare) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RemoteMedicineManageScreen(share: currentShare),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caregiverShares = ref.watch(caregiverSharesProvider).value;
    final currentShare = caregiverShares?.firstWhere(
          (s) =>
              s.patientUid == widget.share.patientUid ||
              s.id == widget.share.id,
          orElse: () => _localShare ?? widget.share,
        ) ??
        _localShare ??
        widget.share;
    final patientName = currentShare.patientName?.trim().isNotEmpty == true
        ? currentShare.patientName!
        : 'Family Member';
    final user = ref.watch(currentUserProvider);
    final scheduleAsync =
        ref.watch(patientAdherenceScheduleProvider(widget.share.patientUid));

    return CreamScaffold(
      title: patientName,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Edit member name',
          onPressed: () => _handleEditPatientName(currentShare),
        ),
        IconButton(
          icon: const Icon(Icons.person_remove_outlined, size: 20),
          color: AppColors.error,
          tooltip: 'Remove family member',
          onPressed: () => _handleRemoveMember(currentShare, patientName),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
              patientAdherenceScheduleProvider(widget.share.patientUid));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xs,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Profile Compact Banner with Manage Button
              SurfaceCard(
                color: AppColors.creamLight,
                elevated: true,
                radius: AppSpacing.radiusLg,
                padding: AppSpacing.cardPadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InitialsAvatar(name: patientName, size: AppSpacing.avatarMd),
                        AppSpacing.gapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      patientName,
                                      style: AppTextStyles.cardTitleOnLight.copyWith(
                                        fontSize: 17,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _handleEditPatientName(currentShare),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 15,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapXs,
                              Text(
                                'Share Code: ${currentShare.shareCode}',
                                style: AppTextStyles.captionOnLight,
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(
                          label: 'Live',
                          icon: Icons.sync_rounded,
                          background: AppColors.tileMint,
                          foreground: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _openManageMedicines(currentShare),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.medication_liquid_rounded,
                              size: 19,
                              color: AppColors.moss,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Manage & Edit Medicines for $patientName',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: AppColors.inkMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,

              // Schedule Content
              scheduleAsync.when(
                data: (doses) {
                  if (doses.isEmpty) {
                    return _buildEmptyState(context, patientName);
                  }

                  final takenCount = doses.where((d) => d.isTaken).length;
                  final pendingCount = doses.where((d) => d.isPending).length;
                  final missedCount = doses.where((d) => d.isMissed).length;
                  final adherenceRate =
                      (takenCount / doses.length * 100).round();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Adherence Metric Card
                      _buildAdherenceCard(
                        adherenceRate: adherenceRate,
                        taken: takenCount,
                        total: doses.length,
                        pending: pendingCount,
                        missed: missedCount,
                      ),
                      AppSpacing.gapLg,

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            Container(
                              width: AppSpacing.headerTickWidth,
                              height: AppSpacing.headerTickHeight,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            AppSpacing.gapSm,
                            Text(
                              "TODAY'S SCHEDULE",
                              style: AppTextStyles.overline.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapSm,

                      // Doses List
                      ...doses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dose = entry.value;
                        final color = AppColors.cardCycleOnLight[
                            index % AppColors.cardCycleOnLight.length];
                        return _buildDoseItem(dose, color);
                      }),

                      AppSpacing.gapLg,
                      // Nudge / Caregiver Action Button
                      PillButton(
                        label: 'Send Gentle Reminder',
                        trailingIcon: Icons.notifications_active_rounded,
                        tone: PillButtonTone.accent,
                        loading: _isSendingNudge,
                        onPressed: () => _handleSendNudge(user, patientName),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, st) => Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.creamLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 32,
                        color: AppColors.inkMuted,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'Could not load shared schedule',
                        style: AppTextStyles.bodyOnLight.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pull down to refresh and retry.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapXl,
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.link_off_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Remove $patientName from Monitoring',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  onPressed: () =>
                      _handleRemoveMember(currentShare, patientName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdherenceCard({
    required int adherenceRate,
    required int taken,
    required int total,
    required int pending,
    required int missed,
  }) {
    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      radius: AppSpacing.radiusLg,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Adherence",
                    style: AppTextStyles.cardTitleOnLight.copyWith(
                      fontSize: 17,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '$taken of $total doses completed',
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tileMint.withValues(
                    alpha: AppColors.isDark ? 0.22 : 0.18,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '$adherenceRate%',
                  style: TextStyle(
                    fontFamily: 'NDot',
                    color: AppColors.isDark
                        ? const Color(0xFF64D2B4)
                        : AppColors.tileMoss,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: total > 0 ? taken / total : 0,
              minHeight: AppSpacing.barHeight,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.tileMint),
            ),
          ),
          AppSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCountPill(
                'Taken',
                taken,
                AppColors.tileMint,
                AppColors.isDark ? const Color(0xFF64D2B4) : AppColors.tileMoss,
              ),
              _buildCountPill(
                'Pending',
                pending,
                AppColors.warning,
                AppColors.isDark
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFFC07000),
              ),
              _buildCountPill(
                'Missed',
                missed,
                AppColors.error,
                AppColors.isDark ? const Color(0xFFFF7D7D) : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountPill(String label, int count, Color bgTint, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgTint.withValues(alpha: AppColors.isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fgColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseItem(SharedAdherenceDose dose, Color accentColor) {
    Color statusBg = AppColors.warning.withValues(
      alpha: AppColors.isDark ? 0.22 : 0.14,
    );
    Color statusFg = AppColors.isDark
        ? const Color(0xFFFFB74D)
        : const Color(0xFFC07000);
    String statusText = 'Pending';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (dose.isTaken) {
      statusBg = AppColors.tileMint.withValues(
        alpha: AppColors.isDark ? 0.22 : 0.18,
      );
      statusFg = AppColors.isDark
          ? const Color(0xFF64D2B4)
          : AppColors.tileMoss;
      statusText = 'Taken';
      statusIcon = Icons.check_circle_rounded;
    } else if (dose.isMissed) {
      statusBg = AppColors.error.withValues(
        alpha: AppColors.isDark ? 0.22 : 0.14,
      );
      statusFg = AppColors.isDark ? const Color(0xFFFF7D7D) : AppColors.error;
      statusText = 'Missed';
      statusIcon = Icons.error_rounded;
    } else if (dose.isSkipped) {
      statusBg = AppColors.inkMuted.withValues(
        alpha: AppColors.isDark ? 0.22 : 0.14,
      );
      statusFg = AppColors.inkMuted;
      statusText = 'Skipped';
      statusIcon = Icons.remove_circle_outline_rounded;
    }

    String subtitle = dose.dosage ?? '1 dose';
    if (dose.mealRelation != null &&
        dose.mealRelation != 'anytime' &&
        dose.mealRelation!.isNotEmpty) {
      subtitle += ' • ${dose.mealRelation}';
    }

    final doseKey = '${dose.medicineName}_${dose.time}';
    final isNudged = _nudgedDoses.contains(doseKey);
    final user = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SurfaceCard(
        color: AppColors.creamLight,
        elevated: true,
        radius: AppSpacing.radiusLg,
        padding: AppSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Generous Dosey medicine illustration
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Image.asset(
                _imageForForm(dose.form),
                fit: BoxFit.contain,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dose.medicineName,
                    style: AppTextStyles.cardTitleOnLight.copyWith(
                      fontSize: 16.5,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    subtitle,
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dose.time,
                  style: AppTextStyles.bodyOnLight.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                AppSpacing.gapXs,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusFg),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusFg,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dose.isPending || dose.isMissed) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: isNudged ? null : () => _handleSendDoseNudge(dose, user),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isNudged
                                ? AppColors.tileMint.withValues(alpha: 0.18)
                                : AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                              color: isNudged
                                  ? AppColors.tileMint
                                  : AppColors.accent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isNudged
                                    ? Icons.check_rounded
                                    : Icons.notifications_active_rounded,
                                size: 12,
                                color: isNudged
                                    ? AppColors.tileMoss
                                    : AppColors.accent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isNudged ? 'Nudged' : 'Nudge',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isNudged
                                      ? AppColors.tileMoss
                                      : AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String patientName) {
    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Image.asset(AppImages.emptyHistory, height: 96),
          AppSpacing.gapMd,
          Text(
            'No Shared Doses Found Today',
            style: AppTextStyles.cardTitleOnLight.copyWith(
              fontSize: 16,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            'When $patientName opens Dosey or logs doses, their schedule will appear here automatically.',
            textAlign: TextAlign.center,
            style: AppTextStyles.captionOnLight,
          ),
        ],
      ),
    );
  }
}

