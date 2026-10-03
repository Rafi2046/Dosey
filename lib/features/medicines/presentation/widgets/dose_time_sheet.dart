import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/amount_stepper.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../domain/dose_time.dart';
import '../../../../core/localization/l10n.dart';

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

/// Bottom sheet to set one intake: its time and how many units then.
/// [canRemove] adds a "Remove this time" action (for existing times).
Future<DoseSheetResult?> showDoseTimeSheet(
  BuildContext context, {
  required DoseTime initial,
  required String unit,
  bool canRemove = false,
}) => showModalBottomSheet<DoseSheetResult>(
  context: context,
  isScrollControlled: true,
  builder: (_) =>
      _DoseTimeSheet(initial: initial, unit: unit, canRemove: canRemove),
);

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
            Text(context.l10n.doseTimeTitle, style: AppTextStyles.titleOnLight),
            AppSpacing.gapMd,
            PickerField(
              label: context.l10n.medicineTime,
              value: _dose.time.format(context).toLowerCase(),
              icon: Icons.schedule_rounded,
              onTap: () async {
                final t = await AppPickers.time(context, initial: _dose.time);
                if (t != null) setState(() => _dose = _dose.copyWith(time: t));
              },
            ),
            LabeledField(
              label: context.l10n.doseHowMany,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AmountStepper(
                  value: _dose.amount,
                  suffix: widget.unit,
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
