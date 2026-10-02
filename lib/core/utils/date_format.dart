import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Lower-case meridiem ("09:00 am"), as in the design.
abstract final class AppDateFormat {
  static final DateFormat _time = DateFormat(AppConstants.timePattern);
  static final DateFormat _dateTime = DateFormat(AppConstants.dateTimePattern);

  static String time(DateTime value) => _lowerMeridiem(_time.format(value));

  /// "Mon, 5 Oct · 09:00 am"
  static String dateTime(DateTime value) =>
      _lowerMeridiem(_dateTime.format(value));

  static String _lowerMeridiem(String s) =>
      s.replaceAll('AM', 'am').replaceAll('PM', 'pm');
}
