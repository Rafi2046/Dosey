import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'app_locale.dart';
export 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's strings in the current language. Using it also rebuilds the
  /// widget when the language changes.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Messages that are assembled from several .arb keys.
extension L10nExtras on AppLocalizations {
  /// "45 min", "2 h", "2 h 10 min".
  String inHoursMinutes(int hours, int minutes) => hours == 0
      ? durationMinutes(minutes)
      : minutes == 0
      ? durationHours(hours)
      : durationHoursMinutes(hours, minutes);

  /// Monday first, matching the reminders' weekday bit mask.
  List<String> get weekdaysShort => [
    weekdayMon,
    weekdayTue,
    weekdayWed,
    weekdayThu,
    weekdayFri,
    weekdaySat,
    weekdaySun,
  ];
}
