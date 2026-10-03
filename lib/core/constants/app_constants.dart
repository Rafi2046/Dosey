/// Non-visual app configuration (currency, storage, notifications, alarms).
abstract final class AppConstants {
  // ── Currency (BDT) ────────────────────────────────────────────────────────
  static const String currencySymbol = '৳';

  /// en_IN gives lakh/crore grouping (1,00,000), which Bangladesh also uses.
  static const String currencyLocale = 'en_IN';
  static const int currencyDecimalDigits = 2;

  /// 1 taka = 100 poisha. Amounts are stored as poisha in the database.
  static const int minorUnitsPerMajor = 100;

  // ── Date formats ──────────────────────────────────────────────────────────
  static const String timePattern = 'hh:mm a';
  static const String dateTimePattern = 'EEE, d MMM · hh:mm a';
  static const String datePattern = 'd MMM yyyy';
  static const String shortDatePattern = 'EEE, d MMM';
  static const String monthPattern = 'MMMM yyyy';

  // ── Publishing (replace before release) ───────────────────────────────────
  /// Shown in Settings › Contact support and in the privacy policy.
  static const String supportEmail = 'support@example.com';

  /// Settings › Rate Dosey. Must match the final applicationId.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.dosey';

  /// "Last updated" date on the privacy policy, terms and disclaimer.
  static final DateTime legalUpdated = DateTime(2026, 10, 3);

  // ── Expense projections ───────────────────────────────────────────────────
  static const int daysPerMonth = 30;
  static const int daysPerWeek = 7;

  /// Months in the spending trend on the expenses card.
  static const int expenseTrendMonths = 6;

  // ── Prescription scan: clock times for dose slots (1+0+1, BD, night…) ─────
  static const int doseMorningHour = 8;
  static const int doseNoonHour = 14;
  static const int doseEveningHour = 18;
  static const int doseNightHour = 21;
  static const int doseBedtimeHour = 22;
  static const int doseBedtimeMinute = 30;

  // ── Stock ─────────────────────────────────────────────────────────────────
  /// Default "warn me N days before it runs out" for new medicines.
  static const int defaultRefillAlertDays = 3;
  static const int maxRefillAlertDays = 30;

  /// Low-stock notifications use `lowStockIdOffset + medicineId`.
  static const int lowStockIdOffset = 1500000000;

  /// First dose of "every N hours" schedules.
  static const int doseIntervalStartHour = 8;

  // ── Storage ───────────────────────────────────────────────────────────────
  static const String databaseName = 'dosey';
  static const String recordsFolder = 'records';
  static const String imageExtension = '.jpg';
  static const String imageMimeType = 'image/jpeg';
  static const int imageQuality = 85;
  static const double imageMaxDimension = 2400;

  /// Decode widths for thumbnails (keeps grids light on memory).
  static const int thumbCacheWidth = 400;
  static const int stripCacheWidth = 300;

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

  /// Every reminder an alarm/notification covers (several medicines due at
  /// the same minute share one alarm), as comma-separated ids.
  static const String payloadReminderIds = 'reminderIds';
  static const String alarmParamReminderIds = 'reminderIds';

  /// Blood pressure unit (the same in every language).
  static const String bpUnit = 'mmHg';

  // ── Alarm scheduling ──────────────────────────────────────────────────────
  static const int defaultSnoozeMinutes = 10;
  static const List<int> snoozeOptions = [5, 10, 15, 30];

  /// Snooze alarms use `snoozeIdOffset + reminderId` (the group's lowest
  /// id) so they never collide with a reminder's own alarm id.
  static const int snoozeIdOffset = 1000000000;

  /// iOS books medicine time slots ahead as `slotIdOffset + minutes since
  /// the epoch` (one id per minute, below [snoozeIdOffset] for the next
  /// ~1,500 years). Other reminder types keep their reminder id.
  static const int slotIdOffset = 100000000;

  /// How far ahead iOS books, and at most how many (iOS keeps only 64
  /// pending local notifications per app; the rest is room for snoozes and
  /// low-stock alerts).
  static const Duration bookAhead = Duration(days: 7);
  static const int bookAheadLimit = 48;

  /// Bundled alarm tone for iOS (ios/Runner/dosey_alarm.aiff, under 30 s:
  /// iOS plays the default sound for anything longer).
  static const String iosAlarmSound = 'resource://raw/dosey_alarm';

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
  static const String nativeSpecialPermissionStatus = 'specialPermissionStatus';
  static const String nativeOpenPermissionSettings = 'openPermissionSettings';
  static const String nativeWasLaunchedOverLock = 'wasLaunchedOverLockScreen';
}
