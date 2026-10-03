import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Typography: Bitter (slab serif) for display/titles, DM Sans for UI text.
/// Defaults are for dark (sage) surfaces; use `.onLight` variants on cream.
abstract final class AppTextStyles {
  static const String _display = 'Bitter';
  static const String _body = 'DMSans';

  // ── Display (Bitter) ──────────────────────────────────────────────────────
  static TextStyle get display => TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontDisplay,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static TextStyle get headline => TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontXxl,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static TextStyle get title => TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontXl,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  static TextStyle get cardTitle => TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  // ── Body (DM Sans) ────────────────────────────────────────────────────────
  static TextStyle get subtitle => TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontLg,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );

  static TextStyle get body => TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeight,
  );

  static TextStyle get bodyMuted => TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontMd,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkMuted,
    height: AppSpacing.lineHeight,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontSm,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDarkMuted,
  );

  static TextStyle get overline => TextStyle(
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
  static TextStyle get navLabel => TextStyle(
    fontFamily: _body,
    fontSize: AppSpacing.fontXs,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDarkMuted,
  );

  // ── Light-surface variants (cream cards / screens) ────────────────────────
  static TextStyle get displayOnLight => display.copyWith(
    color: AppColors.ink,
  );
  static TextStyle get titleOnLight => title.copyWith(color: AppColors.ink);
  static TextStyle get cardTitleOnLight => cardTitle.copyWith(
    color: AppColors.ink,
  );
  static TextStyle get bodyOnLight => body.copyWith(color: AppColors.inkMuted);
  static TextStyle get captionOnLight => caption.copyWith(
    color: AppColors.inkMuted,
  );
  static TextStyle get labelOnLight => caption.copyWith(
    color: AppColors.inkMuted,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get inputOnLight => body.copyWith(color: AppColors.ink);
  static TextStyle get subtitleOnLight => subtitle.copyWith(
    color: AppColors.ink,
  );
  static TextStyle get headlineOnLight => headline.copyWith(
    color: AppColors.ink,
  );

  /// Big money figure (expense totals).
  static TextStyle get amount => TextStyle(
    fontFamily: _display,
    fontSize: AppSpacing.amountFont,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    height: AppSpacing.lineHeightTight,
  );

  static TextStyle get errorText => caption.copyWith(color: AppColors.error);
}
