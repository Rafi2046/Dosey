import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Tab page header: a small eyebrow over a one-line serif
/// title, an optional summary line below and an optional action.
///
/// [title] may hold a line break ("Your\nMedicines"): everything before the
/// last line becomes the eyebrow ("YOUR"), the last line the title.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        // Accent tick marking the section, like a tab label.
                        Container(
                          width: AppSpacing.headerTickWidth,
                          height: AppSpacing.headerTickHeight,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                        AppSpacing.gapSm,
                        Text(
                          eyebrow.toUpperCase(),
                          style: AppTextStyles.overline.copyWith(
                            fontSize: AppSpacing.fontSm,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
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
