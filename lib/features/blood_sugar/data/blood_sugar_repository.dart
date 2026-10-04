import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BloodSugarRepository {
  BloodSugarRepository(this._db);

  final AppDatabase _db;

  /// Newest first.
  Stream<List<BloodSugarReading>> watchAll() =>
      (_db.select(_db.bloodSugarReadings)..orderBy([
            (r) => OrderingTerm.desc(r.measuredAt),
            (r) => OrderingTerm.desc(r.id),
          ]))
          .watch();

  Future<int> create(BloodSugarReadingsCompanion reading) =>
      _db.into(_db.bloodSugarReadings).insert(reading);

  Future<void> update(int id, BloodSugarReadingsCompanion changes) =>
      (_db.update(
        _db.bloodSugarReadings,
      )..where((r) => r.id.equals(id))).write(changes);

  Future<void> delete(int id) =>
      (_db.delete(_db.bloodSugarReadings)..where((r) => r.id.equals(id))).go();
}
