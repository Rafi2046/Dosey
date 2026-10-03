import 'package:flutter/material.dart';

/// The theme-dependent colors. [AppColors] reads the active palette, so
/// widgets keep writing `AppColors.cream` and get the right shade in light
/// or dark mode.
///
/// Names describe the role in the light design ("cream" = light surface,
/// "ink" = text on it). In [dark] the same roles get dark surfaces and light
/// text, so `ink on cream` stays readable in both.
@immutable
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.sage,
    required this.olive,
    required this.mint,
    required this.stone,
    required this.moss,
    required this.cream,
    required this.creamLight,
    required this.sand,
    required this.textOnDark,
    required this.textOnDarkMuted,
    required this.ink,
    required this.inkMuted,
    required this.outlineOnDark,
    required this.divider,
    required this.shadow,
    required this.scrim,
    required this.selected,
    required this.onSelected,
    required this.highlight,
    required this.onHighlight,
  });

  final Brightness brightness;

  /// Screen background.
  final Color sage;

  /// Card tones (stacked reminder cards, medicine-type tiles).
  final Color olive;
  final Color mint;
  final Color stone;
  final Color moss;

  /// Form screens and sheets, and fields/chips on them.
  final Color cream;
  final Color creamLight;
  final Color sand;

  /// Text on [sage] and the card tones.
  final Color textOnDark;
  final Color textOnDarkMuted;

  /// Text on [cream] / [creamLight].
  final Color ink;
  final Color inkMuted;

  final Color outlineOnDark;
  final Color divider;
  final Color shadow;
  final Color scrim;

  /// Selected pill / chip on a [cream] surface, and its text.
  final Color selected;
  final Color onSelected;

  /// Selected indicator on a dark surface (nav bar, pills on cards).
  final Color highlight;
  final Color onHighlight;

  /// The original design (docs/design/ui_design_ideas.png).
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    sage: Color(0xFF687163),
    olive: Color(0xFF728268),
    mint: Color(0xFF64AA93),
    stone: Color(0xFF6E6D65),
    moss: Color(0xFF50594E),
    cream: Color(0xFFE6E3D3),
    creamLight: Color(0xFFF2F0E4),
    sand: Color(0xFFC9C5B0),
    textOnDark: Color(0xFFEEEBDD),
    textOnDarkMuted: Color(0xFFC6C9BC),
    ink: Color(0xFF1B1D1A),
    inkMuted: Color(0xFF4A4B45),
    outlineOnDark: Color(0x66EEEBDD),
    divider: Color(0x1F1B1D1A),
    shadow: Color(0x40000000),
    scrim: Color(0x99000000),
    selected: Color(0xFF50594E),
    onSelected: Color(0xFFEEEBDD),
    highlight: Color(0xFFE6E3D3),
    onHighlight: Color(0xFF1B1D1A),
  );

  /// Night version: deep green-charcoal, same hues, cream text.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    sage: Color(0xFF151916),
    olive: Color(0xFF2B3628),
    mint: Color(0xFF34715E),
    stone: Color(0xFF34352F),
    moss: Color(0xFF232B24),
    cream: Color(0xFF1D231E),
    creamLight: Color(0xFF29302A),
    sand: Color(0xFF39433A),
    textOnDark: Color(0xFFEEEBDD),
    textOnDarkMuted: Color(0xFFA9AEA2),
    ink: Color(0xFFECE9DC),
    inkMuted: Color(0xFFAEB2A7),
    outlineOnDark: Color(0x55EEEBDD),
    divider: Color(0x24EEEBDD),
    shadow: Color(0x80000000),
    scrim: Color(0xB3000000),
    // Pale mint so "selected" reads brighter than the dark surfaces.
    selected: Color(0xFFD4E6DC),
    onSelected: Color(0xFF14201A),
    highlight: Color(0xFFD4E6DC),
    onHighlight: Color(0xFF14201A),
  );
}
