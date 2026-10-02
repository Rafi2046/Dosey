import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/database/app_database.dart';
import '../../reminders/data/reminders_repository.dart';
import 'medicines_repository.dart';

/// Creates a medicine together with one daily reminder per intake time, so
/// "add medicine" is a single atomic step for the user.
class MedicineScheduleService {
  MedicineScheduleService(this._db, this._medicines, this._reminders);

  final AppDatabase _db;
  final MedicinesRepository _medicines;
  final RemindersRepository _reminders;

  Future<int> createWithTimes(
    MedicinesCompanion medicine,
    List<TimeOfDay> times, {
    required DateTime startDate,
    DateTime? endDate,
  }) => _db.transaction(() async {
    final id = await _medicines.create(medicine);
    final name = medicine.name.value;
    for (final t in times) {
      await addTime(id, name, t, startDate: startDate, endDate: endDate);
    }
    return id;
  });

  /// Adds a daily reminder for an existing medicine.
  Future<Reminder> addTime(
    int medicineId,
    String medicineName,
    TimeOfDay time, {
    required DateTime startDate,
    DateTime? endDate,
  }) => _reminders.create(
    RemindersCompanion.insert(
      type: ReminderType.medicine,
      title: medicineName,
      medicineId: Value(medicineId),
      startAt: DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        time.hour,
        time.minute,
      ),
      repeatRule: const Value(RepeatRule.daily),
      endAt: Value(endOfDay(endDate)),
    ),
  );

  /// Applies a changed medicine end date to all of its reminders.
  Future<void> syncEndDate(int medicineId, DateTime? endDate) =>
      _db.transaction(() async {
        final reminders = await _reminders.watchByMedicine(medicineId).first;
        for (final d in reminders) {
          await _reminders.update(
            d.reminder.id,
            RemindersCompanion(endAt: Value(endOfDay(endDate))),
          );
        }
      });

  /// Medicine end dates are inclusive: doses on that day still ring.
  static DateTime? endOfDay(DateTime? day) =>
      day == null ? null : DateTime(day.year, day.month, day.day, 23, 59);
}
