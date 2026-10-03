import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/medicine_with_doctor.dart';

class MedicinesRepository {
  MedicinesRepository(this._db);

  final AppDatabase _db;

  JoinedSelectStatement<HasResultSet, dynamic> _joined() =>
      _db.select(_db.medicines).join([
        leftOuterJoin(
          _db.doctors,
          _db.doctors.id.equalsExp(_db.medicines.doctorId),
        ),
      ])..orderBy([
        OrderingTerm.desc(_db.medicines.isActive),
        OrderingTerm.asc(_db.medicines.name),
      ]);

  Stream<List<MedicineWithDoctor>> _watch(
    JoinedSelectStatement<HasResultSet, dynamic> query,
  ) => query.watch().map(
    (rows) => [
      for (final row in rows)
        MedicineWithDoctor(
          medicine: row.readTable(_db.medicines),
          doctor: row.readTableOrNull(_db.doctors),
        ),
    ],
  );

  Stream<List<MedicineWithDoctor>> watchAll({bool activeOnly = false}) {
    final query = _joined();
    if (activeOnly) query.where(_db.medicines.isActive.equals(true));
    return _watch(query);
  }

  Stream<List<MedicineWithDoctor>> watchByDoctor(int doctorId) =>
      _watch(_joined()..where(_db.medicines.doctorId.equals(doctorId)));

  Stream<MedicineWithDoctor?> watchById(int id) => _watch(
    _joined()..where(_db.medicines.id.equals(id)),
  ).map((list) => list.firstOrNull);

  /// Active medicines only, without the doctor join (used for cost projection).
  Stream<List<Medicine>> watchActiveRaw() => (_db.select(
    _db.medicines,
  )..where((m) => m.isActive.equals(true))).watch();

  Future<int> create(MedicinesCompanion medicine) =>
      _db.into(_db.medicines).insert(medicine);

  Future<void> update(int id, MedicinesCompanion changes) =>
      (_db.update(_db.medicines)..where((m) => m.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(DateTime.now())),
      );

  /// Deactivating also disables the medicine's reminders.
  Future<void> setActive(int id, {required bool active}) =>
      _db.transaction(() async {
        await update(id, MedicinesCompanion(isActive: Value(active)));
        if (!active) {
          await (_db.update(
            _db.reminders,
          )..where((r) => r.medicineId.equals(id))).write(
            const RemindersCompanion(
              isEnabled: Value(false),
              nextTriggerAt: Value(null),
            ),
          );
        }
      });

  /// Records a purchase: adds [quantity] to stock (starting stock tracking if
  /// it wasn't tracked) and logs the cost as a medicine expense, atomically.
  Future<void> refill({
    required Medicine medicine,
    required double quantity,
    required int totalMinor,
    DateTime? on,
  }) => _db.transaction(() async {
    await update(
      medicine.id,
      MedicinesCompanion(
        stockQuantity: Value((medicine.stockQuantity ?? 0) + quantity),
      ),
    );
    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            category: ExpenseCategory.medicine,
            title: medicine.name,
            amountMinor: totalMinor,
            quantity: Value(quantity),
            medicineId: Value(medicine.id),
            doctorId: Value(medicine.doctorId),
            spentOn: on ?? DateTime.now(),
          ),
        );
  });

  /// Cascades to the medicine's reminders and their logs.
  /// The most recently created medicine, if any.
  Future<Medicine?> newest() =>
      (_db.select(_db.medicines)
            ..orderBy([(m) => OrderingTerm.desc(m.id)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> delete(int id) =>
      (_db.delete(_db.medicines)..where((m) => m.id.equals(id))).go();
}
