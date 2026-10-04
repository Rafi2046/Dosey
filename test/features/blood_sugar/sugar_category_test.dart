import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/blood_sugar/domain/sugar_category.dart';
import 'package:dosey/features/blood_sugar/presentation/blood_sugar_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SugarCategory c(double v, SugarContext ctx) => SugarCategory.of(v, ctx);

  test('fasting and before-meal use the tighter ADA ranges', () {
    for (final ctx in [SugarContext.fasting, SugarContext.beforeMeal]) {
      expect(c(2.9, ctx), SugarCategory.veryLow);
      expect(c(3.8, ctx), SugarCategory.low);
      expect(c(3.9, ctx), SugarCategory.inRange);
      expect(c(5.5, ctx), SugarCategory.inRange);
      expect(c(5.6, ctx), SugarCategory.high);
      expect(c(6.9, ctx), SugarCategory.high);
      expect(c(7.0, ctx), SugarCategory.veryHigh);
    }
  });

  test('after a meal, random and bedtime use the wider ranges', () {
    for (final ctx in [
      SugarContext.afterMeal,
      SugarContext.random,
      SugarContext.bedtime,
    ]) {
      expect(c(7.5, ctx), SugarCategory.inRange); // high if fasting
      expect(c(7.8, ctx), SugarCategory.high);
      expect(c(11.0, ctx), SugarCategory.high);
      expect(c(11.1, ctx), SugarCategory.veryHigh);
      expect(c(3.5, ctx), SugarCategory.low);
    }
  });

  test('7-day average needs two readings in the last week', () {
    final now = DateTime(2026, 10, 10, 12);
    BloodSugarReading r(double v, DateTime at) => BloodSugarReading(
      id: at.day,
      mmol: v,
      context: SugarContext.fasting,
      measuredAt: at,
      createdAt: at,
    );
    final all = [
      r(6.0, DateTime(2026, 10, 9)),
      r(7.1, DateTime(2026, 10, 6)),
      r(15.0, DateTime(2026, 9, 1)), // too old
    ];
    expect(BloodSugarScreen.weekAverage(all, now), 6.6);
    expect(BloodSugarScreen.weekAverage(all.take(1).toList(), now), isNull);
  });
}
