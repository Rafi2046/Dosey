import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Soft, generously rounded card. Text color should follow [isLight].
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.color = AppColors.olive,
    this.padding = AppSpacing.cardPaddingLg,
    this.radius = AppSpacing.radiusLg,
    this.elevated = false,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Adds the soft drop shadow used for stacked cards.
  final bool elevated;
  final VoidCallback? onTap;

  /// Whether [color] is a light surface (cream) needing dark text.
  static bool isLight(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.light;

  /// Ink on light surfaces, cream on dark ones.
  static Color foregroundFor(Color color) =>
      isLight(color) ? AppColors.ink : AppColors.textOnDark;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppSpacing.shadowBlur,
                  offset: AppSpacing.shadowOffset,
                ),
              ]
            : null,
      ),
      child: Material(
        color: color,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
