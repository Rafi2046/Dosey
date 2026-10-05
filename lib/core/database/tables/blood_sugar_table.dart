import 'package:drift/drift.dart';

import '../enums.dart';
import 'profiles_table.dart';

/// One blood sugar (glucose) check the user wrote down from a glucometer.
@DataClassName('BloodSugarReading')
@TableIndex(name: 'idx_sugar_measured_at', columns: {#measuredAt})
class BloodSugarReadings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// mmol/L (what glucometers and labs in Bangladesh show).
  RealColumn get mmol => real()();

  /// When it was taken relative to food; decides what's "in range".
  TextColumn get context => textEnum<SugarContext>()();

  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Whose this is (see [Profiles]). Last: v8 added it (ALTER TABLE appends).
  IntColumn get profileId => integer()
      .withDefault(const Constant(1))
      .references(Profiles, #id, onDelete: KeyAction.cascade)();

  @override
  List<String> get customConstraints => const [
    'CHECK (mmol BETWEEN 1.0 AND 35.0)',
  ];
}
