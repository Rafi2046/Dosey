import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Dose amount + unit side by side, then "when to take" pills.
class DoseSection extends StatelessWidget {
  const DoseSection({
    super.key,
    required this.amount,
    required this.unit,
    required this.meal,
    required this.onMealChanged,
  });

  final TextEditingController amount;
  final TextEditingController unit;
  final MealRelation meal;
  final ValueChanged<MealRelation> onMealChanged;

  static String? _positive(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || n <= 0 ? ErrorStrings.invalidNumber : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField.decimal(
                label: MedicineStrings.medicineDose,
                controller: amount,
                validator: _positive,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: AppTextField(
                label: MedicineStrings.medicineDoseUnit,
                controller: unit,
                validator: AppTextField.required,
                textCapitalization: TextCapitalization.none,
              ),
            ),
          ],
        ),
        LabeledField(
          label: MedicineStrings.medicineMeal,
          child: ChoicePills<MealRelation>(
            options: MealRelation.values,
            selected: {meal},
            labelOf: (m) => m.label,
            onChanged: (s) => onMealChanged(s.single),
          ),
        ),
      ],
    );
  }
}
