import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BloodPressureRepository {
  BloodPressureRepository(this._db);

  final AppDatabase _db;

  /// Newest first.
  Stream<List<BloodPressureReading>> watchAll() =>
      (_db.select(_db.bloodPressureReadings)..orderBy([
            (r) => OrderingTerm.desc(r.measuredAt),
            (r) => OrderingTerm.desc(r.id),
          ]))
          .watch();

  Stream<BloodPressureReading?> watchById(int id) => (_db.select(
    _db.bloodPressureReadings,
  )..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<int> create(BloodPressureReadingsCompanion reading) =>
      _db.into(_db.bloodPressureReadings).insert(reading);

  Future<void> update(int id, BloodPressureReadingsCompanion changes) =>
      (_db.update(
        _db.bloodPressureReadings,
      )..where((r) => r.id.equals(id))).write(changes);

  Future<void> delete(int id) => (_db.delete(
    _db.bloodPressureReadings,
  )..where((r) => r.id.equals(id))).go();
}
