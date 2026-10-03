import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../utils/numbers.dart';

/// "−  1½  +" stepper for dose amounts, in half steps (½ tablet is common).
class AmountStepper extends StatelessWidget {
  const AmountStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.suffix,
  });

  static const double step = 0.5;
  static const double min = 0.5;
  static const double max = 20;

  final double value;
  final String? suffix;
  final ValueChanged<double> onChanged;

  /// 1.0 → "1", 1.5 → "1½", 0.5 → "½".
  static String format(double v) {
    final whole = v.truncate();
    final half = v - whole >= step;
    final digits = AppNumber.format(whole);
    if (!half) return digits;
    return whole == 0 ? '½' : '$digits½';
  }

  @override
  Widget build(BuildContext context) {
    final label = format(value);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AppColors.creamLight,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_rounded, color: AppColors.ink),
            onPressed: value > min ? () => onChanged(value - step) : null,
          ),
          Text(
            suffix == null ? label : '$label $suffix',
            style: AppTextStyles.inputOnLight,
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.ink),
            onPressed: value < max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}
