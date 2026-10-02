import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/doctor_with_stats.dart';

class DoctorsRepository {
  DoctorsRepository(this._db);

  final AppDatabase _db;

  Stream<List<Doctor>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.doctors)
      ..orderBy([(d) => OrderingTerm.asc(d.name)]);
    if (!includeArchived) query.where((d) => d.isArchived.equals(false));
    return query.watch();
  }

  /// Non-archived doctors with how many active medicines they prescribed.
  Stream<List<DoctorWithStats>> watchWithStats() {
    final medCount = _db.medicines.id.count();
    final query = _db.select(_db.doctors).join([
      leftOuterJoin(
        _db.medicines,
        _db.medicines.doctorId.equalsExp(_db.doctors.id) &
            _db.medicines.isActive.equals(true),
      ),
    ])
      ..addColumns([medCount])
      ..where(_db.doctors.isArchived.equals(false))
      ..groupBy([_db.doctors.id])
      ..orderBy([OrderingTerm.asc(_db.doctors.name)]);

    return query.watch().map(
          (rows) => [
            for (final row in rows)
              DoctorWithStats(
                doctor: row.readTable(_db.doctors),
                activeMedicineCount: row.read(medCount) ?? 0,
              ),
          ],
        );
  }

  Stream<Doctor?> watchById(int id) =>
      (_db.select(_db.doctors)..where((d) => d.id.equals(id)))
          .watchSingleOrNull();

  Future<int> create(DoctorsCompanion doctor) =>
      _db.into(_db.doctors).insert(doctor);

  Future<void> update(int id, DoctorsCompanion changes) =>
      (_db.update(_db.doctors)..where((d) => d.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> setArchived(int id, {required bool archived}) =>
      update(id, DoctorsCompanion(isArchived: Value(archived)));

  /// Linked medicines, records and expenses keep their rows (doctorId → null).
  Future<void> delete(int id) =>
      (_db.delete(_db.doctors)..where((d) => d.id.equals(id))).go();
}
