import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/notifications/permission_service.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import 'permission_meta.dart';

/// One permission as a rounded card, styled like the design's reminder cards:
/// small label row, serif title, description, and a pill on the right.
class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.permission,
    required this.granted,
    required this.color,
    required this.onRequest,
  });

  final AppPermission permission;
  final bool granted;
  final Color color;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final light = SurfaceCard.isLight(color);
    final titleStyle = light
        ? AppTextStyles.cardTitleOnLight
        : AppTextStyles.cardTitle;
    final bodyStyle = light
        ? AppTextStyles.captionOnLight
        : AppTextStyles.caption;
    final iconColor = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;

    return SurfaceCard(
      color: color,
      elevated: true,
      onTap: granted ? null : onRequest,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      permission.icon,
                      size: AppSpacing.iconSm,
                      color: iconColor,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      permission.badge,
                      style: AppTextStyles.overline.copyWith(color: iconColor),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                Text(permission.title, style: titleStyle),
                AppSpacing.gapXs,
                Text(permission.description, style: bodyStyle),
              ],
            ),
          ),
          AppSpacing.gapMd,
          granted
              ? StatusChip(
                  label: AppStrings.allowed,
                  icon: Icons.check_rounded,
                  background: light ? AppColors.moss : AppColors.creamLight,
                  foreground: light ? AppColors.textOnDark : AppColors.ink,
                )
              : StatusChip(
                  label: AppStrings.allow,
                  background: AppColors.accent,
                  foreground: AppColors.textOnAccent,
                  onTap: onRequest,
                ),
        ],
      ),
    );
  }
}
