import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;

/// Flutter's Bengali Material strings, but with 12-hour time (AM/PM).
///
/// The stock Bengali localization uses a 24-hour clock, so the time picker
/// showed a 0–23 dial even though the rest of Dosey writes "08:00 pm". For
/// medicine times, morning vs night has to be obvious.
class BanglaTwelveHourMaterialLocalizations extends MaterialLocalizationBn {
  const BanglaTwelveHourMaterialLocalizations({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  /// Put first in `localizationsDelegates`: the first delegate of a type
  /// that supports the locale wins over GlobalMaterialLocalizations.
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _Delegate();

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.h_colon_mm_space_a;
}

class _Delegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _Delegate();

  static const String _bn = 'bn';

  @override
  bool isSupported(Locale locale) => locale.languageCode == _bn;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // Same formats GlobalMaterialLocalizations builds for Bengali.
    initializeDateFormatting(_bn);
    return SynchronousFuture(
      BanglaTwelveHourMaterialLocalizations(
        fullYearFormat: intl.DateFormat.y(_bn),
        compactDateFormat: intl.DateFormat.yMd(_bn),
        shortDateFormat: intl.DateFormat.yMMMd(_bn),
        mediumDateFormat: intl.DateFormat.MMMEd(_bn),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(_bn),
        yearMonthFormat: intl.DateFormat.yMMMM(_bn),
        shortMonthDayFormat: intl.DateFormat.MMMd(_bn),
        decimalFormat: intl.NumberFormat.decimalPattern(_bn),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', _bn),
      ),
    );
  }

  @override
  bool shouldReload(_Delegate old) => false;
}
