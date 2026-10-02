import 'package:drift/drift.dart';

import '../enums.dart';
import 'doctors_table.dart';
import 'records_table.dart';

@DataClassName('Medicine')
@TableIndex(name: 'idx_medicines_doctor', columns: {#doctorId})
@TableIndex(name: 'idx_medicines_active', columns: {#isActive})
class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Free-form strength, e.g. "500 mg" or "5 mg/5 ml".
  TextColumn get strength => text().nullable()();
  TextColumn get form =>
      textEnum<MedicineForm>().withDefault(Constant(MedicineForm.tablet.name))();

  /// Units consumed per dose (1 tablet, 5 ml, 2 puffs...).
  RealColumn get doseAmount => real().withDefault(const Constant(1))();
  TextColumn get doseUnit => text().withDefault(const Constant('tablet'))();
  TextColumn get mealRelation => textEnum<MealRelation>()
      .withDefault(Constant(MealRelation.anytime.name))();

  /// Prescribing doctor.
  IntColumn get doctorId => integer()
      .nullable()
      .references(Doctors, #id, onDelete: KeyAction.setNull)();

  /// The prescription document this medicine came from.
  IntColumn get prescriptionId => integer()
      .nullable()
      .references(Records, #id, onDelete: KeyAction.setNull)();

  /// Price of ONE unit (one tablet / one ml) in minor units. Projected cost is
  /// unitPriceMinor × doseAmount × doses per period (from [Reminders]).
  IntColumn get unitPriceMinor => integer().withDefault(const Constant(0))();
  RealColumn get stockQuantity => real().nullable()();
  RealColumn get refillThreshold => real().nullable()();

  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
        'CHECK (dose_amount > 0)',
        'CHECK (unit_price_minor >= 0)',
      ];
}
