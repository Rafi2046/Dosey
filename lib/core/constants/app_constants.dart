/// Non-visual app configuration (currency, storage, notifications, alarms).
abstract final class AppConstants {
  // ── Currency (BDT) ────────────────────────────────────────────────────────
  static const String currencyCode = 'BDT';
  static const String currencySymbol = '৳';

  /// en_IN gives lakh/crore grouping (1,00,000), which Bangladesh also uses.
  static const String currencyLocale = 'en_IN';
  static const int currencyDecimalDigits = 2;

  /// 1 taka = 100 poisha. Amounts are stored as poisha in the database.
  static const int minorUnitsPerMajor = 100;

  // ── Date formats ──────────────────────────────────────────────────────────
  static const String timePattern = 'hh:mm a';
  static const String dateTimePattern = 'EEE, d MMM · hh:mm a';

  // ── Expense projections ───────────────────────────────────────────────────
  static const int daysPerMonth = 30;

  // ── Storage ───────────────────────────────────────────────────────────────
  static const String databaseName = 'dosey';
  static const String recordsFolder = 'records';
  static const String imageExtension = '.jpg';
  static const String imageMimeType = 'image/jpeg';
  static const int imageQuality = 85;
  static const double imageMaxDimension = 2400;

  // ── Notification channels ─────────────────────────────────────────────────
  // Changing a channel's sound/importance requires a NEW key: Android freezes
  // channel settings after first creation.
  static const String channelGroupKey = 'dosey_reminders_group';
  static const String channelMedicine = 'dosey_alarm_medicine_v2';
  static const String channelAppointment = 'dosey_alarm_appointment_v2';
  static const String channelVaccine = 'dosey_alarm_vaccine_v2';
  static const String channelMedicalTest = 'dosey_alarm_test_v2';
  static const String channelGentle = 'dosey_gentle_v2';

  /// Android drawable used as the status-bar icon.
  static const String notificationIcon = 'resource://drawable/ic_stat_dosey';

  // ── Notification actions & payload ────────────────────────────────────────
  static const String actionTaken = 'TAKEN';
  static const String actionSkip = 'SKIP';
  static const String actionSnooze = 'SNOOZE';
  static const String payloadReminderId = 'reminderId';
  static const String payloadScheduledFor = 'scheduledFor';
  static const String alarmParamScheduledFor = 'scheduledFor';
  static const String alarmParamIsSnooze = 'isSnooze';

  // ── Alarm scheduling ──────────────────────────────────────────────────────
  static const int defaultSnoozeMinutes = 10;

  /// Snooze alarms use `snoozeIdOffset + reminderId` so they never collide
  /// with the reminder's own alarm id.
  static const int snoozeIdOffset = 1000000000;

  /// Fixed alarm id used by the boot receiver to run the resync callback.
  static const int resyncAlarmId = 2000000000;

  /// An alarm delivered later than this (device was off, Doze delay...) is
  /// logged as missed instead of ringing.
  static const Duration missedThreshold = Duration(hours: 2);

  /// Vibration pattern for alarm channels (ms: wait, buzz, wait, buzz...).
  static const List<int> alarmVibrationPattern = [0, 800, 400, 800, 400, 800];

  // ── Native bridge (see MainActivity.kt / BootReceiver.kt) ─────────────────
  static const String nativeChannel = 'dosey/native';
  static const String nativeSetShowOverLock = 'setShowOverLockScreen';
  static const String nativeRegisterResync = 'registerResyncHandle';
  static const String nativeEnsureAlarmChannels = 'ensureAlarmChannels';
  static const String nativeWasLaunchedOverLock = 'wasLaunchedOverLockScreen';
}
