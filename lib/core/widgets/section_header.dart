import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Section title with an optional "See all"-style action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.onLight = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Use dark text (for cream screens).
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final style = onLight
        ? AppTextStyles.cardTitleOnLight
        : AppTextStyles.cardTitle;
    final actionColor = onLight
        ? AppColors.inkMuted
        : AppColors.textOnDarkMuted;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: style)),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: actionColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!, style: AppTextStyles.chip),
            ),
        ],
      ),
    );
  }
}
