import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'enums.dart';
import 'tables/blood_pressure_table.dart';
import 'tables/blood_sugar_table.dart';
import 'tables/doctors_table.dart';
import 'tables/expenses_table.dart';
import 'tables/medicines_table.dart';
import 'tables/profiles_table.dart';
import 'tables/records_table.dart';
import 'tables/reminders_table.dart';
import 'tables/settings_table.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Doctors,
    Medicines,
    Reminders,
    ReminderLogs,
    Records,
    RecordAttachments,
    Expenses,
    AppSettings,
    BloodPressureReadings,
    BloodSugarReadings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _addFirstProfile();
    },
    onUpgrade: (m, from, to) async {
      // Table rebuilds below drop and recreate tables; with FKs on, dropping
      // medicines would cascade-delete every reminder.
      await customStatement('PRAGMA foreign_keys = OFF');
      if (from < 2) await m.addColumn(reminders, reminders.ringingFor);
      if (from < 3) await _moveDoseAmountToReminders(m);
      // From v2 the v3 rebuild above already produced the v4 table.
      if (from == 3) await _addStockPlanning(m);
      // v5: blood pressure log (a new table; nothing else changes).
      if (from < 5) {
        await m.createTable(bloodPressureReadings);
        await m.createIndex(idxBpMeasuredAt);
      }
      // v6: blood sugar log (a new table; nothing else changes).
      if (from < 6) {
        await m.createTable(bloodSugarReadings);
        await m.createIndex(idxSugarMeasuredAt);
      }
      // v7: heads-up before appointments (a new nullable column). Before
      // v3 the reminders rebuild below already includes it.
      if (from >= 3 && from < 7) {
        await m.addColumn(reminders, reminders.remindBeforeMinutes);
      }
      if (from < 8) await _addProfiles(m, from);
      if (from < 9) await _addCloudSyncFields(m, from);
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
        // Rebuilt with the current definition: later columns arrive too.
        newColumns: [
          reminders.doseAmount,
          reminders.remindBeforeMinutes,
          reminders.profileId,
          reminders.cloudId,
          reminders.firebaseUid,
          reminders.familyShareCode,
        ],
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
          medicines.profileId,
          medicines.cloudId,
          medicines.firebaseUid,
          medicines.familyShareCode,
        ],
      ),
    );
    await m.createTable(appSettings);
  }

  /// v8: family profiles. Everything so far becomes profile 1's (each
  /// row's profile_id defaults to 1). Tables that an earlier step in this
  /// same upgrade rebuilt or created already have the column.
  Future<void> _addProfiles(Migrator m, int from) async {
    await m.createTable(profiles);
    await _addFirstProfile();
    if (from >= 3) await m.addColumn(reminders, reminders.profileId);
    if (from >= 4) await m.addColumn(medicines, medicines.profileId);
    await m.addColumn(records, records.profileId);
    await m.addColumn(expenses, expenses.profileId);
    if (from >= 5) {
      await m.addColumn(bloodPressureReadings, bloodPressureReadings.profileId);
    }
    if (from >= 6) {
      await m.addColumn(bloodSugarReadings, bloodSugarReadings.profileId);
    }
  }

  /// Profile 1, named after the user if they gave a name ("" shows as Me).
  Future<void> _addFirstProfile() => customStatement(
    "INSERT OR IGNORE INTO profiles (id, name) VALUES (1, COALESCE("
    "(SELECT value FROM app_settings WHERE key = 'user_name'), ''))",
  );

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
        medicines.profileId,
        medicines.cloudId,
        medicines.firebaseUid,
        medicines.familyShareCode,
      ],
    ),
  );

  /// v9: cloud sync fields (cloud_id, firebase_uid, family_share_code, updated_at).
  Future<void> _addCloudSyncFields(Migrator m, int from) async {
    if (from >= 4) {
      await m.addColumn(medicines, medicines.cloudId);
      await m.addColumn(medicines, medicines.firebaseUid);
      await m.addColumn(medicines, medicines.familyShareCode);
    }
    if (from >= 3) {
      await m.addColumn(reminders, reminders.cloudId);
      await m.addColumn(reminders, reminders.firebaseUid);
      await m.addColumn(reminders, reminders.familyShareCode);
    }
    await m.addColumn(reminderLogs, reminderLogs.cloudId);
    await m.addColumn(reminderLogs, reminderLogs.firebaseUid);
    await m.addColumn(reminderLogs, reminderLogs.updatedAt);
    await m.addColumn(reminderLogs, reminderLogs.familyShareCode);
  }

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
