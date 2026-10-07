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

  /// Calming Herbal Sage: natural eucalyptus, soft therapeutic sage,
  /// gentle porcelain cream panels, and deep forest charcoal text.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    sage: Color(0xFF536B5E),
    olive: Color(0xFF5C7B6D),
    mint: Color(0xFF5BA88C),
    stone: Color(0xFF69756F),
    moss: Color(0xFF3E5649),
    cream: Color(0xFFE9EFEA),
    creamLight: Color(0xFFF4F7F4),
    sand: Color(0xFFD3DFD8),
    textOnDark: Color(0xFFEDF3EE),
    textOnDarkMuted: Color(0xFFBDCCC2),
    ink: Color(0xFF1B241F),
    inkMuted: Color(0xFF4B5E53),
    outlineOnDark: Color(0x59EDF3EE),
    divider: Color(0x1A1B241F),
    shadow: Color(0x33000000),
    scrim: Color(0x80000000),
    selected: Color(0xFF3E5649),
    onSelected: Color(0xFFEDF3EE),
    highlight: Color(0xFFE9EFEA),
    onHighlight: Color(0xFF1B241F),
  );

  /// Night version: deep forest obsidian, tranquil herbal hues, and soft porcelain text.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    sage: Color(0xFF121815),
    olive: Color(0xFF223028),
    mint: Color(0xFF2D5446),
    stone: Color(0xFF29332D),
    moss: Color(0xFF1A251F),
    cream: Color(0xFF171E1A),
    creamLight: Color(0xFF202A24),
    sand: Color(0xFF2D3A32),
    textOnDark: Color(0xFFEDF3EE),
    textOnDarkMuted: Color(0xFF9DB0A4),
    ink: Color(0xFFE8EFEA),
    inkMuted: Color(0xFFA3B5AA),
    outlineOnDark: Color(0x4DEDF3EE),
    divider: Color(0x20EDF3EE),
    shadow: Color(0x80000000),
    scrim: Color(0xB3000000),
    // Soft luminous mint so "selected" is soothing yet clear on dark surfaces.
    selected: Color(0xFF7CD4B4),
    onSelected: Color(0xFF0E1A14),
    highlight: Color(0xFF7CD4B4),
    onHighlight: Color(0xFF0E1A14),
  );
}
