import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
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
              'Gentle reminder sent to ${widget.share.patientName ?? "Family Member"}\'s phone! 🔔',
            ),
            backgroundColor: AppColors.tileMoss,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reminder: $e')),
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
            top: AppSpacing.sm,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Profile Banner
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
                    InitialsAvatar(name: patientName, size: 40),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: AppTextStyles.headlineOnLight.copyWith(
                              fontSize: AppSpacing.fontMd,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Share Code: ${widget.share.shareCode}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: AppSpacing.fontXs,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      label: 'Live Sync',
                      icon: Icons.sync_rounded,
                      background: AppColors.tileMint,
                      foreground: Colors.white,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,

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
                      AppSpacing.gapMd,

                      // Section Title
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          AppSpacing.gapXs,
                          Text(
                            "Today's Medication Schedule",
                            style: AppTextStyles.subtitleOnLight.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: AppSpacing.fontSm,
                            ),
                          ),
                        ],
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

                      AppSpacing.gapMd,
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 36,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.tileMint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
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
                      "Today's Adherence: $adherenceRate%",
                      style: AppTextStyles.bodyOnLight.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppSpacing.fontSm,
                      ),
                    ),
                    Text(
                      '$taken of $total doses completed',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: total > 0 ? taken / total : 0,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.tileMint),
            ),
          ),
          AppSpacing.gapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountPill('Taken', taken, AppColors.tileMint),
              _buildCountPill('Pending', pending, AppColors.warning),
              _buildCountPill('Missed', missed, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          AppSpacing.gapXs,
          Text(
            '$label: $count',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: AppSpacing.fontXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseItem(SharedAdherenceDose dose, Color accentColor) {
    Color statusBg = AppColors.warning.withValues(alpha: 0.12);
    Color statusFg = AppColors.warning;
    String statusText = 'Pending';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (dose.isTaken) {
      statusBg = AppColors.tileMint.withValues(alpha: 0.15);
      statusFg = AppColors.tileMoss;
      statusText = 'Taken';
      statusIcon = Icons.check_circle_rounded;
    } else if (dose.isMissed) {
      statusBg = AppColors.error.withValues(alpha: 0.12);
      statusFg = AppColors.error;
      statusText = 'Missed';
      statusIcon = Icons.error_rounded;
    } else if (dose.isSkipped) {
      statusBg = AppColors.inkMuted.withValues(alpha: 0.12);
      statusFg = AppColors.inkMuted;
      statusText = 'Skipped';
      statusIcon = Icons.remove_circle_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Native clean Dosey medicine illustration
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              _imageForForm(dose.form),
              fit: BoxFit.contain,
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicineName,
                  style: AppTextStyles.bodyOnLight.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSpacing.fontSm,
                  ),
                ),
                Text(
                  dose.dosage ?? '1 Dose',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: AppSpacing.fontXs,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dose.time,
                style: AppTextStyles.bodyOnLight.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.fontSm,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 10, color: statusFg),
                    const SizedBox(width: 3),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusFg,
                        fontSize: 10.5,
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 40,
            color: AppColors.inkMuted,
          ),
          AppSpacing.gapMd,
          Text(
            'No Shared Doses Found Today',
            style: AppTextStyles.headlineOnLight.copyWith(
              fontSize: AppSpacing.fontMd,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            'When ${widget.share.patientName ?? "your family member"} opens Dosey or adds reminders on their device, their schedule will appear here automatically.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
