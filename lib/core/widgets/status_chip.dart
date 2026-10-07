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
    this.leading,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  final String label;

  /// Defaults to [AppColors.moss] / [AppColors.textOnDark].
  final Color? background;
  final Color? foreground;
  final IconData? icon;

  /// Shown before the label instead of [icon] (e.g. a progress ring).
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = this.background ?? AppColors.moss;
    final foreground = this.foreground ?? AppColors.textOnDark;
    final isTime = RegExp(r'\d{1,2}:\d{2}').hasMatch(label);
    final textStyle = isTime
        ? TextStyle(
            fontFamily: 'NDot',
            fontSize: AppSpacing.fontSm + 1.5,
            color: foreground,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w400,
          )
        : AppTextStyles.chip.copyWith(color: foreground);

    return Material(
      color: background,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? AppSpacing.chipPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading case final leading?) ...[
                leading,
                AppSpacing.gapXs,
              ] else if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconSm, color: foreground),
                AppSpacing.gapXs,
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
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
