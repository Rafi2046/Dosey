import 'dart:ui';

import 'package:intl/intl.dart';

import 'generated/app_localizations.dart';

/// The app's language. The user can pick English or Bengali in Settings, or
/// follow the phone (no saved choice).
///
/// Widgets get strings from `context.l10n`. Code without a BuildContext
/// (form validators, notifications built in a background isolate) uses
/// [l10n], which the app keeps in sync with the language on screen.
abstract final class AppLocale {
  /// AppSettings key holding "en" / "bn"; absent = follow the phone.
  static const String settingKey = 'locale';

  static const Locale english = Locale('en');
  static const Locale bangla = Locale('bn');

  static Locale _current = english;
  static Locale get current => _current;

  static AppLocalizations get l10n => lookupAppLocalizations(_current);

  static bool get isBangla => _current.languageCode == bangla.languageCode;

  /// Saved choice if any, else the phone's language when supported, else
  /// English.
  static Locale resolve(String? saved, Locale platform) {
    final code = saved ?? platform.languageCode;
    return code == bangla.languageCode ? bangla : english;
  }

  /// Makes [locale] current for [l10n] and for intl's date/number formats
  /// (Bengali digits in "bn").
  static void apply(Locale locale) {
    _current = locale.languageCode == bangla.languageCode ? bangla : english;
    Intl.defaultLocale = _current.languageCode;
  }
}
