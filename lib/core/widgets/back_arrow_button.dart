import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Plain back arrow (no circle). The arrow lines up with the page's left
/// edge; the touch target stays comfortably large.
class BackArrowButton extends StatelessWidget {
  const BackArrowButton({super.key, this.color, this.onPressed});

  /// Defaults to [AppColors.textOnDark].
  final Color? color;

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: MaterialLocalizations.of(context).backButtonTooltip,
      child: InkResponse(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        radius: AppSpacing.circleButton / 2,
        child: SizedBox(
          width: AppSpacing.backArrowWidth,
          height: AppSpacing.circleButton,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.arrow_back_rounded,
              size: AppSpacing.iconMd,
              color: color ?? AppColors.textOnDark,
            ),
          ),
        ),
      ),
    );
  }
}
