import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Small label above content ("Medicine name", "Medicine Time"...), the
/// design's pattern on cream screens.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelOnLight),
          AppSpacing.gapSm,
          child,
        ],
      ),
    );
  }
}
