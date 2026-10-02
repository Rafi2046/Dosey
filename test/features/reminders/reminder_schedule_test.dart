import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/reminders/domain/reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-10-05 is a Monday.
  final start = DateTime(2026, 10, 5, 8, 30);

  DateTime? next(
    RepeatRule rule,
    DateTime after, {
    int? interval,
    int? mask,
    DateTime? endAt,
  }) => ReminderSchedule.nextOccurrence(
    rule: rule,
    startAt: start,
    after: after,
    repeatInterval: interval,
    weekdaysMask: mask,
    endAt: endAt,
  );

  group('once', () {
    test('returns start when in the future, null after', () {
      expect(next(RepeatRule.once, DateTime(2026, 10, 1)), start);
      expect(next(RepeatRule.once, start), isNull);
    });

    test('truncates to the minute', () {
      final r = ReminderSchedule.nextOccurrence(
        rule: RepeatRule.once,
        startAt: DateTime(2026, 10, 5, 8, 30, 42, 123),
        after: DateTime(2026),
      );
      expect(r, DateTime(2026, 10, 5, 8, 30));
    });
  });

  group('daily', () {
    test('before start → start', () {
      expect(next(RepeatRule.daily, DateTime(2026, 9, 1)), start);
    });
    test('same day earlier → today; later → tomorrow', () {
      expect(
        next(RepeatRule.daily, DateTime(2026, 10, 7, 7)),
        DateTime(2026, 10, 7, 8, 30),
      );
      expect(
        next(RepeatRule.daily, DateTime(2026, 10, 7, 8, 30)),
        DateTime(2026, 10, 8, 8, 30),
      );
    });
    test('respects endAt', () {
      expect(
        next(
          RepeatRule.daily,
          DateTime(2026, 10, 9, 9),
          endAt: DateTime(2026, 10, 10),
        ),
        isNull,
      );
    });
    test('crosses month and year boundaries', () {
      expect(
        next(RepeatRule.daily, DateTime(2026, 12, 31, 23)),
        DateTime(2027, 1, 1, 8, 30),
      );
    });
  });

  group('everyNDays', () {
    test('every 3 days lands on start + 3k', () {
      expect(
        next(RepeatRule.everyNDays, DateTime(2026, 10, 6), interval: 3),
        DateTime(2026, 10, 8, 8, 30),
      );
      expect(
        next(RepeatRule.everyNDays, DateTime(2026, 10, 8, 9), interval: 3),
        DateTime(2026, 10, 11, 8, 30),
      );
    });
  });

  group('weekly', () {
    const monWedFri = 1 | 4 | 16;
    test('picks next enabled weekday', () {
      // Tue → Wed
      expect(
        next(RepeatRule.weekly, DateTime(2026, 10, 6, 12), mask: monWedFri),
        DateTime(2026, 10, 7, 8, 30),
      );
      // Fri after time → Mon next week
      expect(
        next(RepeatRule.weekly, DateTime(2026, 10, 9, 9), mask: monWedFri),
        DateTime(2026, 10, 12, 8, 30),
      );
    });
    test('same weekday later in the day wraps a full week', () {
      const mondayOnly = 1;
      expect(
        next(RepeatRule.weekly, DateTime(2026, 10, 12, 9), mask: mondayOnly),
        DateTime(2026, 10, 19, 8, 30),
      );
    });
    test('does not fire before start', () {
      const sundayOnly = 64;
      expect(
        next(RepeatRule.weekly, DateTime(2026, 9, 1), mask: sundayOnly),
        DateTime(2026, 10, 11, 8, 30),
      );
    });
  });

  test('dosesPerDay', () {
    expect(ReminderSchedule.dosesPerDay(RepeatRule.once), 0);
    expect(ReminderSchedule.dosesPerDay(RepeatRule.daily), 1);
    expect(
      ReminderSchedule.dosesPerDay(RepeatRule.everyNDays, repeatInterval: 2),
      0.5,
    );
    expect(
      ReminderSchedule.dosesPerDay(RepeatRule.weekly, weekdaysMask: 127),
      1,
    );
    expect(
      ReminderSchedule.dosesPerDay(RepeatRule.weekly, weekdaysMask: 1 | 4),
      2 / 7,
    );
  });
}
