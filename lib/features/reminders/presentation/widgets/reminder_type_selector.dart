import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';

class ReminderTypeSelector extends StatelessWidget {
  const ReminderTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ReminderType value;
  final ValueChanged<ReminderType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: ReminderStrings.reminderType,
      child: ChoicePills<ReminderType>(
        options: ReminderType.values,
        selected: {value},
        labelOf: (t) => t.label,
        iconOf: (t) => t.icon,
        onChanged: (s) => onChanged(s.single),
      ),
    );
  }
}
