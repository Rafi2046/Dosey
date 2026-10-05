import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/file_storage_service.dart';
import '../domain/record_summary.dart';

/// Keeps record rows and their image files in sync.
class RecordsRepository {
  RecordsRepository(this._db, this._storage, {this.profileId});

  /// Whose records: only this profile's are listed, and new ones are
  /// theirs. Null = every profile.
  final int? profileId;

  final AppDatabase _db;
  final FileStorageService _storage;

  // ── Queries ───────────────────────────────────────────────────────────────

  Stream<List<RecordSummary>> watchSummaries({
    RecordType? type,
    int? doctorId,
  }) {
    final a = _db.recordAttachments;
    final pageCount = subqueryExpression<int>(
      _db.selectOnly(a)
        ..addColumns([a.id.count()])
        ..where(a.recordId.equalsExp(_db.records.id)),
    );
    final coverPath = subqueryExpression<String>(
      _db.selectOnly(a)
        ..addColumns([a.relativePath])
        ..where(a.recordId.equalsExp(_db.records.id))
        ..orderBy([OrderingTerm.asc(a.sortOrder), OrderingTerm.asc(a.id)])
        ..limit(1),
    );

    final query =
        _db.select(_db.records).join([
            leftOuterJoin(
              _db.doctors,
              _db.doctors.id.equalsExp(_db.records.doctorId),
            ),
          ])
          ..addColumns([pageCount, coverPath])
          ..orderBy([OrderingTerm.desc(_db.records.recordDate)]);
    if (profileId case final id?) {
      query.where(_db.records.profileId.equals(id));
    }
    if (type != null) query.where(_db.records.type.equalsValue(type));
    if (doctorId != null) query.where(_db.records.doctorId.equals(doctorId));

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          RecordSummary(
            record: row.readTable(_db.records),
            doctor: row.readTableOrNull(_db.doctors),
            coverPath: row.read(coverPath),
            pageCount: row.read(pageCount) ?? 0,
          ),
      ],
    );
  }

  Stream<MedicalRecord?> watchById(int id) => (_db.select(
    _db.records,
  )..where((r) => r.id.equals(id))).watchSingleOrNull();

  Stream<List<RecordAttachment>> watchAttachments(int recordId) =>
      (_db.select(_db.recordAttachments)
            ..where((a) => a.recordId.equals(recordId))
            ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
          .watch();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Copies [imagePaths] (e.g. from image_picker) into app storage and saves
  /// the record. Copied files are removed again if the insert fails.
  Future<int> create(RecordsCompanion record, List<String> imagePaths) async {
    final saved = <String>[];
    try {
      for (final path in imagePaths) {
        saved.add(await _storage.saveRecordImage(path));
      }
      return await _db.transaction(() async {
        final id = await _db
            .into(_db.records)
            .insert(
              profileId == null || record.profileId.present
                  ? record
                  : record.copyWith(profileId: Value(profileId!)),
            );
        await _insertAttachments(id, saved, startOrder: 0);
        return id;
      });
    } catch (_) {
      await _storage.deleteAll(saved);
      rethrow;
    }
  }

  Future<void> update(int id, RecordsCompanion changes) =>
      (_db.update(_db.records)..where((r) => r.id.equals(id))).write(changes);

  Future<void> addPages(int recordId, List<String> imagePaths) async {
    final saved = <String>[];
    try {
      for (final path in imagePaths) {
        saved.add(await _storage.saveRecordImage(path));
      }
      final existing = await (_db.select(
        _db.recordAttachments,
      )..where((a) => a.recordId.equals(recordId))).get();
      await _insertAttachments(recordId, saved, startOrder: existing.length);
    } catch (_) {
      await _storage.deleteAll(saved);
      rethrow;
    }
  }

  Future<void> deletePage(RecordAttachment page) async {
    await (_db.delete(
      _db.recordAttachments,
    )..where((a) => a.id.equals(page.id))).go();
    await _storage.delete(page.relativePath);
  }

  /// Deletes the record, its pages (via cascade) and their image files.
  Future<void> delete(int id) async {
    final pages = await (_db.select(
      _db.recordAttachments,
    )..where((a) => a.recordId.equals(id))).get();
    await (_db.delete(_db.records)..where((r) => r.id.equals(id))).go();
    await _storage.deleteAll(pages.map((p) => p.relativePath));
  }

  Future<void> _insertAttachments(
    int recordId,
    List<String> relativePaths, {
    required int startOrder,
  }) => _db.batch(
    (b) => b.insertAll(_db.recordAttachments, [
      for (var i = 0; i < relativePaths.length; i++)
        RecordAttachmentsCompanion.insert(
          recordId: recordId,
          relativePath: relativePaths[i],
          mimeType: const Value(AppConstants.imageMimeType),
          sortOrder: Value(startOrder + i),
        ),
    ]),
  );
}
