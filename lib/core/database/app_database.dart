import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'enums.dart';
import 'tables/doctors_table.dart';
import 'tables/expenses_table.dart';
import 'tables/medicines_table.dart';
import 'tables/records_table.dart';
import 'tables/reminders_table.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Doctors,
    Medicines,
    Reminders,
    ReminderLogs,
    Records,
    RecordAttachments,
    Expenses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // SQLite ships with FK enforcement off; cascades depend on it.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'dosey',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        // Alarm callbacks run in a background isolate and write to the same DB.
        shareAcrossIsolates: true,
      ),
    );
  }
}
