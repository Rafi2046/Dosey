import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../domain/dose_time.dart';
import '../../providers/medicines_providers.dart';
import 'dose_time_sheet.dart';
import '../../../../core/localization/l10n.dart';

/// "Medicine Time" and "Days in a week" chips, driven by the medicine's
/// reminders. Each time shows its own amount; tap one to edit it, or "Add
/// time" to create a daily reminder with a time and amount.
class MedicineTimesSection extends ConsumerWidget {
  const MedicineTimesSection({super.key, required this.medicine});

  final Medicine medicine;

  Future<void> _addTime(BuildContext context, WidgetRef ref) async {
    final result = await showDoseTimeSheet(
      context,
      initial: DoseTime(TimeOfDay.now()),
      unit: medicine.doseUnit,
    );
    if (result is! DoseSaved) return;
    await ref
        .read(medicineScheduleServiceProvider)
        .addTime(
          medicine.id,
          medicine.name,
          result.dose,
          startDate: DateTime.now(),
          endDate: medicine.endDate,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders =
        ref.watch(remindersByMedicineProvider(medicine.id)).value ?? const [];
    final weekdayLabels = {
      for (final d in reminders)
        ReminderText.frequency(context.l10n, d.reminder),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: context.l10n.medicineTime,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final d in reminders)
                StatusChip(
                  label:
                      '${AppDateFormat.time(d.reminder.startAt)}'
                      '${context.l10n.notifDoseSeparator}'
                      '${ReminderText.dose(d.reminder.doseAmount ?? 1, medicine.doseUnit)}',
                  icon: d.reminder.isEnabled ? null : Icons.pause_rounded,
                  background: AppColors.sand,
                  foreground: AppColors.ink,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReminderFormScreen(existing: d.reminder),
                    ),
                  ),
                ),
              StatusChip(
                label: context.l10n.addTime,
                icon: Icons.add_alarm_rounded,
                onTap: () => _addTime(context, ref),
              ),
            ],
          ),
        ),
        if (weekdayLabels.isNotEmpty)
          LabeledField(
            label: context.l10n.daysInWeek,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final label in weekdayLabels)
                  StatusChip(
                    label: label,
                    background: AppColors.sand,
                    foreground: AppColors.ink,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
