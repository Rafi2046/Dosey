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
    this.compact = false,
  });

  final String title;
  final String? message;

  /// Illustration above the title; null for none.
  final String? image;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Tighter spacing and a smaller title, for a section of a longer page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Column(
        // Only as tall as its content, so a parent can centre it.
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image case final image?) ...[
            Opacity(
              opacity: AppSpacing.emptyIllustrationOpacity,
              child: Image.asset(image, height: AppSpacing.emptyIllustration),
            ),
            AppSpacing.gapLg,
          ],
          Text(
            title,
            style: compact ? AppTextStyles.cardTitle : AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            AppSpacing.gapSm,
            Text(
              message!,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null) ...[
            compact ? AppSpacing.gapLg : AppSpacing.gapXl,
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
