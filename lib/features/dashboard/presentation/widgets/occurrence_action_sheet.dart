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
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../../reminders/domain/scheduled_occurrence.dart';
import '../../../../core/localization/l10n.dart';

/// Quick "Medicine Taken" / "Skip" for one of today's occurrences — the same
/// engine path as the alarm screen, so stock and history stay consistent —
/// plus "Edit this time" / "Delete this time" to fix a wrong entry here.
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
          // Just this card's medicine, even if it rang with others.
          reminderIds: [occurrence.details.reminder.id],
          scheduledFor: occurrence.at,
          action: action,
        );
    if (context.mounted) Navigator.pop(context);
  }

  void _edit(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ReminderFormScreen(existing: occurrence.details.reminder),
      ),
    );
  }

  /// Removes this one reminder time (its alarm first), after confirming.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final r = occurrence.details.reminder;
    final l10n = context.l10n;
    if (!await confirmDelete(
      context,
      body: l10n.deleteThisTimeBody(AppDateFormat.time(r.startAt), r.title),
    )) {
      return;
    }
    await ref.read(alarmEngineProvider).cancel(r.id);
    await ref.read(remindersRepositoryProvider).delete(r.id);
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
              ReminderText.body(context.l10n, occurrence.details),
              style: AppTextStyles.bodyOnLight,
            ),
            if (status != null) ...[
              AppSpacing.gapMd,
              StatusChip(
                label: status.label(context.l10n),
                background: AppColors.sand,
                foreground: AppColors.ink,
              ),
            ],
            AppSpacing.gapXl,
            PillButton(
              label: isMedicine
                  ? context.l10n.alarmMarkTaken
                  : context.l10n.alarmDone,
              tone: PillButtonTone.moss,
              trailingIcon: Icons.check_rounded,
              onPressed: () => _act(context, ref, AlarmAction.taken),
            ),
            AppSpacing.gapMd,
            PillButton(
              label: context.l10n.skipDose,
              tone: PillButtonTone.cream,
              trailingIcon: Icons.redo_rounded,
              onPressed: () => _act(context, ref, AlarmAction.skip),
            ),
            AppSpacing.gapSm,
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit_rounded),
                    label: Text(context.l10n.editThisTime),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkMuted,
                    ),
                    onPressed: () => _edit(context),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(context.l10n.deleteThisTime),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    onPressed: () => _delete(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
