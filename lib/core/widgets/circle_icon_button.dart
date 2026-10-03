import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Outlined circular icon button (the design's back button).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Defaults to [AppColors.textOnDark].
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.textOnDark;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        type: MaterialType.transparency,
        shape: CircleBorder(
          side: BorderSide(color: color, width: AppSpacing.borderThin),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSpacing.circleButton,
            child: Icon(icon, color: color),
          ),
        ),
      ),
    );
  }
}
