import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Large serif page title ("Today's Medicine Reminders") with optional
/// trailing actions, as on the design's home screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.style,
    this.maxLines,
    this.crossAxisAlignment,
  });

  final String title;
  final Widget? trailing;
  final TextStyle? style;
  final int? maxLines;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: style ?? AppTextStyles.display,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );

    if (maxLines == 1) {
      titleWidget = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: titleWidget,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ??
            (trailing != null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.end),
        children: [
          Expanded(child: titleWidget),
          if (trailing != null) ...[AppSpacing.gapMd, trailing!],
        ],
      ),
    );
  }
}
