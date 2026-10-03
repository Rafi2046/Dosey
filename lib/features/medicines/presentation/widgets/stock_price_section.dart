import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/localization/l10n.dart';

/// Price per unit (৳) and optional stock tracking.
class StockPriceSection extends StatelessWidget {
  const StockPriceSection({
    super.key,
    required this.unitPrice,
    required this.stock,
    required this.refillAt,
  });

  final TextEditingController unitPrice;
  final TextEditingController stock;
  final TextEditingController refillAt;

  static String? _optionalAmount(String? v) =>
      (v == null || v.trim().isEmpty || Money.parse(v) != null)
      ? null
      : AppLocale.l10n.invalidAmount;

  static String? _optionalNumber(String? v) =>
      (v == null || v.trim().isEmpty || (double.tryParse(v) ?? -1) >= 0)
      ? null
      : AppLocale.l10n.invalidNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField.decimal(
          label: context.l10n.medicineUnitPrice,
          controller: unitPrice,
          prefixText: AppConstants.currencySymbol,
          validator: _optionalAmount,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField.decimal(
                label: context.l10n.medicineStock,
                controller: stock,
                hint: context.l10n.optional,
                validator: _optionalNumber,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: AppTextField.decimal(
                label: context.l10n.medicineRefillAt,
                controller: refillAt,
                hint: context.l10n.optional,
                validator: _optionalNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
