import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Lower-case meridiem ("09:00 am"), as in the design.
abstract final class AppDateFormat {
  // Built per call so they follow the current language (Intl.defaultLocale):
  // "৫ অক্টো ২০২৬" in Bengali.
  static DateFormat get _time => DateFormat(AppConstants.timePattern);
  static DateFormat get _dateTime => DateFormat(AppConstants.dateTimePattern);
  static DateFormat get _date => DateFormat(AppConstants.datePattern);
  static DateFormat get _shortDate => DateFormat(AppConstants.shortDatePattern);
  static DateFormat get _month => DateFormat(AppConstants.monthPattern);

  /// "5 Oct 2026"
  static String date(DateTime value) => _date.format(value);

  /// "Mon, 5 Oct"
  static String shortDate(DateTime value) => _shortDate.format(value);

  /// "Oct" (in the current language), for chart labels.
  static String monthShort(DateTime value) => DateFormat.MMM().format(value);

  /// "October" without the year.
  static String monthName(DateTime value) => DateFormat.MMMM().format(value);

  /// "October 2026"
  static String month(DateTime value) => _month.format(value);

  static String time(DateTime value) => _lowerMeridiem(_time.format(value));

  /// A bare time of day the same way: "08:00 am", always with am/pm (so
  /// morning vs night is clear, whatever the phone's 24-hour setting).
  static String timeOfDay(TimeOfDay value) =>
      time(DateTime(2000, 1, 1, value.hour, value.minute));

  /// "Mon, 5 Oct · 09:00 am"
  static String dateTime(DateTime value) =>
      _lowerMeridiem(_dateTime.format(value));

  static String _lowerMeridiem(String s) =>
      s.replaceAll('AM', 'am').replaceAll('PM', 'pm');
}
