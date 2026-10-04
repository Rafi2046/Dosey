import 'package:drift/drift.dart';

import '../enums.dart';
import 'doctors_table.dart';
import 'medicines_table.dart';

/// One row = one alarm time. A medicine taken 3×/day has 3 reminder rows.
/// The row [id] doubles as the awesome_notifications / AlarmManager id.
@DataClassName('Reminder')
@TableIndex(name: 'idx_reminders_next', columns: {#isEnabled, #nextTriggerAt})
@TableIndex(name: 'idx_reminders_medicine', columns: {#medicineId})
@TableIndex(name: 'idx_reminders_doctor', columns: {#doctorId})
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<ReminderType>()();
  TextColumn get title => text().withLength(min: 1, max: 160)();
  TextColumn get description => text().nullable()();

  /// Required when [type] is medicine (enforced by CHECK below).
  IntColumn get medicineId => integer().nullable().references(
    Medicines,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Doctor for appointments; optional context for other types.
  IntColumn get doctorId => integer().nullable().references(
    Doctors,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Units to take at this time (2 tablets at 08:00, 1 at 14:00…), in the
  /// medicine's [Medicines.doseUnit]. Null for non-medicine reminders.
  RealColumn get doseAmount => real().nullable()();

  /// Clinic / lab / vaccination centre.
  TextColumn get location => text().nullable()();

  /// First occurrence; its time-of-day is reused for repeating rules.
  DateTimeColumn get startAt => dateTime()();
  TextColumn get repeatRule =>
      textEnum<RepeatRule>().withDefault(Constant(RepeatRule.once.name))();

  /// N for [RepeatRule.everyNDays].
  IntColumn get repeatInterval => integer().nullable()();

  /// Bit 0 = Monday … bit 6 = Sunday, for [RepeatRule.weekly].
  IntColumn get weekdaysMask => integer().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();

  /// Cached next fire time used by the scheduler; null once the series ends.
  DateTimeColumn get nextTriggerAt => dateTime().nullable()();

  /// Occurrence currently ringing and awaiting Taken/Skip/Snooze; null when
  /// nothing is pending. Drives the full-screen alarm screen.
  DateTimeColumn get ringingFor => dateTime().nullable()();

  /// Critical = bypass DND + full-screen intent.
  BoolColumn get isCritical => boolean().withDefault(const Constant(true))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(10))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    "CHECK (type <> 'medicine' OR medicine_id IS NOT NULL)",
    'CHECK (dose_amount IS NULL OR dose_amount > 0)',
    "CHECK (repeat_rule <> 'everyNDays' OR (repeat_interval IS NOT NULL AND repeat_interval >= 1))",
    "CHECK (repeat_rule <> 'weekly' OR (weekdays_mask IS NOT NULL AND weekdays_mask BETWEEN 1 AND 127))",
  ];
}

/// Dose / attendance history, written from notification actions.
@DataClassName('ReminderLog')
@TableIndex(name: 'idx_reminder_logs_reminder', columns: {#reminderId})
class ReminderLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId =>
      integer().references(Reminders, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledFor => dateTime()();
  TextColumn get status => textEnum<ReminderLogStatus>()();

  /// When the user acted. For [ReminderLogStatus.snoozed]: when the dose
  /// rings again (it only counts as missed a while after that).
  DateTimeColumn get actedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {reminderId, scheduledFor},
  ];
}
