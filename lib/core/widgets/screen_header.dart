import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Tab page header: an icon tile, a small eyebrow over a one-line serif
/// title, an optional summary line below and an optional action.
///
/// [title] may hold a line break ("Your\nMedicines"): everything before the
/// last line becomes the eyebrow ("YOUR"), the last line the title.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData? icon;

  /// Short live summary ("3 medicines"); hidden while null.
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    final eyebrow = lines.length > 1
        ? lines.take(lines.length - 1).join(' ')
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xl),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: AppSpacing.headerIconTile,
              height: AppSpacing.headerIconTile,
              decoration: BoxDecoration(
                color: AppColors.moss,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.outlineOnDark,
                  width: AppSpacing.borderThin,
                ),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconMd,
                color: AppColors.textOnDark,
              ),
            ),
            AppSpacing.gapMd,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null)
                  Text(eyebrow.toUpperCase(), style: AppTextStyles.overline),
                // One line, shrinking for long words or big fonts.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lines.last,
                    style: AppTextStyles.headline,
                    maxLines: 1,
                  ),
                ),
                if (subtitle != null)
                  Row(
                    children: [
                      Container(
                        width: AppSpacing.headerDot,
                        height: AppSpacing.headerDot,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[AppSpacing.gapMd, trailing!],
        ],
      ),
    );
  }
}
