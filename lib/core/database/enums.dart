// Enums persisted via Drift's `textEnum`, which stores `enum.name`.
// Renaming a value is a schema change and needs a migration; reordering is safe.

enum MedicineForm {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  inhaler,
  cream,
  other,
}

enum MealRelation { beforeMeal, withMeal, afterMeal, anytime }

enum ReminderType { medicine, appointment, vaccine, medicalTest }

enum RepeatRule {
  /// Fires once at [Reminders.startAt].
  once,

  /// Fires every day at the time-of-day of [Reminders.startAt].
  daily,

  /// Fires on the weekdays set in [Reminders.weekdaysMask].
  weekly,

  /// Fires every [Reminders.repeatInterval] days.
  everyNDays,
}

enum ReminderLogStatus {
  taken,
  skipped,
  snoozed,

  /// Nobody acted within `AppConstants.missedThreshold`, or the alarm was
  /// dismissed without an answer.
  missed,

  /// A missed dose the user later reported taking.
  takenLate,
}

extension ReminderLogStatusOutcome on ReminderLogStatus {
  /// The dose was actually swallowed (on time or late): stock is deducted.
  bool get isTaken =>
      this == ReminderLogStatus.taken || this == ReminderLogStatus.takenLate;

  /// The user gave a final answer (a snooze or a miss can still change).
  bool get isAnswered => isTaken || this == ReminderLogStatus.skipped;
}

enum RecordType { prescription, testReport, vaccineCertificate, invoice, other }

enum ExpenseCategory { medicine, consultation, test, vaccine, other }

/// When a blood sugar reading was taken.
enum SugarContext { fasting, beforeMeal, afterMeal, random, bedtime }
