import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Every color used in the app. Widgets must never declare a `Color(...)`
/// inline.
///
/// Theme-dependent colors are getters on the active [AppPalette] (light or
/// dark, switched in Settings); brand and status colors are constant.
abstract final class AppColors {
  static AppPalette _palette = AppPalette.light;
  static AppPalette get palette => _palette;
  static bool get isDark => _palette.brightness == Brightness.dark;

  /// Makes [palette] active. Returns whether it changed (the app then
  /// rebuilds so every widget picks up the new colors).
  static bool apply(AppPalette palette) {
    if (identical(palette, _palette)) return false;
    _palette = palette;
    return true;
  }

  // ── Brand surfaces ────────────────────────────────────────────────────────
  /// Main background.
  static Color get sage => _palette.sage;

  /// [sage] at zero opacity, for fades into the background.
  static Color get sageTransparent => _palette.sage.withValues(alpha: 0);

  /// Card tones used for stacked reminder cards and medicine-type tiles.
  static Color get olive => _palette.olive;
  static Color get mint => _palette.mint;
  static Color get stone => _palette.stone;
  static Color get moss => _palette.moss;
  static Color get cream => _palette.cream;
  static Color get creamLight => _palette.creamLight;

  /// Chip fill on cream surfaces.
  static Color get sand => _palette.sand;

  /// Rotating palette for stacked cards (olive → mint → stone → cream).
  static List<Color> get cardCycle => [olive, mint, stone, cream];

  /// Same idea for tiles placed ON a cream surface (no cream tile).
  static List<Color> get cardCycleOnLight => [olive, mint, stone, moss];

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFD572F);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// On sage / dark cards.
  static Color get textOnDark => _palette.textOnDark;
  static Color get textOnDarkMuted => _palette.textOnDarkMuted;

  /// On cream / light cards.
  static Color get ink => _palette.ink;
  static Color get inkMuted => _palette.inkMuted;

  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF2B84B);
  static const Color error = Color(0xFFE5484D);

  // ── Reminder type accents ─────────────────────────────────────────────────
  static Color get medicine => mint;
  static Color get appointment => olive;
  static Color get vaccine => stone;
  static const Color medicalTest = accent;

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);
  static Color get outlineOnDark => _palette.outlineOnDark;
  static Color get divider => _palette.divider;
  static Color get shadow => _palette.shadow;
  static Color get scrim => _palette.scrim;

  // ── Selection ─────────────────────────────────────────────────────────────
  static Color get selected => _palette.selected;
  static Color get onSelected => _palette.onSelected;
  static Color get highlight => _palette.highlight;
  static Color get onHighlight => _palette.onHighlight;

  // ── Icon tiles ────────────────────────────────────────────────────────────
  /// Mid-tone fills for small icon tiles: the light-mode card colors, which
  /// read well on both light and dark surfaces.
  static const Color tileMint = Color(0xFF64AA93);
  static const Color tileOlive = Color(0xFF728268);
  static const Color tileStone = Color(0xFF7E7D74);
  static const Color tileMoss = Color(0xFF50594E);
}
