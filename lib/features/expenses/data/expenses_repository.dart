import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Ranges are half-open: [start, end).
class ExpensesRepository {
  ExpensesRepository(this._db);

  final AppDatabase _db;

  Expression<bool> _inRange(DateTime start, DateTime end) =>
      _db.expenses.spentOn.isBiggerOrEqualValue(start) &
      _db.expenses.spentOn.isSmallerThanValue(end);

  Stream<List<Expense>> watchBetween(DateTime start, DateTime end) =>
      (_db.select(_db.expenses)
            ..where((_) => _inRange(start, end))
            ..orderBy([
              (e) => OrderingTerm.desc(e.spentOn),
              (e) => OrderingTerm.desc(e.id),
            ]))
          .watch();

  Stream<int> watchTotal(DateTime start, DateTime end) {
    final sum = _db.expenses.amountMinor.sum();
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([sum])
      ..where(_inRange(start, end));
    return query.watchSingle().map((row) => row.read(sum) ?? 0);
  }

  Stream<Map<ExpenseCategory, int>> watchTotalsByCategory(
    DateTime start,
    DateTime end,
  ) {
    final category = _db.expenses.category;
    final sum = _db.expenses.amountMinor.sum();
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([category, sum])
      ..where(_inRange(start, end))
      ..groupBy([category]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          ExpenseCategory.values.byName(row.read(category)!):
              row.read(sum) ?? 0,
      },
    );
  }

  Future<int> create(ExpensesCompanion expense) =>
      _db.into(_db.expenses).insert(expense);

  Future<void> update(int id, ExpensesCompanion changes) =>
      (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(changes);

  Future<void> delete(int id) =>
      (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
}
