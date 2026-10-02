import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Outlined circular icon button (the design's back button).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.textOnDark,
    this.tooltip,
  });

  /// Back button that pops the current route.
  factory CircleIconButton.back(BuildContext context, {Color? color}) =>
      CircleIconButton(
        icon: Icons.chevron_left_rounded,
        color: color ?? AppColors.textOnDark,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
      );

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
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
