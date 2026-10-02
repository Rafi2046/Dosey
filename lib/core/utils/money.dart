import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formatting/parsing for amounts stored as minor units (poisha).
abstract final class Money {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  static final NumberFormat _plain = NumberFormat.decimalPatternDigits(
    locale: AppConstants.currencyLocale,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  /// 125050 → "৳1,250.50"
  static String format(int minor) =>
      _currency.format(minor / AppConstants.minorUnitsPerMajor);

  /// 125050 → "1,250.50" (for input fields).
  static String formatPlain(int minor) =>
      _plain.format(minor / AppConstants.minorUnitsPerMajor);

  /// "1,250.5" / "৳ 1250.50" → 125050. Returns null for invalid or negative input.
  static int? parse(String input) {
    final cleaned = input
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .trim();
    final value = double.tryParse(cleaned);
    if (value == null || value < 0 || !value.isFinite) return null;
    return (value * AppConstants.minorUnitsPerMajor).round();
  }
}
