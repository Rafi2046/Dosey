import 'package:flutter/material.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/localization/l10n.dart';

/// Dose unit, then "when to take" pills. How many units per intake is set
/// per time in [ReminderTimesEditor].
class DoseSection extends StatelessWidget {
  const DoseSection({
    super.key,
    required this.unit,
    required this.meal,
    required this.onMealChanged,
  });

  final TextEditingController unit;
  final MealRelation meal;
  final ValueChanged<MealRelation> onMealChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: context.l10n.medicineDoseUnit,
          controller: unit,
          validator: AppTextField.required,
          textCapitalization: TextCapitalization.none,
        ),
        LabeledField(
          label: context.l10n.medicineMeal,
          child: ChoicePills<MealRelation>(
            columns: 2,
            options: MealRelation.values,
            selected: {meal},
            labelOf: (m) => m.label(context.l10n),
            onChanged: (s) => onMealChanged(s.single),
          ),
        ),
      ],
    );
  }
}
