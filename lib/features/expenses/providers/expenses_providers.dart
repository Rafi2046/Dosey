import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock_providers.dart';
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

/// Always the current calendar month (dashboard), independent of the month
/// selected on the expenses screen.
final currentMonthExpenseTotalProvider = StreamProvider<int>((ref) {
  final day = ref.watch(currentDayProvider).value ?? DateTime.now();
  final (start, end) = _monthRange(DateTime(day.year, day.month));
  return ref.watch(expensesRepositoryProvider).watchTotal(start, end);
});

/// Spending per month for the trend chart: the selected month and the ones
/// before it, oldest first.
final expenseTrendProvider = StreamProvider<List<(DateTime, int)>>((ref) {
  final month = ref.watch(expenseMonthProvider);
  final months = [
    for (var i = AppConstants.expenseTrendMonths - 1; i >= 0; i--)
      DateTime(month.year, month.month - i),
  ];
  final (_, end) = _monthRange(month);
  return ref
      .watch(expensesRepositoryProvider)
      .watchBetween(months.first, end)
      .map((expenses) {
        final totals = {for (final m in months) m: 0};
        for (final e in expenses) {
          final m = DateTime(e.spentOn.year, e.spentOn.month);
          totals[m] = (totals[m] ?? 0) + e.amountMinor;
        }
        return [for (final m in months) (m, totals[m]!)];
      });
});
