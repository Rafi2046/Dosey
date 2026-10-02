import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/scheduled_occurrence.dart';

/// Quick "Medicine Taken" / "Skip" for one of today's occurrences — the same
/// engine path as the alarm screen, so stock and history stay consistent.
Future<void> showOccurrenceActions(
  BuildContext context,
  ScheduledOccurrence occurrence,
) => showModalBottomSheet<void>(
  context: context,
  builder: (_) => _OccurrenceSheet(occurrence: occurrence),
);

class _OccurrenceSheet extends ConsumerWidget {
  const _OccurrenceSheet({required this.occurrence});

  final ScheduledOccurrence occurrence;

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    AlarmAction action,
  ) async {
    await ref
        .read(alarmEngineProvider)
        .handleAction(
          reminderId: occurrence.details.reminder.id,
          scheduledFor: occurrence.at,
          action: action,
        );
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = occurrence.details.reminder;
    final isMedicine = r.type == ReminderType.medicine;
    final status = occurrence.status;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.title, style: AppTextStyles.headlineOnLight),
                ),
                StatusChip(label: AppDateFormat.time(occurrence.at)),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              ReminderText.body(occurrence.details),
              style: AppTextStyles.bodyOnLight,
            ),
            if (status != null) ...[
              AppSpacing.gapMd,
              StatusChip(
                label: status.label,
                background: AppColors.sand,
                foreground: AppColors.ink,
              ),
            ],
            AppSpacing.gapXl,
            PillButton(
              label: isMedicine
                  ? AppStrings.alarmMarkTaken
                  : AppStrings.alarmDone,
              tone: PillButtonTone.moss,
              trailingIcon: Icons.check_rounded,
              onPressed: () => _act(context, ref, AlarmAction.taken),
            ),
            AppSpacing.gapMd,
            PillButton(
              label: AppStrings.skipDose,
              tone: PillButtonTone.cream,
              trailingIcon: Icons.redo_rounded,
              onPressed: () => _act(context, ref, AlarmAction.skip),
            ),
          ],
        ),
      ),
    );
  }
}
