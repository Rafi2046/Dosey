import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// "−  3  +" stepper on a cream pill.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 365,
    this.suffix,
  });

  final int value;
  final int min;
  final int max;
  final String? suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.creamLight,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, color: AppColors.ink),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text(
            suffix == null ? '$value' : '$value $suffix',
            style: AppTextStyles.inputOnLight,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.ink),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
