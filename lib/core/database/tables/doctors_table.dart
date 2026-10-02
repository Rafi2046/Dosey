import 'package:drift/drift.dart';

@DataClassName('Doctor')
class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get specialty => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get clinic => text().nullable()();
  TextColumn get address => text().nullable()();

  /// Stored in minor units (e.g. cents/paisa) to avoid floating-point drift.
  IntColumn get consultationFeeMinor => integer().nullable()();
  TextColumn get notes => text().nullable()();

  /// Archived doctors are hidden from pickers but keep their history intact.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
