import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/reminder_alarm_engine.dart';
import '../../../core/storage/file_storage_service.dart';
import '../../reminders/data/reminders_repository.dart';

/// Settings › Delete all data: wipes everything the user entered on this
/// phone. App preferences (language, theme, onboarding) are kept.
class DataResetService {
  DataResetService(this._db, this._reminders, this._engine, this._files);

  final AppDatabase _db;
  final RemindersRepository _reminders;
  final ReminderAlarmEngine _engine;
  final FileStorageService _files;

  Future<void> deleteAll() async {
    // Alarms first: OS alarms and notifications outlive database rows.
    for (final r in await _reminders.getAll()) {
      await _engine.cancel(r.id);
    }
    await _db.transaction(() async {
      // Children before parents (cascades would cover most of it anyway).
      for (final table in <TableInfo<Table, dynamic>>[
        _db.reminderLogs,
        _db.reminders,
        _db.bloodPressureReadings,
        _db.bloodSugarReadings,
        _db.expenses,
        _db.recordAttachments,
        _db.records,
        _db.medicines,
        _db.doctors,
      ]) {
        await _db.delete(table).go();
      }
      // Family profiles go too; the user's own stays, unnamed again.
      await (_db.delete(_db.profiles)..where((p) => p.id.isNotValue(1))).go();
      await (_db.update(_db.profiles)..where((p) => p.id.equals(1))).write(
        const ProfilesCompanion(name: Value('')),
      );
    });
    await _files.deleteRecordsFolder();
  }
}
