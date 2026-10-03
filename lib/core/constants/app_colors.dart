import 'package:flutter/material.dart';

/// Every color used in the app, sampled from docs/design/ui_design_ideas.png.
/// Widgets must never declare a `Color(...)` inline.
abstract final class AppColors {
  // ── Brand surfaces ────────────────────────────────────────────────────────
  /// Main sage background.
  static const Color sage = Color(0xFF687163);

  /// [sage] at zero opacity, for fades into the background.
  static const Color sageTransparent = Color(0x00687163);

  /// Card tones used for stacked reminder cards and medicine-type tiles.
  static const Color olive = Color(0xFF728268);
  static const Color mint = Color(0xFF64AA93);
  static const Color stone = Color(0xFF6E6D65);
  static const Color moss = Color(0xFF50594E);
  static const Color cream = Color(0xFFE6E3D3);
  static const Color creamLight = Color(0xFFF2F0E4);

  /// Chip fill on cream surfaces.
  static const Color sand = Color(0xFFC9C5B0);

  /// Rotating palette for stacked cards (olive → mint → stone → cream).
  static const List<Color> cardCycle = [olive, mint, stone, cream];

  /// Same idea for tiles placed ON a cream surface (no cream tile).
  static const List<Color> cardCycleOnLight = [olive, mint, stone, moss];

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFD572F);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// On sage / dark cards.
  static const Color textOnDark = Color(0xFFEEEBDD);
  static const Color textOnDarkMuted = Color(0xFFC6C9BC);

  /// On cream / light cards.
  static const Color ink = Color(0xFF1B1D1A);
  static const Color inkMuted = Color(0xFF4A4B45);

  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF2B84B);
  static const Color error = Color(0xFFE5484D);

  // ── Reminder type accents ─────────────────────────────────────────────────
  static const Color medicine = mint;
  static const Color appointment = olive;
  static const Color vaccine = stone;
  static const Color medicalTest = accent;

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);
  static const Color outlineOnDark = Color(0x66EEEBDD);
  static const Color divider = Color(0x1F1B1D1A);
  static const Color shadow = Color(0x40000000);
  static const Color scrim = Color(0x99000000);
}
