import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/selection_sheet.dart';
import '../../providers/records_providers.dart';
import '../../../../core/localization/l10n.dart';

/// Links a medicine to the prescription record it came from.
class PrescriptionPickerField extends ConsumerWidget {
  const PrescriptionPickerField({
    super.key,
    required this.recordId,
    required this.onChanged,
  });

  final int? recordId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = [
      for (final s in ref.watch(prescriptionsProvider).value ?? const [])
        s.record,
    ];
    final selected = records.where((r) => r.id == recordId).firstOrNull;

    return PickerField(
      label: context.l10n.prescription,
      value: selected?.title,
      placeholder: context.l10n.optional,
      icon: Icons.description_rounded,
      onClear: () => onChanged(null),
      onTap: () async {
        final result = await showSelectionSheet(
          context: context,
          title: context.l10n.prescription,
          items: records,
          labelOf: (r) => r.title,
          subtitleOf: (r) => AppDateFormat.date(r.recordDate),
          icon: Icons.description_rounded,
          selected: selected,
          allowNone: true,
        );
        if (result != null) onChanged(result.value?.id);
      },
    );
  }
}
