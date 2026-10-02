import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/selection_sheet.dart';
import '../../providers/medicines_providers.dart';

/// Picks one of the user's active medicines.
class MedicinePickerField extends ConsumerWidget {
  const MedicinePickerField({
    super.key,
    required this.label,
    required this.medicineId,
    required this.onChanged,
    this.allowNone = true,
    this.errorText,
  });

  final String label;
  final int? medicineId;
  final ValueChanged<int?> onChanged;
  final bool allowNone;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = [
      for (final m in ref.watch(medicinesProvider).value ?? const [])
        m.medicine,
    ];
    final selected = medicines.where((m) => m.id == medicineId).firstOrNull;

    return PickerField(
      label: label,
      value: selected?.name,
      icon: Icons.medication_rounded,
      errorText: errorText,
      onClear: allowNone ? () => onChanged(null) : null,
      onTap: () async {
        final result = await showSelectionSheet(
          context: context,
          title: label,
          items: medicines,
          labelOf: (m) => m.name,
          subtitleOf: (m) => m.strength,
          icon: Icons.medication_rounded,
          selected: selected,
          allowNone: allowNone,
        );
        if (result != null) onChanged(result.value?.id);
      },
    );
  }
}
