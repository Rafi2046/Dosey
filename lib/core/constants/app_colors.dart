import 'package:flutter/material.dart';

/// Every color used in the app. Widgets must never declare a `Color(...)` inline.
abstract final class AppColors {
  // ── Neon accents ──────────────────────────────────────────────────────────
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonCyanSoft = Color(0xFF6EF3FF);
  static const Color neonCyanDeep = Color(0xFF00A3B8);
  static const Color neonGlow = Color(0x6600E5FF);
  static const Color neonGlowFaint = Color(0x2600E5FF);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF060A14);
  static const Color backgroundMid = Color(0xFF0B1426);
  static const Color backgroundEnd = Color(0xFF071C26);
  static const Color surface = Color(0xFF0E1628);
  static const Color surfaceElevated = Color(0xFF141E33);

  static const List<Color> backgroundGradient = [
    background,
    backgroundMid,
    backgroundEnd,
  ];

  // ── Glass ─────────────────────────────────────────────────────────────────
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassFillStrong = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  static const List<Color> glassGradient = [glassFillStrong, glassFill];

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEAF6FF);
  static const Color textSecondary = Color(0xFF9DB0C8);
  static const Color textMuted = Color(0xFF5E6E85);
  static const Color textOnNeon = Color(0xFF00141A);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2EF2A2);
  static const Color warning = Color(0xFFFFC857);
  static const Color error = Color(0xFFFF5C7A);
  static const Color errorContainer = Color(0x33FF5C7A);

  // ── Reminder type accents ─────────────────────────────────────────────────
  static const Color medicine = neonCyan;
  static const Color appointment = Color(0xFFB388FF);
  static const Color vaccine = Color(0xFF2EF2A2);
  static const Color medicalTest = Color(0xFFFFC857);

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);
  static const Color scrim = Color(0xB3000000);
  static const Color divider = Color(0x1AFFFFFF);
  static const Color shadow = Color(0x66000000);
}
