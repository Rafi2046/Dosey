import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/status_chip.dart';

/// "Medicine Time" chips (09:00 am · 07:00 pm) with an "Add time" chip.
/// Tapping a time removes it.
class ReminderTimesEditor extends StatelessWidget {
  const ReminderTimesEditor({
    super.key,
    required this.times,
    required this.onChanged,
  });

  final List<TimeOfDay> times;
  final ValueChanged<List<TimeOfDay>> onChanged;

  static int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _add(BuildContext context) async {
    final picked = await AppPickers.time(context);
    if (picked == null) return;
    if (times.any((t) => _minutes(t) == _minutes(picked))) return;
    onChanged([...times, picked]..sort((a, b) => _minutes(a) - _minutes(b)));
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: MedicineStrings.medicineTime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in times)
                StatusChip(
                  label: t.format(context).toLowerCase(),
                  icon: Icons.close_rounded,
                  background: AppColors.sand,
                  foreground: AppColors.ink,
                  onTap: () => onChanged([...times]..remove(t)),
                ),
              StatusChip(
                label: AppStrings.addTime,
                icon: Icons.add_alarm_rounded,
                onTap: () => _add(context),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            MedicineStrings.reminderTimesHint,
            style: AppTextStyles.captionOnLight,
          ),
        ],
      ),
    );
  }
}
