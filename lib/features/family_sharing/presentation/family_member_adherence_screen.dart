import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/surface_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/family_share.dart';
import '../domain/shared_adherence_dose.dart';
import '../providers/shared_adherence_providers.dart';

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

  String _imageForForm(String? form) {
    switch (form?.toLowerCase()) {
      case 'injection':
        return AppImages.medInjection;
      case 'capsule':
        return AppImages.medCapsule;
      case 'tablet':
        return AppImages.medTablet;
      default:
        return AppImages.medOther;
    }
  }

  Future<void> _handleSendNudge(User? user) async {
    if (user == null) return;
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
              '🔔 Gentle reminder sent to ${widget.share.patientName ?? "Family Member"}\'s phone!',
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

  @override
  Widget build(BuildContext context) {
    final patientName = widget.share.patientName ?? 'Family Member';
    final user = ref.watch(currentUserProvider);
    final scheduleAsync =
        ref.watch(patientAdherenceScheduleProvider(widget.share.patientUid));

    return CreamScaffold(
      title: patientName,
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
              // Patient Profile Compact Banner
              SurfaceCard(
                color: AppColors.creamLight,
                elevated: true,
                radius: AppSpacing.radiusLg,
                padding: AppSpacing.cardPadding,
                child: Row(
                  children: [
                    InitialsAvatar(name: patientName, size: AppSpacing.avatarMd),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: AppTextStyles.cardTitleOnLight.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          AppSpacing.gapXs,
                          Text(
                            'Share Code: ${widget.share.shareCode}',
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
              ),
              AppSpacing.gapLg,

              // Schedule Content
              scheduleAsync.when(
                data: (doses) {
                  if (doses.isEmpty) {
                    return _buildEmptyState(context);
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
                        onPressed: () => _handleSendNudge(user),
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
                  color: AppColors.tileMint.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '$adherenceRate%',
                  style: const TextStyle(
                    color: AppColors.tileMoss,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
              _buildCountPill('Taken', taken, AppColors.tileMint, AppColors.tileMoss),
              _buildCountPill('Pending', pending, AppColors.warning, const Color(0xFFC07000)),
              _buildCountPill('Missed', missed, AppColors.error, AppColors.error),
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
        color: bgTint.withValues(alpha: 0.12),
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
    Color statusBg = AppColors.warning.withValues(alpha: 0.14);
    Color statusFg = const Color(0xFFC07000);
    String statusText = 'Pending';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (dose.isTaken) {
      statusBg = AppColors.tileMint.withValues(alpha: 0.18);
      statusFg = AppColors.tileMoss;
      statusText = 'Taken';
      statusIcon = Icons.check_circle_rounded;
    } else if (dose.isMissed) {
      statusBg = AppColors.error.withValues(alpha: 0.14);
      statusFg = AppColors.error;
      statusText = 'Missed';
      statusIcon = Icons.error_rounded;
    } else if (dose.isSkipped) {
      statusBg = AppColors.inkMuted.withValues(alpha: 0.14);
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 48,
            color: AppColors.inkMuted,
          ),
          AppSpacing.gapMd,
          Text(
            'No Shared Doses Found Today',
            style: AppTextStyles.cardTitleOnLight.copyWith(
              fontSize: 16,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            'When ${widget.share.patientName ?? "your family member"} opens Dosey or logs doses, their schedule will appear here automatically.',
            textAlign: TextAlign.center,
            style: AppTextStyles.captionOnLight,
          ),
        ],
      ),
    );
  }
}

