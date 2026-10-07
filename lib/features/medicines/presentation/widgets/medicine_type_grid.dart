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

  bool get _isOther => !_primary.contains(value);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600 || screenSize.width >= 600;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: isTablet ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.lg,
          crossAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.lg,
          childAspectRatio: isTablet ? 0.95 : AppSpacing.medTypeAspect,
          children: [
            for (final form in _primary)
              MedicineTypeTile(
                label: form.label(context.l10n),
                image: form.image,
                color: AppColors.olive,
                selected: value == form,
                onTap: () => onChanged(form),
              ),
            MedicineTypeTile(
              label: MedicineForm.other.label(context.l10n),
              image: AppImages.medOther,
              color: AppColors.olive,
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
