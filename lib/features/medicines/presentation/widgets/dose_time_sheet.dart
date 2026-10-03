import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/amount_stepper.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../domain/dose_time.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/dose_unit.dart';
import '../../../../core/widgets/sheet_title.dart';

/// What the user did in [showDoseTimeSheet]; null when dismissed.
sealed class DoseSheetResult {
  const DoseSheetResult();
}

class DoseSaved extends DoseSheetResult {
  const DoseSaved(this.dose);
  final DoseTime dose;
}

class DoseRemoved extends DoseSheetResult {
  const DoseRemoved();
}

/// Tapping the time inside the sheet: close it, pick, then reopen.
class _PickTime {
  const _PickTime(this.dose);
  final DoseTime dose;
}

/// Bottom sheet to set one intake: its time and how many units then.
/// [canRemove] adds a "Remove this time" action (for existing times).
///
/// Only one sheet is on screen at a time: the time picker never opens over
/// this sheet. Tapping the time closes the sheet, shows the picker on its
/// own, then brings the sheet back with the new time. With [pickTimeFirst]
/// (adding a time) the picker comes first and the sheet after it.
Future<DoseSheetResult?> showDoseTimeSheet(
  BuildContext context, {
  required DoseTime initial,
  required String unit,
  bool canRemove = false,
  bool pickTimeFirst = false,
}) async {
  var dose = initial;
  if (pickTimeFirst) {
    final t = await AppPickers.time(context, initial: dose.time);
    if (t == null || !context.mounted) return null;
    dose = dose.copyWith(time: t);
  }
  while (true) {
    if (!context.mounted) return null;
    // A DoseSheetResult, a _PickTime, or null when dismissed.
    final result = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _DoseTimeSheet(initial: dose, unit: unit, canRemove: canRemove),
    );
    if (result is! _PickTime) return result as DoseSheetResult?;
    dose = result.dose;
    if (!context.mounted) return null;
    final t = await AppPickers.time(context, initial: dose.time);
    // Cancelled picker: back to the sheet with the time unchanged.
    if (t != null) dose = dose.copyWith(time: t);
  }
}

class _DoseTimeSheet extends StatefulWidget {
  const _DoseTimeSheet({
    required this.initial,
    required this.unit,
    required this.canRemove,
  });

  final DoseTime initial;
  final String unit;
  final bool canRemove;

  @override
  State<_DoseTimeSheet> createState() => _DoseTimeSheetState();
}

class _DoseTimeSheetState extends State<_DoseTimeSheet> {
  late DoseTime _dose = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(context.l10n.doseTimeTitle),
            AppSpacing.gapMd,
            PickerField(
              label: context.l10n.medicineTime,
              value: AppDateFormat.timeOfDay(_dose.time),
              icon: Icons.schedule_rounded,
              onTap: () => Navigator.pop(context, _PickTime(_dose)),
            ),
            LabeledField(
              label: context.l10n.doseHowMany,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AmountStepper(
                  value: _dose.amount,
                  suffix: DoseUnit.display(
                    widget.unit,
                    context.l10n,
                    amount: _dose.amount,
                  ),
                  onChanged: (v) =>
                      setState(() => _dose = _dose.copyWith(amount: v)),
                ),
              ),
            ),
            PillButton(
              label: context.l10n.done,
              onPressed: () => Navigator.pop(context, DoseSaved(_dose)),
            ),
            if (widget.canRemove) ...[
              AppSpacing.gapSm,
              TextButton.icon(
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(context.l10n.removeTime),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () => Navigator.pop(context, const DoseRemoved()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
