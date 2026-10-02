import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Typography. Use these (or `Theme.of(context).textTheme`, which maps to them)
/// instead of building `TextStyle`s in widgets.
abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: AppSpacing.fontDisplay,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle headline = TextStyle(
    fontSize: AppSpacing.fontXxl,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: AppSpacing.fontXl,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: AppSpacing.lineHeight,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: AppSpacing.lineHeight,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppSpacing.fontSm,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: AppSpacing.fontXs,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: AppSpacing.letterSpacingWide,
  );

  static const TextStyle button = TextStyle(
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w700,
    letterSpacing: AppSpacing.letterSpacingWide,
  );

  /// Big neon figures (expense totals, next-dose countdown).
  static const TextStyle neonFigure = TextStyle(
    fontSize: AppSpacing.fontDisplay,
    fontWeight: FontWeight.w800,
    color: AppColors.neonCyan,
    shadows: [
      Shadow(color: AppColors.neonGlow, blurRadius: AppSpacing.glowBlur),
    ],
  );

  static const TextStyle neonLabel = TextStyle(
    fontSize: AppSpacing.fontSm,
    fontWeight: FontWeight.w700,
    color: AppColors.neonCyan,
    letterSpacing: AppSpacing.letterSpacingWide,
  );
}
