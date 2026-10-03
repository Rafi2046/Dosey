import 'package:flutter/painting.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';

/// Blood pressure category of one reading, following the American Heart
/// Association's adult guide (2017), plus "low" for readings under 90/60.
/// The higher of the two numbers' categories wins.
enum BpCategory {
  low,
  normal,
  elevated,
  stage1,
  stage2,
  crisis;

  /// Valid input ranges (also enforced by the database).
  static const int systolicMin = 40;
  static const int systolicMax = 300;
  static const int diastolicMin = 20;
  static const int diastolicMax = 200;
  static const int pulseMin = 20;
  static const int pulseMax = 250;

  static BpCategory of(int systolic, int diastolic) {
    if (systolic > 180 || diastolic > 120) return crisis;
    if (systolic >= 140 || diastolic >= 90) return stage2;
    if (systolic >= 130 || diastolic >= 80) return stage1;
    if (systolic >= 120) return elevated;
    if (systolic < 90 || diastolic < 60) return low;
    return normal;
  }

  String label(AppLocalizations l) => switch (this) {
    low => l.bpLow,
    normal => l.bpNormal,
    elevated => l.bpElevated,
    stage1 => l.bpStage1,
    stage2 => l.bpStage2,
    crisis => l.bpCrisis,
  };

  /// Chip colour: calm for normal, warmer as it rises.
  Color get color => switch (this) {
    normal => AppColors.tileMint,
    low || elevated => AppColors.warning,
    stage1 || stage2 => AppColors.accent,
    crisis => AppColors.error,
  };

  Color get onColor => switch (this) {
    low || elevated => AppColors.ink,
    _ => AppColors.textOnAccent,
  };
}
