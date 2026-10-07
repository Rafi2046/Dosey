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
    this.subtitleMaxLines = 2,
    this.trailing,
    this.below,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final int subtitleMaxLines;
  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.22),
                          blurRadius: 5,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyOnLight.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSpacing.fontMd,
                            color: AppColors.ink,
                          ),
                        ),
                        if (subtitle case final s?) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            s,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: AppSpacing.fontSm,
                              height: 1.25,
                            ),
                            maxLines: subtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: trailing!,
                    ),
                  ],
                  if (onTap != null && trailing == null)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                    ),
                ],
              ),
              if (below != null) ...[
                const SizedBox(height: AppSpacing.md),
                below!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
