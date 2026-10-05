import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/medicines/domain/course_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Medicine med({required DateTime start, DateTime? end}) => Medicine(
    profileId: 1,
    id: 1,
    name: 'Amoxicillin',
    form: MedicineForm.capsule,
    doseUnit: 'capsule',
    mealRelation: MealRelation.afterMeal,
    unitPriceMinor: 0,
    startDate: start,
    endDate: end,
    isActive: true,
    createdAt: start,
    updatedAt: start,
  );

  group('CourseLength', () {
    test('an N-day course ends on its Nth day', () {
      final start = DateTime(2026, 10, 1, 14, 30);
      expect(CourseLength.endDate(start, 7), DateTime(2026, 10, 7));
      expect(CourseLength.endDate(start, 1), DateTime(2026, 10, 1));
      expect(CourseLength.days(start, DateTime(2026, 10, 7)), 7);
    });

    test('counts calendar days across a month end and the time of day', () {
      final start = DateTime(2026, 10, 20, 23, 59);
      final end = CourseLength.endDate(start, CourseLength.month);
      expect(end, DateTime(2026, 11, 18));
      expect(CourseLength.days(start, end), 30);
    });
  });

  group('CourseProgress', () {
    final start = DateTime(2026, 10, 1, 9);
    final sevenDays = med(start: start, end: DateTime(2026, 10, 7));

    test('is null for ongoing medicines', () {
      expect(CourseProgress.of(med(start: start), DateTime(2026, 10, 3)), null);
    });

    test('day 3 of 7 with 4 days to go', () {
      final p = CourseProgress.of(sevenDays, DateTime(2026, 10, 3))!;
      expect((p.day, p.totalDays, p.daysLeft), (3, 7, 4));
      expect(p.fraction, closeTo(3 / 7, 1e-9));
      expect(p.notStarted || p.isComplete, isFalse);
    });

    test('last day, then complete', () {
      final last = CourseProgress.of(sevenDays, DateTime(2026, 10, 7))!;
      expect((last.daysLeft, last.isComplete, last.fraction), (0, false, 1));

      final after = CourseProgress.of(sevenDays, DateTime(2026, 10, 8))!;
      expect((after.daysLeft, after.isComplete), (0, true));
    });

    test('before the start date', () {
      final p = CourseProgress.of(sevenDays, DateTime(2026, 9, 30))!;
      expect((p.notStarted, p.daysLeft, p.fraction), (true, 7, 0));
    });

    test('an end date before the start is complete, not a crash', () {
      final p = CourseProgress.of(
        med(start: start, end: DateTime(2026, 9, 28)),
        DateTime(2026, 10, 1),
      )!;
      expect((p.isComplete, p.daysLeft, p.fraction), (true, 0, 1));
    });
  });
}
