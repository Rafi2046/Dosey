import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/choice_pills.dart';
import 'medicine_type_tile.dart';
import '../../../../core/localization/l10n.dart';

/// The design's 2×2 grid (Tablet, Capsule, Injection, Other). Choosing
/// "Other" reveals the less common forms as pills.
class MedicineTypeGrid extends StatelessWidget {
  const MedicineTypeGrid({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MedicineForm value;
  final ValueChanged<MedicineForm> onChanged;

  static const List<MedicineForm> _primary = [
    MedicineForm.tablet,
    MedicineForm.capsule,
    MedicineForm.injection,
  ];

  static const List<MedicineForm> _others = [
    MedicineForm.syrup,
    MedicineForm.drops,
    MedicineForm.inhaler,
    MedicineForm.cream,
    MedicineForm.other,
  ];

  // Tile colors follow the reference: olive, mint, cream, moss.
  static const List<Color> _colors = [
    AppColors.olive,
    AppColors.mint,
    AppColors.cream,
    AppColors.moss,
  ];

  bool get _isOther => !_primary.contains(value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
          children: [
            for (final (i, form) in _primary.indexed)
              MedicineTypeTile(
                label: form.label(context.l10n),
                image: form.image,
                color: _colors[i],
                selected: value == form,
                onTap: () => onChanged(form),
              ),
            MedicineTypeTile(
              label: MedicineForm.other.label(context.l10n),
              image: AppImages.medOther,
              color: _colors.last,
              selected: _isOther,
              onTap: () => onChanged(MedicineForm.other),
            ),
          ],
        ),
        if (_isOther) ...[
          AppSpacing.gapXl,
          ChoicePills<MedicineForm>(
            onDark: true,
            options: _others,
            selected: {value},
            labelOf: (f) => f.label(context.l10n),
            onChanged: (s) => onChanged(s.single),
          ),
        ],
      ],
    );
  }
}
