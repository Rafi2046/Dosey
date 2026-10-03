import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'enums.dart';
import 'tables/doctors_table.dart';
import 'tables/expenses_table.dart';
import 'tables/medicines_table.dart';
import 'tables/records_table.dart';
import 'tables/reminders_table.dart';
import 'tables/settings_table.dart';

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
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Table rebuilds below drop and recreate tables; with FKs on, dropping
      // medicines would cascade-delete every reminder.
      await customStatement('PRAGMA foreign_keys = OFF');
      if (from < 2) await m.addColumn(reminders, reminders.ringingFor);
      if (from < 3) await _moveDoseAmountToReminders(m);
      // From v2 the v3 rebuild above already produced the v4 table.
      if (from == 3) await _addStockPlanning(m);
    },
    beforeOpen: (details) async {
      // SQLite ships with FK enforcement off; cascades depend on it.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// v3: the dose amount moves from medicines to each reminder, so one
  /// medicine can be 2 tablets at 08:00 and 1 at 14:00. Existing reminders
  /// inherit their medicine's amount; then medicines is rebuilt without the
  /// column (SQLite can't DROP a column a CHECK constraint refers to).
  Future<void> _moveDoseAmountToReminders(Migrator m) async {
    await m.alterTable(
      TableMigration(
        reminders,
        newColumns: [reminders.doseAmount],
        columnTransformer: {
          reminders.doseAmount: const CustomExpression<double>(
            '(SELECT dose_amount FROM medicines '
            'WHERE medicines.id = reminders.medicine_id)',
          ),
        },
      ),
    );
    // Rebuilt with the current definition, so v4's columns arrive here too.
    await m.alterTable(
      TableMigration(
        medicines,
        newColumns: [
          medicines.unitsPerStrip,
          medicines.stripsPerBox,
          medicines.refillAlertDays,
        ],
      ),
    );
    await m.createTable(appSettings);
  }

  /// v4: pack sizes and a days-based refill alert. The table is rebuilt
  /// (not ALTER ADD COLUMN) so the new CHECK constraints apply too; existing
  /// rows keep their values with the new columns empty.
  Future<void> _addStockPlanning(Migrator m) => m.alterTable(
    TableMigration(
      medicines,
      newColumns: [
        medicines.unitsPerStrip,
        medicines.stripsPerBox,
        medicines.refillAlertDays,
      ],
    ),
  );

  /// Adds [delta] (negative to consume) to a medicine's stock, clamped at
  /// zero. No-op when stock isn't tracked (null).
  Future<void> adjustMedicineStock(int medicineId, double delta) =>
      customUpdate(
        'UPDATE medicines SET stock_quantity = MAX(0, stock_quantity + ?) '
        'WHERE id = ? AND stock_quantity IS NOT NULL',
        variables: [Variable.withReal(delta), Variable.withInt(medicineId)],
        updates: {medicines},
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: AppConstants.databaseName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        // Alarm callbacks run in a background isolate and write to the same DB.
        shareAcrossIsolates: true,
      ),
    );
  }
}
