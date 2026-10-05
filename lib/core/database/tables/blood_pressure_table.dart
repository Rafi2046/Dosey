import 'package:drift/drift.dart';

import 'profiles_table.dart';

/// One blood pressure check the user wrote down (from any home monitor).
@DataClassName('BloodPressureReading')
@TableIndex(name: 'idx_bp_measured_at', columns: {#measuredAt})
class BloodPressureReadings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Upper number, mmHg.
  IntColumn get systolic => integer()();

  /// Lower number, mmHg.
  IntColumn get diastolic => integer()();

  /// Beats per minute, if the monitor showed it.
  IntColumn get pulse => integer().nullable()();

  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Whose this is (see [Profiles]). Last: v8 added it (ALTER TABLE appends).
  IntColumn get profileId => integer()
      .withDefault(const Constant(1))
      .references(Profiles, #id, onDelete: KeyAction.cascade)();

  @override
  List<String> get customConstraints => const [
    'CHECK (systolic BETWEEN 40 AND 300)',
    'CHECK (diastolic BETWEEN 20 AND 200)',
    'CHECK (pulse IS NULL OR pulse BETWEEN 20 AND 250)',
  ];
}
