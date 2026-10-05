import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BloodSugarRepository {
  BloodSugarRepository(this._db, {this.profileId});

  final AppDatabase _db;

  /// Whose readings: only this profile's are listed, and new ones are
  /// theirs. Null = every profile.
  final int? profileId;

  /// Newest first.
  Stream<List<BloodSugarReading>> watchAll() =>
      (_db.select(_db.bloodSugarReadings)
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

  Future<int> create(BloodSugarReadingsCompanion reading) => _db
      .into(_db.bloodSugarReadings)
      .insert(
        profileId == null || reading.profileId.present
            ? reading
            : reading.copyWith(profileId: Value(profileId!)),
      );

  Future<void> update(int id, BloodSugarReadingsCompanion changes) =>
      (_db.update(
        _db.bloodSugarReadings,
      )..where((r) => r.id.equals(id))).write(changes);

  Future<void> delete(int id) =>
      (_db.delete(_db.bloodSugarReadings)..where((r) => r.id.equals(id))).go();
}
