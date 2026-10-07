import 'package:flutter/material.dart';

import '../constants/constants.dart';

enum PillButtonTone { accent, moss, cream }

/// Full-width stadium button. With [showForwardArrow] the label is followed
/// by a gently nudging arrow, used for "continue" style CTAs.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PillButtonTone.accent,
    this.trailingIcon,
    this.showForwardArrow = false,
    this.loading = false,
    this.padding,
    this.scaleDownText = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonTone tone;
  final IconData? trailingIcon;
  final bool showForwardArrow;
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
              padding: padding ?? AppSpacing.screenPadding,
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
                  if (showForwardArrow && !loading) ...[
                    AppSpacing.gapSm,
                    _NudgeArrow(color: foreground),
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

/// Inline forward arrow that drifts a few pixels ahead now and then, hinting
/// "continue" without competing with the label. Stays still when the system
/// asks for reduced motion.
class _NudgeArrow extends StatefulWidget {
  const _NudgeArrow({required this.color});

  final Color color;

  @override
  State<_NudgeArrow> createState() => _NudgeArrowState();
}

class _NudgeArrowState extends State<_NudgeArrow>
    with SingleTickerProviderStateMixin {
  static const double _travel = 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppSpacing.nudgePeriod,
  );

  // Two quick nudges at the start of each period, then rest.
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: _travel,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 6,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: _travel,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 6,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: _travel,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 6,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: _travel,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 6,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 76),
  ]).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) =>
          Transform.translate(offset: Offset(_offset.value, 0), child: child),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: widget.color,
        size: AppSpacing.iconMd,
      ),
    );
  }
}
