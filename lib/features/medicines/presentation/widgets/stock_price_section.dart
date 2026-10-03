import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';

/// Price per unit, stock on hand (with a box/strip calculator) and a
/// days-based refill alert.
///
/// Stock is always kept in single units (tablets): with the pack size set,
/// "+1 box" / "+1 strip" add the right number so nobody has to multiply.
class StockPriceSection extends StatelessWidget {
  const StockPriceSection({
    super.key,
    required this.unitPrice,
    required this.stock,
    required this.unitsPerStrip,
    required this.stripsPerBox,
    required this.alertDays,
    required this.onAlertDaysChanged,
    required this.unit,
    required this.unitsPerDay,
    this.showPacks = true,
  });

  final TextEditingController unitPrice;
  final TextEditingController stock;
  final TextEditingController unitsPerStrip;
  final TextEditingController stripsPerBox;
  final int alertDays;
  final ValueChanged<int> onAlertDaysChanged;

  /// "tablet", "ml"…
  final String unit;

  /// Daily use at the current times, to show what the alert means in units.
  final double unitsPerDay;

  /// Strips and boxes only make sense for tablets and capsules.
  final bool showPacks;

  static String? _optionalAmount(String? v) =>
      (v == null || v.trim().isEmpty || Money.parse(v) != null)
      ? null
      : AppLocale.l10n.invalidAmount;

  static String? _optionalNumber(String? v) =>
      (v == null || v.trim().isEmpty || (double.tryParse(v) ?? -1) >= 0)
      ? null
      : AppLocale.l10n.invalidNumber;

  static String? _optionalCount(String? v) =>
      (v == null || v.trim().isEmpty || (int.tryParse(v) ?? 0) > 0)
      ? null
      : AppLocale.l10n.invalidNumber;

  void _addUnits(int units) {
    final current = double.tryParse(stock.text.trim()) ?? 0;
    // Latin digits: it's a text field the form parses back.
    stock.text = ReminderText.formatAmount(current + units);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([stock, unitsPerStrip, stripsPerBox]),
      builder: (context, _) {
        final perStrip = int.tryParse(unitsPerStrip.text.trim());
        final perBox = int.tryParse(stripsPerBox.text.trim());
        final hasStock = stock.text.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField.decimal(
              label: l10n.medicineUnitPrice,
              controller: unitPrice,
              prefixText: AppConstants.currencySymbol,
              validator: _optionalAmount,
            ),
            // Directly in a row (not inside another labelled group), so
            // the spacing doesn't double up.
            if (showPacks)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CountField(
                      label: l10n.unitsPerStrip(unit),
                      controller: unitsPerStrip,
                      validator: _optionalCount,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: _CountField(
                      label: l10n.stripsPerBox,
                      controller: stripsPerBox,
                      validator: _optionalCount,
                    ),
                  ),
                ],
              ),
            AppTextField.decimal(
              label: l10n.medicineStock,
              controller: stock,
              hint: l10n.optional,
              validator: _optionalNumber,
              // The +1 box / strip buttons belong right under it.
              bottomGap: showPacks && perStrip != null
                  ? AppSpacing.sm
                  : AppSpacing.fieldGap,
            ),
            if (showPacks && perStrip != null) ...[
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (perBox != null)
                    StatusChip(
                      label: l10n.addOneBox,
                      icon: Icons.inventory_2_rounded,
                      onTap: () => _addUnits(perStrip * perBox),
                    ),
                  StatusChip(
                    label: l10n.addOneStrip,
                    icon: Icons.view_agenda_rounded,
                    onTap: () => _addUnits(perStrip),
                  ),
                ],
              ),
              AppSpacing.gapLg,
            ],
            LabeledField(
              label: l10n.refillAlert,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NumberStepper(
                        value: alertDays,
                        min: 1,
                        max: AppConstants.maxRefillAlertDays,
                        onChanged: onAlertDaysChanged,
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: Text(
                          l10n.refillAlertDays(alertDays),
                          style: AppTextStyles.inputOnLight,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapSm,
                  Text(
                    !hasStock
                        ? l10n.refillAlertNeedsStock
                        : unitsPerDay > 0
                        ? l10n.refillAlertUnits(
                            AppNumber.format(unitsPerDay * alertDays),
                            unit,
                          )
                        : '',
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CountField extends StatelessWidget {
  const _CountField({
    required this.label,
    required this.controller,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => AppTextField(
    label: label,
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: validator,
  );
}
