import 'package:flutter/material.dart';

import '../constants/constants.dart';

enum PillButtonTone { accent, moss, cream }

/// Full-width stadium button. With [showRingChevron] it renders the design's
/// signature "label + outlined ring with chevron" CTA.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PillButtonTone.accent,
    this.trailingIcon,
    this.showRingChevron = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonTone tone;
  final IconData? trailingIcon;
  final bool showRingChevron;
  final bool loading;

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
              padding: showRingChevron
                  ? AppSpacing.ctaPadding
                  : AppSpacing.screenPadding,
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
                      child: Text(
                        label,
                        style: AppTextStyles.button.copyWith(color: foreground),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (trailingIcon != null) ...[
                    AppSpacing.gapMd,
                    Icon(trailingIcon, color: foreground),
                  ],
                  if (showRingChevron) ...[
                    AppSpacing.gapLg,
                    _RingChevron(color: foreground),
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

class _RingChevron extends StatelessWidget {
  const _RingChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.ctaIconRingWidth,
      height: AppSpacing.ctaIconRing,
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: color, width: AppSpacing.borderThick),
        ),
      ),
      child: Icon(Icons.chevron_right_rounded, color: color),
    );
  }
}
