import 'package:drift/drift.dart';

import '../enums.dart';
import 'doctors_table.dart';

/// A medical document: prescription, test report, vaccine card, invoice...
/// The images themselves live in [RecordAttachments] (one record can span pages).
@DataClassName('MedicalRecord')
@TableIndex(name: 'idx_records_doctor', columns: {#doctorId})
@TableIndex(name: 'idx_records_type_date', columns: {#type, #recordDate})
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<RecordType>()();
  TextColumn get title => text().withLength(min: 1, max: 160)();
  IntColumn get doctorId => integer()
      .nullable()
      .references(Doctors, #id, onDelete: KeyAction.setNull)();

  /// Date printed on the document (not the upload date).
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('RecordAttachment')
@TableIndex(name: 'idx_attachments_record', columns: {#recordId})
class RecordAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordId => integer()
      .references(Records, #id, onDelete: KeyAction.cascade)();

  /// Path relative to the app documents directory. Never store absolute paths:
  /// the iOS container path changes between app updates.
  TextColumn get relativePath => text()();
  TextColumn get mimeType => text().withDefault(const Constant('image/jpeg'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
