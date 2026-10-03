import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Small label above content ("Medicine name", "Medicine Time"...), the
/// design's pattern on cream screens.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.bottomGap = AppSpacing.fieldGap,
  });

  final String label;
  final Widget child;

  /// Space below; smaller when something closely related follows.
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
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
