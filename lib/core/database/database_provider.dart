import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single app-wide database. Override in tests with an in-memory instance:
/// `appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory()))`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
