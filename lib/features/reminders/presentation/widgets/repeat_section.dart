import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/picker_field.dart';

/// Repeat rule + its parameters (weekdays / interval) + optional end date.
class RepeatSection extends StatelessWidget {
  const RepeatSection({
    super.key,
    required this.rule,
    required this.weekdays,
    required this.interval,
    required this.endAt,
    required this.onRuleChanged,
    required this.onWeekdaysChanged,
    required this.onIntervalChanged,
    required this.onEndChanged,
    this.weekdaysError,
  });

  final RepeatRule rule;

  /// Indexes 0 (Mon) … 6 (Sun).
  final Set<int> weekdays;
  final int interval;
  final DateTime? endAt;
  final ValueChanged<RepeatRule> onRuleChanged;
  final ValueChanged<Set<int>> onWeekdaysChanged;
  final ValueChanged<int> onIntervalChanged;
  final ValueChanged<DateTime?> onEndChanged;
  final String? weekdaysError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: AppStrings.reminderRepeat,
          child: ChoicePills<RepeatRule>(
            options: RepeatRule.values,
            selected: {rule},
            labelOf: (r) => r.label,
            onChanged: (s) => onRuleChanged(s.single),
          ),
        ),
        if (rule == RepeatRule.weekly)
          LabeledField(
            label: AppStrings.daysInWeek,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoicePills<int>(
                  options: List.generate(
                    AppStrings.weekdaysShort.length,
                    (i) => i,
                  ),
                  selected: weekdays,
                  labelOf: (i) => AppStrings.weekdaysShort[i],
                  multiSelect: true,
                  onChanged: onWeekdaysChanged,
                ),
                if (weekdaysError != null) ...[
                  AppSpacing.gapSm,
                  Text(weekdaysError!, style: AppTextStyles.errorText),
                ],
              ],
            ),
          ),
        if (rule == RepeatRule.everyNDays)
          LabeledField(
            label: AppStrings.reminderEveryNDays,
            child: NumberStepper(
              value: interval,
              suffix: AppStrings.daysUnit,
              onChanged: onIntervalChanged,
            ),
          ),
        if (rule != RepeatRule.once)
          PickerField(
            label: AppStrings.reminderEndDate,
            value: endAt == null ? null : AppDateFormat.date(endAt!),
            placeholder: AppStrings.ongoing,
            icon: Icons.event_rounded,
            onClear: () => onEndChanged(null),
            onTap: () async {
              final picked = await AppPickers.date(context, initial: endAt);
              if (picked != null) {
                // Inclusive: the series may still fire on the end date.
                onEndChanged(
                  DateTime(picked.year, picked.month, picked.day, 23, 59),
                );
              }
            },
          ),
      ],
    );
  }
}
