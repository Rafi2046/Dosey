import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'labeled_field.dart';

/// Read-only "label above value" block for cream detail screens, e.g.
/// "Medicine name / Insulin" in the design.
class InfoBlock extends StatelessWidget {
  const InfoBlock({
    super.key,
    required this.label,
    required this.value,
    this.large = false,
  });

  final String label;
  final String value;

  /// Use the big serif style (the screen's main subject).
  final bool large;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: Text(
        value,
        style: large ? AppTextStyles.displayOnLight : AppTextStyles.bodyOnLight,
      ),
    );
  }
}
