import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../medicines/presentation/widgets/course_progress_pill.dart';
import '../../../reminders/domain/reminder_with_details.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../../../core/localization/l10n.dart';

/// "⚠ Previous dose missed" when this medicine has an earlier dose from
/// today or yesterday that was missed and not since marked as taken late.
/// Nothing otherwise (and nothing for appointments, tests…).
class PreviousMissedChip extends ConsumerWidget {
  const PreviousMissedChip({
    super.key,
    required this.details,
    required this.scheduledFor,
  });

  final ReminderWithDetails details;

  /// The dose ringing now; only doses before it count as "previous".
  final DateTime scheduledFor;

  /// Whether [details]'s medicine has a missed dose before [scheduledFor].
  static bool appliesTo(
    WidgetRef ref,
    ReminderWithDetails details,
    DateTime scheduledFor,
  ) {
    final medicineId = details.reminder.medicineId;
    if (medicineId == null) return false;
    return ref
            .watch(medicinesMissedBeforeProvider(scheduledFor))
            .value
            ?.contains(medicineId) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!appliesTo(ref, details, scheduledFor)) return const SizedBox.shrink();

    return StatusChip(
      label: context.l10n.alarmPreviousMissed,
      // A soft orange tint rather than a solid fill: a hint, not an alarm.
      background: AppColors.accent.withValues(alpha: AppSpacing.badgeOpacity),
      foreground: AppColors.ink,
      leading: const Icon(
        Icons.warning_amber_rounded,
        size: AppSpacing.iconSm,
        color: AppColors.accent,
      ),
    );
  }
}

/// Course progress and missed-dose warning for one medicine of a grouped
/// alarm, on one wrapping line under its dose. Empty when neither applies.
class AlarmDoseContext extends ConsumerWidget {
  const AlarmDoseContext({
    super.key,
    required this.details,
    required this.scheduledFor,
  });

  final ReminderWithDetails details;
  final DateTime scheduledFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = details.medicine;
    final course = medicine != null && medicine.endDate != null;
    final missed = PreviousMissedChip.appliesTo(ref, details, scheduledFor);
    if (!course && !missed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          if (course)
            CourseProgressPill(
              medicine: medicine,
              today: DateUtils.dateOnly(scheduledFor),
              onLight: true,
              muted: true,
              compact: true,
            ),
          if (missed)
            PreviousMissedChip(details: details, scheduledFor: scheduledFor),
        ],
      ),
    );
  }
}
