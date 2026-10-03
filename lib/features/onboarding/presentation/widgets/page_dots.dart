import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';

/// "● ━ ●" progress dots; the current page is a wider pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.onboardingStep(current + 1, count),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppSpacing.animMedium,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: i == current
                  ? AppSpacing.pageDotActive
                  : AppSpacing.pageDot,
              height: AppSpacing.pageDot,
              decoration: BoxDecoration(
                color: i == current
                    ? AppColors.accent
                    : AppColors.outlineOnDark,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
        ],
      ),
    );
  }
}
