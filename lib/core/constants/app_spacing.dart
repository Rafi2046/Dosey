import 'package:flutter/widgets.dart';

/// Spacing, radii, sizes and effect values. Widgets must not use raw numbers.
abstract final class AppSpacing {
  // ── Spacing scale ─────────────────────────────────────────────────────────
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusPill = 999;

  // ── Icons ─────────────────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double iconXl = 40;
  static const double iconHero = 64;

  // ── Component sizes ───────────────────────────────────────────────────────
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double avatarSm = 36;
  static const double avatarMd = 48;
  static const double avatarLg = 72;
  static const double thumbnail = 88;
  static const double logo = 96;
  static const double navBarHeight = 72;
  static const double fabSize = 60;

  // ── Glass & glow effects ──────────────────────────────────────────────────
  static const double glassBlur = 18;
  static const double borderThin = 1;
  static const double borderThick = 1.5;
  static const double glowBlur = 24;
  static const double glowSpread = 0;
  static const double elevationNone = 0;
  static const double glowOpacity = 0.35;
  static const Alignment orbTopLeft = Alignment(-1.2, -0.9);
  static const Alignment orbBottomRight = Alignment(1.3, 0.6);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const double fontXs = 11;
  static const double fontSm = 13;
  static const double fontMd = 15;
  static const double fontLg = 17;
  static const double fontXl = 20;
  static const double fontXxl = 26;
  static const double fontDisplay = 34;
  static const double letterSpacingWide = 0.6;
  static const double lineHeight = 1.35;

  // ── Durations (ms) ────────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 280);
  static const Duration animSlow = Duration(milliseconds: 450);

  // ── Common insets ─────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  // ── Gaps (use inside Row/Column) ──────────────────────────────────────────
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}
