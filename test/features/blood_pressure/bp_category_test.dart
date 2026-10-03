import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/blood_pressure/domain/bp_category.dart';
import 'package:dosey/features/blood_pressure/presentation/blood_pressure_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('categories follow the AHA bands; the higher number wins', () {
    expect(BpCategory.of(85, 55), BpCategory.low);
    expect(BpCategory.of(115, 75), BpCategory.normal);
    expect(BpCategory.of(119, 79), BpCategory.normal);
    expect(BpCategory.of(120, 79), BpCategory.elevated);
    expect(BpCategory.of(129, 70), BpCategory.elevated);
    expect(BpCategory.of(130, 70), BpCategory.stage1);
    expect(BpCategory.of(118, 80), BpCategory.stage1); // lower number decides
    expect(BpCategory.of(139, 89), BpCategory.stage1);
    expect(BpCategory.of(140, 70), BpCategory.stage2);
    expect(BpCategory.of(125, 90), BpCategory.stage2);
    expect(BpCategory.of(180, 120), BpCategory.stage2);
    expect(BpCategory.of(181, 100), BpCategory.crisis);
    expect(BpCategory.of(150, 121), BpCategory.crisis);
  });

  test('the 7-day average needs two readings in the last week', () {
    final now = DateTime(2026, 10, 10, 12);
    BloodPressureReading r(int sys, int dia, DateTime at) =>
        BloodPressureReading(
          id: sys,
          systolic: sys,
          diastolic: dia,
          measuredAt: at,
          createdAt: at,
        );
    final week = [
      r(130, 85, DateTime(2026, 10, 9)),
      r(120, 80, DateTime(2026, 10, 5)),
      r(170, 100, DateTime(2026, 9, 20)), // older than a week: ignored
    ];
    expect(BloodPressureScreen.weekAverage(week, now), (125, 83));
    expect(BloodPressureScreen.weekAverage(week.take(1).toList(), now), isNull);
  });
}
