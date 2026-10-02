import '../../../core/database/app_database.dart';

/// Pure recurrence math for [Reminders]. Date arithmetic uses the
/// `DateTime(y, m, d + n, h, min)` form so wall-clock time survives DST shifts.
abstract final class ReminderSchedule {
  static const int _daysPerWeek = 7;

  /// First occurrence strictly after [after], or null if the series has ended.
  static DateTime? nextOccurrence({
    required RepeatRule rule,
    required DateTime startAt,
    required DateTime after,
    int? repeatInterval,
    int? weekdaysMask,
    DateTime? endAt,
  }) {
    final next = switch (rule) {
      RepeatRule.once => startAt.isAfter(after) ? startAt : null,
      RepeatRule.daily => _nextEveryNDays(startAt, after, 1),
      RepeatRule.everyNDays =>
        _nextEveryNDays(startAt, after, repeatInterval ?? 1),
      RepeatRule.weekly => _nextWeekly(startAt, after, weekdaysMask ?? 0),
    };
    if (next == null || (endAt != null && next.isAfter(endAt))) return null;
    return next;
  }

  /// Convenience wrapper for a stored [Reminder].
  static DateTime? nextFor(Reminder r, DateTime after) => nextOccurrence(
        rule: r.repeatRule,
        startAt: r.startAt,
        after: after,
        repeatInterval: r.repeatInterval,
        weekdaysMask: r.weekdaysMask,
        endAt: r.endAt,
      );

  /// All occurrences of [r] on the calendar day of [day], in order.
  static List<DateTime> occurrencesOn(Reminder r, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day + 1);
    final result = <DateTime>[];
    var cursor = dayStart.subtract(const Duration(microseconds: 1));
    while (true) {
      final next = nextFor(r, cursor);
      if (next == null || !next.isBefore(dayEnd)) break;
      result.add(next);
      cursor = next;
    }
    return result;
  }

  /// Average doses per day, used for projected medicine cost.
  static double dosesPerDay(RepeatRule rule, {int? repeatInterval, int? weekdaysMask}) =>
      switch (rule) {
        RepeatRule.once => 0,
        RepeatRule.daily => 1,
        RepeatRule.everyNDays => 1 / (repeatInterval ?? 1),
        RepeatRule.weekly => _bitCount(weekdaysMask ?? 0) / _daysPerWeek,
      };

  /// Bit 0 = Monday … bit 6 = Sunday (matches [DateTime.weekday] - 1).
  static bool weekdayEnabled(int mask, int weekday) =>
      mask & (1 << (weekday - 1)) != 0;

  static DateTime? _nextEveryNDays(DateTime start, DateTime after, int n) {
    if (n < 1) return null;
    if (start.isAfter(after)) return start;
    final startDay = DateTime(start.year, start.month, start.day);
    final afterDay = DateTime(after.year, after.month, after.day);
    // Calendar-day difference, robust to DST (hours / 24 rounds 23h or 25h).
    final elapsed = (afterDay.difference(startDay).inHours / 24).round();
    var k = elapsed ~/ n;
    while (true) {
      final candidate = _atDayOffset(start, k * n);
      if (candidate.isAfter(after)) return candidate;
      k++;
    }
  }

  static DateTime? _nextWeekly(DateTime start, DateTime after, int mask) {
    if (mask == 0) return null;
    final base = start.isAfter(after) ? start : after;
    // Looking 8 days ahead covers "today but earlier time" → same weekday next week.
    for (var i = 0; i <= _daysPerWeek; i++) {
      final candidate = DateTime(
        base.year, base.month, base.day + i, start.hour, start.minute, //
      );
      if (candidate.isBefore(start) || !candidate.isAfter(after)) continue;
      if (weekdayEnabled(mask, candidate.weekday)) return candidate;
    }
    return null;
  }

  static DateTime _atDayOffset(DateTime start, int days) => DateTime(
        start.year, start.month, start.day + days, start.hour, start.minute, //
      );

  static int _bitCount(int v) {
    var count = 0;
    for (var x = v; x != 0; x &= x - 1) {
      count++;
    }
    return count;
  }
}
