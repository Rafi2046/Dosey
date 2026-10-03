import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/selection_sheet.dart';
import '../../providers/medicines_providers.dart';
import '../medicine_type_screen.dart';

/// Picks one of the user's medicines. If there are none (or the right one
/// is missing) it offers "Add new medicine" and selects the new one when the
/// user comes back.
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

  Future<void> _addNew(
    BuildContext context,
    WidgetRef ref,
    List<Medicine> before,
  ) async {
    final known = {for (final m in before) m.id};
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const MedicineTypeScreen()));
    if (saved != true) return;
    // The medicine just saved is the one the user wants here.
    final added = await ref.read(medicinesRepositoryProvider).newest();
    if (added != null && !known.contains(added.id)) onChanged(added.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = <Medicine>[
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
          emptyTitle: context.l10n.medicinePickerEmpty,
          emptyMessage: context.l10n.medicinePickerEmptyHint,
          addLabel: context.l10n.addNewMedicine,
          onAdd: () => _addNew(context, ref, medicines),
        );
        if (result != null) onChanged(result.value?.id);
      },
    );
  }
}
