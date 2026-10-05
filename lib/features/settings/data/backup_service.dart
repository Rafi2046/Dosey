import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

/// Why a file couldn't be restored.
enum RestoreError {
  /// Not a Dosey backup (or damaged).
  notABackup,

  /// Made by a newer Dosey than this one: update the app first.
  tooNew,
}

class RestoreException implements Exception {
  const RestoreException(this.error);
  final RestoreError error;

  @override
  String toString() => 'RestoreException(${error.name})';
}

/// Everything the user has, in one file they can keep anywhere (Drive,
/// Files, WhatsApp…): a copy of the database plus the record photos, as a
/// zip with a small manifest. Restoring replaces all current data.
class BackupService {
  BackupService(this._db, this._documents);

  final AppDatabase _db;

  /// App documents directory; record photos live under
  /// [AppConstants.recordsFolder] in it (paths in the DB are relative).
  final Directory _documents;

  static const String fileExtension = '.dosey';
  static const String _manifestEntry = 'manifest.json';
  static const String _databaseEntry = 'dosey.sqlite';
  static const String _app = 'dosey';

  /// "Dosey-backup-2026-10-05.dosey"
  static String fileNameFor(DateTime at) =>
      'Dosey-backup-${DateFormat('yyyy-MM-dd').format(at)}$fileExtension';

  /// Writes a backup into [outDir] and returns the file.
  Future<File> create(Directory outDir, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    // File work is synchronous on purpose: small files, done once, and it
    // keeps the steps in order with the database calls in between.
    outDir.createSync(recursive: true);
    final snapshot = File(p.join(outDir.path, 'dosey-snapshot.sqlite'));
    if (snapshot.existsSync()) snapshot.deleteSync();
    // A consistent copy of the live database, even while it's in use.
    await _db.customStatement('VACUUM INTO ?', [snapshot.path]);

    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          _manifestEntry,
          jsonEncode({
            'app': _app,
            'schemaVersion': _db.schemaVersion,
            'createdAt': at.toIso8601String(),
          }),
        ),
      )
      ..addFile(ArchiveFile.bytes(_databaseEntry, snapshot.readAsBytesSync()));
    snapshot.deleteSync();

    final records = Directory(
      p.join(_documents.path, AppConstants.recordsFolder),
    );
    if (records.existsSync()) {
      for (final f in records.listSync(recursive: true).whereType<File>()) {
        // Stored with forward slashes so a backup moves between platforms.
        final name = p.posix.joinAll(
          p.split(p.relative(f.path, from: _documents.path)),
        );
        archive.addFile(ArchiveFile.bytes(name, f.readAsBytesSync()));
      }
    }

    final out = File(p.join(outDir.path, fileNameFor(at)));
    out.writeAsBytesSync(ZipEncoder().encodeBytes(archive), flush: true);
    return out;
  }

  /// Replaces all data with the backup in [bytes]. Throws
  /// [RestoreException] if it isn't a usable backup; nothing is changed then.
  /// Older backups are upgraded to the current schema first.
  Future<void> restore(List<int> bytes, {required Directory workDir}) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const RestoreException(RestoreError.notABackup);
    }
    final manifest = archive.findFile(_manifestEntry);
    final database = archive.findFile(_databaseEntry);
    if (manifest == null || database == null) {
      throw const RestoreException(RestoreError.notABackup);
    }
    final Map<String, dynamic> info;
    try {
      info = jsonDecode(utf8.decode(manifest.content)) as Map<String, dynamic>;
    } on Object {
      throw const RestoreException(RestoreError.notABackup);
    }
    final version = info['schemaVersion'];
    if (info['app'] != _app || version is! int) {
      throw const RestoreException(RestoreError.notABackup);
    }
    if (version > _db.schemaVersion) {
      throw const RestoreException(RestoreError.tooNew);
    }

    workDir.createSync(recursive: true);
    final incoming = File(p.join(workDir.path, 'dosey-restore.sqlite'));
    if (incoming.existsSync()) incoming.deleteSync();
    incoming.writeAsBytesSync(database.content, flush: true);
    // Opening it runs the normal migrations, so an older backup arrives
    // with exactly the current tables and columns.
    final upgraded = AppDatabase(NativeDatabase(incoming));
    try {
      await upgraded.customSelect('SELECT 1').get();
    } on Object {
      await upgraded.close();
      incoming.deleteSync();
      throw const RestoreException(RestoreError.notABackup);
    }
    await upgraded.close();

    await _copyAllTables(from: incoming);
    incoming.deleteSync();
    _replaceRecordFiles(archive);
  }

  /// Swaps every table's rows for the backup's, all or nothing.
  Future<void> _copyAllTables({required File from}) async {
    // Rows are copied in any order; keys are consistent within the backup.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    await _db.customStatement('ATTACH DATABASE ? AS backup', [from.path]);
    try {
      await _db.transaction(() async {
        for (final table in _db.allTables) {
          final name = table.actualTableName;
          await _db.customStatement('DELETE FROM main."$name"');
          await _db.customStatement(
            'INSERT INTO main."$name" SELECT * FROM backup."$name"',
          );
        }
      });
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    // Raw SQL bypasses drift's change tracking: refresh every open query.
    _db.markTablesUpdated(_db.allTables);
  }

  void _replaceRecordFiles(Archive archive) {
    final records = Directory(
      p.join(_documents.path, AppConstants.recordsFolder),
    );
    if (records.existsSync()) records.deleteSync(recursive: true);
    for (final entry in archive.files) {
      if (!entry.isFile ||
          !entry.name.startsWith('${AppConstants.recordsFolder}/')) {
        continue;
      }
      // Refuse anything that would land outside the records folder.
      final target = p.normalize(
        p.joinAll([_documents.path, ...p.posix.split(entry.name)]),
      );
      if (!p.isWithin(records.path, target)) continue;
      final file = File(target);
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(entry.content, flush: true);
    }
  }
}
