import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/selection_sheet.dart';
import '../../providers/doctors_providers.dart';

/// Picks one of the user's (non-archived) doctors, or none.
class DoctorPickerField extends ConsumerWidget {
  const DoctorPickerField({
    super.key,
    required this.label,
    required this.doctorId,
    required this.onChanged,
  });

  final String label;
  final int? doctorId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider).value ?? const [];
    final selected = doctors.where((d) => d.id == doctorId).firstOrNull;

    return PickerField(
      label: label,
      value: selected?.name,
      icon: Icons.person_search_rounded,
      onClear: () => onChanged(null),
      onTap: () async {
        final result = await showSelectionSheet(
          context: context,
          title: label,
          items: doctors,
          labelOf: (d) => d.name,
          subtitleOf: (d) => d.specialty,
          icon: Icons.person_rounded,
          selected: selected,
          allowNone: true,
        );
        if (result != null) onChanged(result.value?.id);
      },
    );
  }
}
