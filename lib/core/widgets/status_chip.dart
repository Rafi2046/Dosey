import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Small stadium label, e.g. "Required", "09:00 am", "Allowed ✓".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.icon,
    this.onTap,
  });

  final String label;

  /// Defaults to [AppColors.moss] / [AppColors.textOnDark].
  final Color? background;
  final Color? foreground;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = this.background ?? AppColors.moss;
    final foreground = this.foreground ?? AppColors.textOnDark;
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
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.chip.copyWith(color: foreground),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
