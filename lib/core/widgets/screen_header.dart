import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Large serif page title ("Today's Medicine Reminders") with optional
/// trailing actions, as on the design's home screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: AppTextStyles.display)),
          if (trailing != null) ...[AppSpacing.gapMd, trailing!],
        ],
      ),
    );
  }
}
