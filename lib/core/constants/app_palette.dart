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

  /// Calm teal-blue: soft lagoon surfaces, misty light panels, deep
  /// blue-slate text. Same lightness steps as before, gentler hues.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    sage: Color(0xFF5B727A),
    olive: Color(0xFF60828E),
    mint: Color(0xFF62A8A5),
    stone: Color(0xFF676E73),
    moss: Color(0xFF445A62),
    cream: Color(0xFFDBE5E7),
    creamLight: Color(0xFFE8F2F4),
    sand: Color(0xFFBDC6C9),
    textOnDark: Color(0xFFE3EDEF),
    textOnDarkMuted: Color(0xFFC0C9CC),
    ink: Color(0xFF191D1F),
    inkMuted: Color(0xFF454C4E),
    outlineOnDark: Color(0x66E3EDEF),
    divider: Color(0x1F191D1F),
    shadow: Color(0x40000000),
    scrim: Color(0x99000000),
    selected: Color(0xFF445A62),
    onSelected: Color(0xFFE3EDEF),
    highlight: Color(0xFFDBE5E7),
    onHighlight: Color(0xFF191D1F),
  );

  /// Night version: deep blue-charcoal, same hues, mist text.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    sage: Color(0xFF141919),
    olive: Color(0xFF21363C),
    mint: Color(0xFF326F6D),
    stone: Color(0xFF2F3638),
    moss: Color(0xFF202A2F),
    cream: Color(0xFF1B2323),
    creamLight: Color(0xFF263033),
    sand: Color(0xFF344347),
    textOnDark: Color(0xFFE3EDEF),
    textOnDarkMuted: Color(0xFFA4AEB0),
    ink: Color(0xFFE1EBED),
    inkMuted: Color(0xFFA9B2B4),
    outlineOnDark: Color(0x55E3EDEF),
    divider: Color(0x24E3EDEF),
    shadow: Color(0x80000000),
    scrim: Color(0xB3000000),
    // Pale aqua so "selected" reads brighter than the dark surfaces.
    selected: Color(0xFFD2E6E4),
    onSelected: Color(0xFF12201F),
    highlight: Color(0xFFD2E6E4),
    onHighlight: Color(0xFF12201F),
  );
}
