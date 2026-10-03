import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// One settings row: tinted icon, title, optional subtitle, and either a
/// trailing widget or a chevron when tappable. [below] holds a full-width
/// control (e.g. language pills) under the text.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.below,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.settingsIcon,
                  height: AppSpacing.settingsIcon,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.iconMd,
                    color: AppColors.textOnAccent,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.inputOnLight),
                      if (subtitle case final s?)
                        Text(s, style: AppTextStyles.captionOnLight),
                    ],
                  ),
                ),
                if (trailing != null) ...[AppSpacing.gapSm, trailing!],
                if (onTap != null && trailing == null)
                  Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
              ],
            ),
            if (below != null) ...[AppSpacing.gapMd, below!],
          ],
        ),
      ),
    );
  }
}
