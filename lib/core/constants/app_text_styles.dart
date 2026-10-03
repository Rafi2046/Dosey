import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Typography: Bitter (slab serif) for display/titles, DM Sans for UI text.
/// Defaults are for dark (sage) surfaces; use `.onLight` variants on cream.
abstract final class AppTextStyles {
  static const String _display = 'Bitter';
  static const String _body = 'DMSans';

  // ── Display (Bitter) ──────────────────────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontDisplay,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontXxl,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontXl,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  // ── Body (DM Sans) ────────────────────────────────────────────────────────
  static const TextStyle subtitle = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeight,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkMuted,
    height: AppSpacing.lineHeight,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontSm,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDarkMuted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontXs,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDarkMuted,
    letterSpacing: AppSpacing.letterSpacingWide,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontSm,
    fontWeight: FontWeight.w600,
  );

  /// Bottom-navigation labels.
  static const TextStyle navLabel = TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontXs,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDarkMuted,
  );

  // ── Light-surface variants (cream cards / screens) ────────────────────────
  static final TextStyle displayOnLight = display.copyWith(
    color: AppColors.ink,
  );
  static final TextStyle titleOnLight = title.copyWith(color: AppColors.ink);
  static final TextStyle cardTitleOnLight = cardTitle.copyWith(
    color: AppColors.ink,
  );
  static final TextStyle bodyOnLight = body.copyWith(color: AppColors.inkMuted);
  static final TextStyle captionOnLight = caption.copyWith(
    color: AppColors.inkMuted,
  );
  static final TextStyle labelOnLight = caption.copyWith(
    color: AppColors.inkMuted,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle inputOnLight = body.copyWith(color: AppColors.ink);
  static final TextStyle subtitleOnLight = subtitle.copyWith(
    color: AppColors.ink,
  );
  static final TextStyle headlineOnLight = headline.copyWith(
    color: AppColors.ink,
  );

  /// Big money figure (expense totals).
  static const TextStyle amount = TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.amountFont,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static final TextStyle errorText = caption.copyWith(color: AppColors.error);
}
