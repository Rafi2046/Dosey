import 'package:flutter/material.dart';

/// Thin wrappers over the Material date/time pickers with app-wide bounds.
abstract final class AppPickers {
  static final DateTime _first = DateTime(2000);
  static final DateTime _last = DateTime(2100);

  static Future<DateTime?> date(BuildContext context, {DateTime? initial}) =>
      showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: _first,
        lastDate: _last,
      );

  static Future<TimeOfDay?> time(BuildContext context, {TimeOfDay? initial}) =>
      showTimePicker(context: context, initialTime: initial ?? TimeOfDay.now());

  /// Date then time; null if either is cancelled.
  static Future<DateTime?> dateTime(
    BuildContext context, {
    DateTime? initial,
  }) async {
    final day = await date(context, initial: initial);
    if (day == null || !context.mounted) return null;
    final t = await time(
      context,
      initial: initial == null ? null : TimeOfDay.fromDateTime(initial),
    );
    if (t == null) return null;
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }
}
