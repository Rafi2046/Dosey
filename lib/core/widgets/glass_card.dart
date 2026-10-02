import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Frosted-glass surface: backdrop blur + translucent gradient + hairline border.
/// Set [glowColor] to add a neon halo (e.g. for the next-due reminder).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.radius = AppSpacing.radiusLg,
    this.glowColor,
    this.borderColor = AppColors.glassBorder,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? glowColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final glow = glowColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: glow == null
            ? null
            : [
                // Outer-only, so the halo doesn't tint the translucent glass.
                BoxShadow(
                  color: glow.withValues(alpha: AppSpacing.glowOpacity),
                  blurRadius: AppSpacing.glowBlur,
                  spreadRadius: AppSpacing.glowSpread,
                  blurStyle: BlurStyle.outer,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.glassBlur,
            sigmaY: AppSpacing.glassBlur,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.glassGradient,
                  ),
                  border: Border.all(
                    color: glow ?? borderColor,
                    width: AppSpacing.borderThin,
                  ),
                ),
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
