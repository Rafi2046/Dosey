import 'package:flutter/material.dart';

import '../constants/constants.dart';

enum PillButtonTone { accent, moss, cream }

/// Full-width stadium button. With [showCapsuleArrow] it renders Dosey's
/// signature "label + two-tone capsule arrow" CTA.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PillButtonTone.accent,
    this.trailingIcon,
    this.showCapsuleArrow = false,
    this.loading = false,
    this.padding,
    this.scaleDownText = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonTone tone;
  final IconData? trailingIcon;
  final bool showCapsuleArrow;
  final bool loading;
  final EdgeInsetsGeometry? padding;
  final bool scaleDownText;

  (Color, Color) get _colors => switch (tone) {
    PillButtonTone.accent => (AppColors.accent, AppColors.textOnAccent),
    PillButtonTone.moss => (AppColors.moss, AppColors.textOnDark),
    PillButtonTone.cream => (AppColors.creamLight, AppColors.ink),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    final enabled = onPressed != null && !loading;

    return AnimatedOpacity(
      duration: AppSpacing.animFast,
      opacity: enabled ? 1 : AppSpacing.disabledOpacity,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            height: AppSpacing.buttonHeight,
            child: Padding(
              padding: padding ??
                  (showCapsuleArrow
                      ? AppSpacing.ctaPadding
                      : AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox.square(
                      dimension: AppSpacing.iconMd,
                      child: CircularProgressIndicator(color: foreground),
                    )
                  else
                    Flexible(
                      child: scaleDownText
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                style: AppTextStyles.button.copyWith(
                                  color: foreground,
                                ),
                                maxLines: 1,
                              ),
                            )
                          : Text(
                              label,
                              style: AppTextStyles.button.copyWith(
                                color: foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  if (trailingIcon != null) ...[
                    AppSpacing.gapSm,
                    Icon(
                      trailingIcon,
                      color: foreground,
                      size: AppSpacing.iconMd,
                    ),
                  ],
                  if (showCapsuleArrow) ...[
                    AppSpacing.gapLg,
                    _CapsuleArrow(color: foreground, arrowColor: background),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dosey's signature CTA mark: a two-tone medicine capsule. The left half is
/// a tinted shell, the right half is solid and carries the forward arrow.
class _CapsuleArrow extends StatelessWidget {
  const _CapsuleArrow({required this.color, required this.arrowColor});

  final Color color;
  final Color arrowColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.ctaCapsuleHeight / 2),
      child: SizedBox(
        width: AppSpacing.ctaCapsuleWidth,
        height: AppSpacing.ctaCapsuleHeight,
        child: Row(
          children: [
            Expanded(
              child: ColoredBox(color: color.withValues(alpha: 0.28)),
            ),
            const SizedBox(width: AppSpacing.borderThick),
            Expanded(
              child: ColoredBox(
                color: color,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: arrowColor,
                  size: AppSpacing.iconSm + 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
