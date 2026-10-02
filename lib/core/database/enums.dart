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

enum ReminderLogStatus { taken, skipped, snoozed, missed }

enum RecordType { prescription, testReport, vaccineCertificate, invoice, other }

enum ExpenseCategory { medicine, consultation, test, vaccine, other }
