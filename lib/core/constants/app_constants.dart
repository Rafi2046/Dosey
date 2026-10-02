/// Non-visual app configuration (currency, storage, notification keys).
abstract final class AppConstants {
  // ── Currency (BDT) ────────────────────────────────────────────────────────
  static const String currencyCode = 'BDT';
  static const String currencySymbol = '৳';

  /// en_IN gives lakh/crore grouping (1,00,000), which Bangladesh also uses.
  static const String currencyLocale = 'en_IN';
  static const int currencyDecimalDigits = 2;

  /// 1 taka = 100 poisha. Amounts are stored as poisha in the database.
  static const int minorUnitsPerMajor = 100;

  // ── Expense projections ───────────────────────────────────────────────────
  static const int daysPerMonth = 30;

  // ── Storage ───────────────────────────────────────────────────────────────
  static const String databaseName = 'dosey';
  static const String recordsFolder = 'records';
  static const String imageExtension = '.jpg';
  static const String imageMimeType = 'image/jpeg';
  static const int imageQuality = 85;
  static const double imageMaxDimension = 2400;

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String criticalChannelKey = 'dosey_critical_alarms';
  static const String standardChannelKey = 'dosey_reminders';
  static const String channelGroupKey = 'dosey_group';
  static const int defaultSnoozeMinutes = 10;
}
