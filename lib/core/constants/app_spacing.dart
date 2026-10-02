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

  // ── Radii (the design uses generous, pillowy corners) ─────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusXl = 36;
  static const double radiusPill = 999;

  // ── Icons ─────────────────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double iconXl = 40;

  // ── Component sizes ───────────────────────────────────────────────────────
  static const double buttonHeight = 58;
  static const double buttonHeightSm = 44;
  static const double circleButton = 44;
  static const double ctaIconRing = 40;
  static const double ctaIconRingWidth = 64;
  static const double chipHeight = 40;
  static const double permissionIcon = 48;
  static const double heroIllustration = 240;
  static const double alarmIllustration = 200;
  static const double logo = 96;
  static const double navBarHeight = 72;
  static const double fabSize = 64;

  // ── Effects ───────────────────────────────────────────────────────────────
  static const double borderThin = 1;
  static const double borderThick = 1.5;
  static const double elevationNone = 0;
  static const double shadowBlur = 24;
  static const Offset shadowOffset = Offset(0, 10);
  static const double disabledOpacity = 0.45;

  // ── Text ──────────────────────────────────────────────────────────────────
  static const double fontXs = 11;
  static const double fontSm = 13;
  static const double fontMd = 15;
  static const double fontLg = 17;
  static const double fontXl = 21;
  static const double fontXxl = 30;
  static const double fontDisplay = 38;
  static const double fontClock = 72;
  static const double letterSpacingWide = 0.6;
  static const double lineHeight = 1.4;
  static const double lineHeightTight = 1.12;

  // ── Motion ────────────────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 280);
  static const Duration animSlow = Duration(milliseconds: 450);
  static const Duration alarmShake = Duration(milliseconds: 900);
  static const double alarmShakeTurns = 0.012;

  // ── Common insets ─────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(xl);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets ctaPadding = EdgeInsets.only(
    left: xl,
    right: sm,
    top: sm,
    bottom: sm,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  static const EdgeInsets bottomBarPadding = EdgeInsets.fromLTRB(xl, md, xl, xl);

  // ── Gaps (use inside Row/Column) ──────────────────────────────────────────
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}
