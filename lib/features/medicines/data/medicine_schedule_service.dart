import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../reminders/data/reminders_repository.dart';
import '../domain/dose_time.dart';
import 'medicines_repository.dart';

/// Creates a medicine together with one daily reminder per intake time (each
/// with its own amount), so "add medicine" is a single atomic step.
class MedicineScheduleService {
  MedicineScheduleService(this._db, this._medicines, this._reminders);

  final AppDatabase _db;
  final MedicinesRepository _medicines;
  final RemindersRepository _reminders;

  Future<int> createWithTimes(
    MedicinesCompanion medicine,
    List<DoseTime> doses, {
    required DateTime startDate,
    DateTime? endDate,
    bool critical = true,
  }) => _db.transaction(
    () => _create(
      medicine,
      doses,
      startDate: startDate,
      endDate: endDate,
      critical: critical,
    ),
  );

  /// Bulk add (e.g. a scanned prescription): all medicines and their
  /// reminders are saved, or none are. With [newDoctor] (the doctor read off
  /// the prescription) that doctor is created too and every medicine is
  /// linked to them.
  Future<List<int>> createMany(
    List<NewMedicine> items, {
    DoctorsCompanion? newDoctor,
  }) => _db.transaction(() async {
    final doctorId = newDoctor == null
        ? null
        : await _db.into(_db.doctors).insert(newDoctor);
    return [
      for (final i in items)
        await _create(
          doctorId == null
              ? i.medicine
              : i.medicine.copyWith(doctorId: Value(doctorId)),
          i.doses,
          startDate: i.startDate,
          endDate: i.endDate,
        ),
    ];
  });

  Future<int> _create(
    MedicinesCompanion medicine,
    List<DoseTime> doses, {
    required DateTime startDate,
    DateTime? endDate,
    bool critical = true,
  }) async {
    final id = await _medicines.create(medicine);
    final name = medicine.name.value;
    for (final d in doses) {
      await addTime(
        id,
        name,
        d,
        startDate: startDate,
        endDate: endDate,
        critical: critical,
      );
    }
    return id;
  }

  /// Adds a daily reminder for an existing medicine.
  /// [critical]: full-screen alarm that rings on silent (default) rather
  /// than a gentle notification.
  Future<Reminder> addTime(
    int medicineId,
    String medicineName,
    DoseTime dose, {
    required DateTime startDate,
    DateTime? endDate,
    bool critical = true,
  }) => _reminders.create(
    RemindersCompanion.insert(
      type: ReminderType.medicine,
      title: medicineName,
      medicineId: Value(medicineId),
      startAt: DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        dose.time.hour,
        dose.time.minute,
      ),
      doseAmount: Value(dose.amount),
      isCritical: Value(critical),
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

/// One medicine for [MedicineScheduleService.createMany].
class NewMedicine {
  const NewMedicine({
    required this.medicine,
    required this.doses,
    required this.startDate,
    this.endDate,
  });

  final MedicinesCompanion medicine;
  final List<DoseTime> doses;
  final DateTime startDate;
  final DateTime? endDate;
}
