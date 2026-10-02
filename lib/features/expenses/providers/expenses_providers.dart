import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../data/expenses_repository.dart';
import '../domain/medicine_cost_projection.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>(
  (ref) => ExpensesRepository(ref.watch(appDatabaseProvider)),
);

/// First day of the month shown on the expenses screen.
final expenseMonthProvider = NotifierProvider<ExpenseMonth, DateTime>(
  ExpenseMonth.new,
);

class ExpenseMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);
  void next() => state = DateTime(state.year, state.month + 1);
}

(DateTime, DateTime) _monthRange(DateTime month) =>
    (month, DateTime(month.year, month.month + 1));

final monthExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final (start, end) = _monthRange(ref.watch(expenseMonthProvider));
  return ref.watch(expensesRepositoryProvider).watchBetween(start, end);
});

final monthExpenseTotalProvider = StreamProvider<int>((ref) {
  final (start, end) = _monthRange(ref.watch(expenseMonthProvider));
  return ref.watch(expensesRepositoryProvider).watchTotal(start, end);
});

final monthCategoryTotalsProvider = StreamProvider<Map<ExpenseCategory, int>>((
  ref,
) {
  final (start, end) = _monthRange(ref.watch(expenseMonthProvider));
  return ref
      .watch(expensesRepositoryProvider)
      .watchTotalsByCategory(start, end);
});

final _activeMedicinesRawProvider = StreamProvider<List<Medicine>>(
  (ref) => ref.watch(medicinesRepositoryProvider).watchActiveRaw(),
);

/// Projected cost of the medicines currently being taken.
final medicineCostProjectionProvider = FutureProvider<MedicineCostProjection>((
  ref,
) async {
  final medicines = await ref.watch(_activeMedicinesRawProvider.future);
  final reminders = await ref.watch(enabledRemindersProvider.future);
  return MedicineCostProjection.from(
    activeMedicines: medicines,
    reminders: [for (final r in reminders) r.reminder],
  );
});
