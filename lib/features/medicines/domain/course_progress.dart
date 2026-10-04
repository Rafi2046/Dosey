import '../../../core/database/app_database.dart';

/// Course lengths offered on the medicine form, in days ("1 month" = 30).
abstract final class CourseLength {
  static const List<int> presets = [3, 5, 7, 10, 14, month];
  static const int month = 30;

  /// Form choices besides [presets]: no end date, or a picked date.
  static const int ongoing = 0;
  static const int custom = -1;

  /// Last day of an N-day course starting on [start] (end dates are
  /// inclusive: a 7-day course from the 1st ends on the 7th).
  static DateTime endDate(DateTime start, int days) =>
      DateTime(start.year, start.month, start.day + days - 1);

  /// Inclusive length in days from [start] to [end], by calendar day.
  static int days(DateTime start, DateTime end) =>
      _dayIndex(end) - _dayIndex(start) + 1;

  /// Calendar day number, immune to DST (a day can be 23 or 25 hours).
  static int _dayIndex(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}

/// Where a fixed-length course stands on a given day: "Day 3 of 7".
class CourseProgress {
  const CourseProgress({required this.day, required this.totalDays});

  /// Null for ongoing medicines (no end date).
  static CourseProgress? of(Medicine m, DateTime today) {
    final end = m.endDate;
    if (end == null) return null;
    return CourseProgress(
      day: CourseLength.days(m.startDate, today),
      totalDays: CourseLength.days(m.startDate, end),
    );
  }

  /// 1 on the first day; below 1 before it starts, above [totalDays] after
  /// it ends.
  final int day;
  final int totalDays;

  bool get notStarted => day < 1;
  bool get isComplete => day > totalDays;

  /// Days still to go after today (0 on the last day).
  int get daysLeft => totalDays - day < 0 ? 0 : totalDays - day;

  /// Share of the course reached by the end of today, 0–1.
  double get fraction =>
      totalDays <= 0 ? 1 : (day / totalDays).clamp(0, 1).toDouble();
}
