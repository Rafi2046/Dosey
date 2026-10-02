import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';

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
      : AppStrings.invalidAmount;

  static String? _optionalNumber(String? v) =>
      (v == null || v.trim().isEmpty || (double.tryParse(v) ?? -1) >= 0)
      ? null
      : AppStrings.invalidNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField.decimal(
          label: AppStrings.medicineUnitPrice,
          controller: unitPrice,
          prefixText: AppConstants.currencySymbol,
          validator: _optionalAmount,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField.decimal(
                label: AppStrings.medicineStock,
                controller: stock,
                hint: AppStrings.optional,
                validator: _optionalNumber,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: AppTextField.decimal(
                label: AppStrings.medicineRefillAt,
                controller: refillAt,
                hint: AppStrings.optional,
                validator: _optionalNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
