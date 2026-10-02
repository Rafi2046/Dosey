import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'pill_button.dart';

/// Friendly placeholder with an illustration and an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.image = AppImages.alarmClock,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String image;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Opacity(
            opacity: AppSpacing.emptyIllustrationOpacity,
            child: Image.asset(image, height: AppSpacing.emptyIllustration),
          ),
          AppSpacing.gapLg,
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          if (message != null) ...[
            AppSpacing.gapSm,
            Text(
              message!,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null) ...[
            AppSpacing.gapXl,
            PillButton(
              label: actionLabel!,
              showRingChevron: true,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
