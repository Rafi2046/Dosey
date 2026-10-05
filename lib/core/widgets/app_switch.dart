import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Compact switch scaled to [AppSpacing.switchScale] (68%), matching the
/// design's sleek toggles.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.alignment = Alignment.centerRight,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: AppSpacing.switchScale,
      alignment: alignment,
      child: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
