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
        _db.expenses,
        _db.recordAttachments,
        _db.records,
        _db.medicines,
        _db.doctors,
      ]) {
        await _db.delete(table).go();
      }
    });
    await _files.deleteRecordsFolder();
  }
}
