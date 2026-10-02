import 'package:drift/drift.dart';

import '../enums.dart';
import 'doctors_table.dart';
import 'medicines_table.dart';
import 'records_table.dart';

/// Actual money spent. Projected medicine cost is derived from
/// [Medicines.unitPriceMinor] + reminders, not stored here.
@DataClassName('Expense')
@TableIndex(name: 'idx_expenses_spent_on', columns: {#spentOn})
@TableIndex(name: 'idx_expenses_medicine', columns: {#medicineId})
@TableIndex(name: 'idx_expenses_doctor', columns: {#doctorId})
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => textEnum<ExpenseCategory>()();
  TextColumn get title => text().withLength(min: 1, max: 160)();

  /// Minor units (cents/paisa). Currency is an app-level setting.
  IntColumn get amountMinor => integer()();
  RealColumn get quantity => real().nullable()();

  IntColumn get medicineId => integer()
      .nullable()
      .references(Medicines, #id, onDelete: KeyAction.setNull)();
  IntColumn get doctorId => integer()
      .nullable()
      .references(Doctors, #id, onDelete: KeyAction.setNull)();

  /// Receipt / invoice image.
  IntColumn get receiptRecordId => integer()
      .nullable()
      .references(Records, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get spentOn => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['CHECK (amount_minor >= 0)'];
}
