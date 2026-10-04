import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/reminder_schedule.dart';
import '../domain/reminder_with_details.dart';
import '../../medicines/domain/stock_status.dart';

class RemindersRepository {
  RemindersRepository(this._db);

  final AppDatabase _db;

  // ── Queries ───────────────────────────────────────────────────────────────

  JoinedSelectStatement<HasResultSet, dynamic> _joined() =>
      _db.select(_db.reminders).join([
        leftOuterJoin(
          _db.medicines,
          _db.medicines.id.equalsExp(_db.reminders.medicineId),
        ),
        leftOuterJoin(
          _db.doctors,
          _db.doctors.id.equalsExp(_db.reminders.doctorId),
        ),
      ]);

  Stream<List<ReminderWithDetails>> _watch(
    JoinedSelectStatement<HasResultSet, dynamic> query,
  ) => query.watch().map(
    (rows) => [
      for (final row in rows)
        ReminderWithDetails(
          reminder: row.readTable(_db.reminders),
          medicine: row.readTableOrNull(_db.medicines),
          doctor: row.readTableOrNull(_db.doctors),
        ),
    ],
  );

  Stream<List<ReminderWithDetails>> watchAll() => _watch(
    _joined()..orderBy([
      OrderingTerm.desc(_db.reminders.isEnabled),
      OrderingTerm.asc(_db.reminders.nextTriggerAt, nulls: NullsOrder.last),
    ]),
  );

  Stream<List<ReminderWithDetails>> watchEnabled() =>
      _watch(_joined()..where(_db.reminders.isEnabled.equals(true)));

  /// Upcoming enabled reminders ordered by next fire time.
  Stream<List<ReminderWithDetails>> watchUpcoming({int? limit}) {
    final query = _joined()
      ..where(
        _db.reminders.isEnabled.equals(true) &
            _db.reminders.nextTriggerAt.isNotNull(),
      )
      ..orderBy([OrderingTerm.asc(_db.reminders.nextTriggerAt)]);
    if (limit != null) query.limit(limit);
    return _watch(query);
  }

  Stream<List<ReminderWithDetails>> watchByMedicine(int medicineId) =>
      _watch(_joined()..where(_db.reminders.medicineId.equals(medicineId)));

  Stream<ReminderWithDetails?> watchById(int id) => _watch(
    _joined()..where(_db.reminders.id.equals(id)),
  ).map((list) => list.firstOrNull);

  Future<Reminder?> getById(int id) => (_db.select(
    _db.reminders,
  )..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<Reminder>> getAll() => _db.select(_db.reminders).get();

  /// Raw rows, for keeping OS alarms in sync with the database.
  Stream<List<Reminder>> watchAllRaw() => _db.select(_db.reminders).watch();

  Future<ReminderWithDetails?> getDetails(int id) => watchById(id).first;

  /// Enabled medicine reminders whose next alarm is exactly [at]: the ones
  /// that ring together as one grouped alarm.
  Future<List<Reminder>> getMedicinesDueAt(DateTime at) =>
      (_db.select(_db.reminders)
            ..where(
              (r) =>
                  r.isEnabled.equals(true) &
                  r.type.equalsValue(ReminderType.medicine) &
                  r.nextTriggerAt.equals(at),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .get();

  /// What was already recorded for [ids] at [scheduledFor].
  Future<Map<int, ReminderLogStatus>> statusesFor(
    List<int> ids,
    DateTime scheduledFor,
  ) async => {
    for (final l
        in await (_db.select(_db.reminderLogs)..where(
              (l) =>
                  l.reminderId.isIn(ids) & l.scheduledFor.equals(scheduledFor),
            ))
            .get())
      l.reminderId: l.status,
  };

  /// Enabled reminders with their medicine/doctor, once.
  Future<List<ReminderWithDetails>> getEnabledDetails() => watchEnabled().first;

  /// Logs for occurrences scheduled in [start, end), once.
  Future<List<ReminderLog>> logsBetween(DateTime start, DateTime end) =>
      (_db.select(_db.reminderLogs)..where(
            (l) =>
                l.scheduledFor.isBiggerOrEqualValue(start) &
                l.scheduledFor.isSmallerThanValue(end),
          ))
          .get();

  /// Reminders currently ringing (awaiting Taken/Skip/Snooze), oldest first.
  Stream<List<ReminderWithDetails>> watchRinging() => _watch(
    _joined()
      ..where(_db.reminders.ringingFor.isNotNull())
      ..orderBy([OrderingTerm.asc(_db.reminders.ringingFor)]),
  );

  Stream<List<ReminderLog>> watchLogsBetween(DateTime start, DateTime end) =>
      (_db.select(
        _db.reminderLogs,
      )..where((l) => l.scheduledFor.isBetweenValues(start, end))).watch();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Inserts and computes [Reminders.nextTriggerAt]. Returns the stored row.
  Future<Reminder> create(RemindersCompanion reminder, {DateTime? now}) async {
    final id = await _db.into(_db.reminders).insert(reminder);
    return refreshNextTrigger(id, now: now);
  }

  Future<Reminder> update(
    int id,
    RemindersCompanion changes, {
    DateTime? now,
  }) async {
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(DateTime.now())),
    );
    return refreshNextTrigger(id, now: now);
  }

  Future<Reminder> setEnabled(int id, {required bool enabled, DateTime? now}) =>
      update(id, RemindersCompanion(isEnabled: Value(enabled)), now: now);

  /// Recomputes the next fire time after [now]; call after an alarm fires.
  Future<Reminder> refreshNextTrigger(int id, {DateTime? now}) async {
    final row = (await getById(id))!;
    final next = row.isEnabled
        ? ReminderSchedule.nextFor(row, now ?? DateTime.now())
        : null;
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(nextTriggerAt: Value(next)),
    );
    return row.copyWith(nextTriggerAt: Value(next));
  }

  /// Marks which occurrence is ringing (null clears it).
  Future<void> setRinging(int id, DateTime? occurrence) =>
      (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
        RemindersCompanion(ringingFor: Value(occurrence)),
      );

  Future<void> delete(int id) =>
      (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();

  /// Records the user's action for one occurrence. Marking a medicine dose
  /// as taken (or taken late) deducts its dose from stock (only once per
  /// occurrence).
  Future<void> logAction({
    required int reminderId,
    required DateTime scheduledFor,
    required ReminderLogStatus status,
    DateTime? actedAt,
  }) => _db.transaction(() async {
    final previous =
        await (_db.select(_db.reminderLogs)..where(
              (l) =>
                  l.reminderId.equals(reminderId) &
                  l.scheduledFor.equals(scheduledFor),
            ))
            .getSingleOrNull();

    await _db
        .into(_db.reminderLogs)
        .insert(
          ReminderLogsCompanion.insert(
            reminderId: reminderId,
            scheduledFor: scheduledFor,
            status: status,
            actedAt: Value(actedAt ?? DateTime.now()),
          ),
          onConflict: DoUpdate(
            (_) => ReminderLogsCompanion(
              status: Value(status),
              actedAt: Value(actedAt ?? DateTime.now()),
            ),
            target: [
              _db.reminderLogs.reminderId,
              _db.reminderLogs.scheduledFor,
            ],
          ),
        );

    final wasTaken = previous?.status.isTaken ?? false;
    final isTaken = status.isTaken;
    if (wasTaken != isTaken) {
      await _adjustStockForDose(reminderId, restore: wasTaken);
    }
  });

  /// [logAction] for several reminders of one occurrence, all or nothing
  /// (a grouped alarm's "Taken" records every medicine together).
  Future<void> logActions({
    required List<int> reminderIds,
    required DateTime scheduledFor,
    required ReminderLogStatus status,
  }) => _db.transaction(() async {
    final actedAt = DateTime.now();
    for (final id in reminderIds) {
      await logAction(
        reminderId: id,
        scheduledFor: scheduledFor,
        status: status,
        actedAt: actedAt,
      );
    }
  });

  Future<void> _adjustStockForDose(
    int reminderId, {
    required bool restore,
  }) async {
    final reminder = await getById(reminderId);
    final medicineId = reminder?.medicineId;
    if (reminder == null || medicineId == null) return;
    // Each time can have its own amount (2 at 08:00, 1 at 14:00).
    final amount = reminder.doseAmount ?? 1;
    await _db.adjustMedicineStock(medicineId, restore ? amount : -amount);
  }

  /// Stock state of the medicine [reminderId] belongs to, at its current
  /// dose (null for non-medicine reminders).
  Future<StockStatus?> stockStatusFor(int reminderId) async {
    final medicineId = (await getById(reminderId))?.medicineId;
    if (medicineId == null) return null;
    final medicine = await (_db.select(
      _db.medicines,
    )..where((m) => m.id.equals(medicineId))).getSingleOrNull();
    if (medicine == null) return null;
    final reminders = await (_db.select(
      _db.reminders,
    )..where((r) => r.medicineId.equals(medicineId))).get();
    return StockStatus(
      medicine,
      unitsPerDayByMedicine(reminders)[medicineId] ?? 0,
    );
  }
}
