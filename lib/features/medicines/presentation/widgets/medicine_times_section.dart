import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../providers/medicines_providers.dart';

/// "Medicine Time" and "Days in a week" chips, driven by the medicine's
/// reminders. Tap a time to edit it; "Add time" creates a daily reminder.
class MedicineTimesSection extends ConsumerWidget {
  const MedicineTimesSection({super.key, required this.medicine});

  final Medicine medicine;

  Future<void> _addTime(BuildContext context, WidgetRef ref) async {
    final t = await AppPickers.time(context);
    if (t == null) return;
    await ref
        .read(medicineScheduleServiceProvider)
        .addTime(
          medicine.id,
          medicine.name,
          t,
          startDate: DateTime.now(),
          endDate: medicine.endDate,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders =
        ref.watch(remindersByMedicineProvider(medicine.id)).value ?? const [];
    final weekdayLabels = {
      for (final d in reminders) ReminderText.frequency(d.reminder),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: AppStrings.medicineTime,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final d in reminders)
                StatusChip(
                  label: AppDateFormat.time(d.reminder.startAt),
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
                label: AppStrings.addTime,
                icon: Icons.add_alarm_rounded,
                onTap: () => _addTime(context, ref),
              ),
            ],
          ),
        ),
        if (weekdayLabels.isNotEmpty)
          LabeledField(
            label: AppStrings.daysInWeek,
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
