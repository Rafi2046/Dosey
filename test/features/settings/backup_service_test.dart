import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/settings/data/backup_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  late Directory docs;
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    tmp = Directory.systemTemp.createTempSync('dosey_backup_test');
    docs = Directory(p.join(tmp.path, 'docs'))..createSync();
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db, docs);
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<void> seed() async {
    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            startDate: DateTime(2026, 10, 1),
            stockQuantity: const Value(20),
          ),
        );
    final r = await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            type: ReminderType.medicine,
            title: 'Napa',
            startAt: DateTime(2026, 10, 1, 8),
            medicineId: Value(med),
          ),
        );
    await db
        .into(db.reminderLogs)
        .insert(
          ReminderLogsCompanion.insert(
            reminderId: r,
            scheduledFor: DateTime(2026, 10, 1, 8),
            status: ReminderLogStatus.takenLate,
          ),
        );
    final record = await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            type: RecordType.prescription,
            title: 'Rx',
            recordDate: DateTime(2026, 10, 1),
          ),
        );
    await db
        .into(db.recordAttachments)
        .insert(
          RecordAttachmentsCompanion.insert(
            recordId: record,
            relativePath: 'records/rx1.jpg',
          ),
        );
    File(p.join(docs.path, 'records', 'rx1.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3, 4]);
  }

  test('backup → change everything → restore brings it all back', () async {
    await seed();
    final file = await backup.create(
      Directory(p.join(tmp.path, 'out')),
      now: DateTime(2026, 10, 5),
    );
    expect(p.basename(file.path), 'Dosey-backup-2026-10-05.dosey');

    // After the backup: a new medicine, the old one deleted, photo gone.
    await db.delete(db.medicines).go();
    await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(name: 'Other', startDate: DateTime(2026)),
        );
    File(p.join(docs.path, 'records', 'rx1.jpg')).deleteSync();
    File(p.join(docs.path, 'records', 'stray.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync([9]);

    await backup.restore(
      file.readAsBytesSync(),
      workDir: Directory(p.join(tmp.path, 'work')),
    );

    expect((await db.select(db.medicines).get()).map((m) => m.name), ['Napa']);
    expect((await db.select(db.reminders).getSingle()).title, 'Napa');
    expect(
      (await db.select(db.reminderLogs).getSingle()).status,
      ReminderLogStatus.takenLate,
    );
    expect(
      (await db.select(db.recordAttachments).getSingle()).relativePath,
      'records/rx1.jpg',
    );
    expect(File(p.join(docs.path, 'records', 'rx1.jpg')).readAsBytesSync(), [
      1,
      2,
      3,
      4,
    ]);
    expect(
      File(p.join(docs.path, 'records', 'stray.jpg')).existsSync(),
      isFalse,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    // New rows keep working after the restore (ids continue).
    await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(name: 'Seclo', startDate: DateTime(2026)),
        );
    expect(await db.select(db.medicines).get(), hasLength(2));
  });

  test('a file that is not a backup is refused and nothing changes', () async {
    await seed();
    await expectLater(
      backup.restore([1, 2, 3], workDir: tmp),
      throwsA(
        isA<RestoreException>().having(
          (e) => e.error,
          'error',
          RestoreError.notABackup,
        ),
      ),
    );
    expect(await db.select(db.medicines).get(), hasLength(1));
  });

  test('a backup from a newer Dosey is refused', () async {
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({'app': 'dosey', 'schemaVersion': 999}),
        ),
      )
      ..addFile(ArchiveFile.bytes('dosey.sqlite', [0]));
    await expectLater(
      backup.restore(ZipEncoder().encodeBytes(archive), workDir: tmp),
      throwsA(
        isA<RestoreException>().having(
          (e) => e.error,
          'error',
          RestoreError.tooNew,
        ),
      ),
    );
  });

  test('entries pointing outside the records folder are ignored', () async {
    await seed();
    final file = await backup.create(Directory(p.join(tmp.path, 'out')));
    final archive = ZipDecoder().decodeBytes(file.readAsBytesSync())
      ..addFile(ArchiveFile.bytes('records/../../evil.txt', [6, 6, 6]));
    await backup.restore(
      ZipEncoder().encodeBytes(archive),
      workDir: Directory(p.join(tmp.path, 'work')),
    );
    expect(File(p.join(tmp.path, 'evil.txt')).existsSync(), isFalse);
  });
}
