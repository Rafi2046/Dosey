import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BloodPressureRepository {
  BloodPressureRepository(this._db, {this.profileId});

  final AppDatabase _db;

  /// Whose readings: only this profile's are listed, and new ones are
  /// theirs. Null = every profile.
  final int? profileId;

  /// Newest first.
  Stream<List<BloodPressureReading>> watchAll() =>
      (_db.select(_db.bloodPressureReadings)
            ..where(
              (r) => profileId == null
                  ? const Constant(true)
                  : r.profileId.equals(profileId!),
            )
            ..orderBy([
              (r) => OrderingTerm.desc(r.measuredAt),
              (r) => OrderingTerm.desc(r.id),
            ]))
          .watch();

  Stream<BloodPressureReading?> watchById(int id) => (_db.select(
    _db.bloodPressureReadings,
  )..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<int> create(BloodPressureReadingsCompanion reading) => _db
      .into(_db.bloodPressureReadings)
      .insert(
        profileId == null || reading.profileId.present
            ? reading
            : reading.copyWith(profileId: Value(profileId!)),
      );

  Future<void> update(int id, BloodPressureReadingsCompanion changes) =>
      (_db.update(
        _db.bloodPressureReadings,
      )..where((r) => r.id.equals(id))).write(changes);

  Future<void> delete(int id) => (_db.delete(
    _db.bloodPressureReadings,
  )..where((r) => r.id.equals(id))).go();
}
