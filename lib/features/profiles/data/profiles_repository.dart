import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class ProfilesRepository {
  ProfilesRepository(this._db);

  final AppDatabase _db;

  /// The first profile: the user's own. It can't be deleted.
  static const int mainProfileId = 1;

  /// Oldest first (the user's own profile leads).
  Stream<List<Profile>> watchAll() => (_db.select(
    _db.profiles,
  )..orderBy([(p) => OrderingTerm.asc(p.id)])).watch();

  Future<int> create(String name, {required int colorIndex}) => _db
      .into(_db.profiles)
      .insert(
        ProfilesCompanion.insert(
          name: name.trim(),
          colorIndex: Value(colorIndex),
        ),
      );

  Future<void> rename(int id, String name) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(id))).write(
        ProfilesCompanion(name: Value(name.trim())),
      );

  /// Deletes a family member's profile and everything that's theirs
  /// (medicines, reminders and their history, records, expenses, readings),
  /// by cascade. The main profile is kept.
  Future<void> delete(int id) async {
    if (id == mainProfileId) return;
    await (_db.delete(_db.profiles)..where((p) => p.id.equals(id))).go();
  }
}
