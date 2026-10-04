import 'package:flutter/painting.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/localization/l10n.dart';

/// Where a blood sugar reading falls, by the American Diabetes
/// Association's ranges, which depend on when it was taken (mmol/L):
/// - fasting / before a meal: in range 3.9–5.5, high 5.6–6.9, very high 7.0+
/// - after a meal (2 h), random, bedtime: in range 3.9–7.7, high 7.8–11.0,
///   very high 11.1+
/// - any time: low under 3.9, very low under 3.0 (treat right away).
enum SugarCategory {
  veryLow,
  low,
  inRange,
  high,
  veryHigh;

  static const double mmolMin = 1.0;
  static const double mmolMax = 35.0;

  /// mg/dL per mmol/L, for showing both units.
  static const double mgPerMmol = 18.0;

  static SugarCategory of(double mmol, SugarContext context) {
    if (mmol < 3.0) return veryLow;
    if (mmol < 3.9) return low;
    final fasting =
        context == SugarContext.fasting || context == SugarContext.beforeMeal;
    final (highFrom, veryHighFrom) = fasting ? (5.6, 7.0) : (7.8, 11.1);
    if (mmol >= veryHighFrom) return veryHigh;
    if (mmol >= highFrom) return high;
    return inRange;
  }

  String label(AppLocalizations l) => switch (this) {
    veryLow => l.sugarVeryLow,
    low => l.sugarLow,
    inRange => l.sugarInRange,
    high => l.sugarHigh,
    veryHigh => l.sugarVeryHigh,
  };

  Color get color => switch (this) {
    inRange => AppColors.tileMint,
    low || high => AppColors.warning,
    veryHigh => AppColors.accent,
    veryLow => AppColors.error,
  };

  Color get onColor => switch (this) {
    low || high => AppColors.ink,
    _ => AppColors.textOnAccent,
  };
}

extension SugarContextLabel on SugarContext {
  String label(AppLocalizations l) => switch (this) {
    SugarContext.fasting => l.sugarFasting,
    SugarContext.beforeMeal => l.sugarBeforeMeal,
    SugarContext.afterMeal => l.sugarAfterMeal,
    SugarContext.random => l.sugarRandom,
    SugarContext.bedtime => l.sugarBedtime,
  };
}
