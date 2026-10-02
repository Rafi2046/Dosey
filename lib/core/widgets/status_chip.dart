import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Small stadium label, e.g. "Required", "09:00 am", "Allowed ✓".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.background = AppColors.moss,
    this.foreground = AppColors.textOnDark,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.chipPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconSm, color: foreground),
                AppSpacing.gapXs,
              ],
              Text(label, style: AppTextStyles.chip.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
