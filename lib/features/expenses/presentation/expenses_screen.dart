import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../providers/expenses_providers.dart';
import 'expense_form_screen.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/expense_hero_card.dart';
import 'widgets/expense_tile.dart';
import 'widgets/medicine_cost_breakdown.dart';
import 'widgets/month_switcher.dart';
import '../../../core/localization/l10n.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _openForm(BuildContext context, [ExpenseFormScreen? screen]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => screen ?? const ExpenseFormScreen(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(expenseMonthProvider);
    final monthNotifier = ref.read(expenseMonthProvider.notifier);
    final trend = ref.watch(expenseTrendProvider).value ?? const [];
    final projection = ref.watch(medicineCostProjectionProvider);
    final categories = ref.watch(monthCategoryTotalsProvider).value ?? const {};
    final expenses = ref.watch(monthExpensesProvider);

    return TabScrollView(
      // No expenses this month: centre the empty state in the space left.
      centerLast: expenses.value?.isEmpty ?? false,
      children: [
        ScreenHeader(title: context.l10n.expensesTitle),
        MonthSwitcher(
          month: month,
          onPrevious: monthNotifier.previous,
          onNext: monthNotifier.next,
        ),
        AppSpacing.gapLg,
        ExpenseHeroCard(
          month: month,
          trend: trend,
          projectedMonthlyMinor: projection.value?.monthlyMinor ?? 0,
          projectedDailyMinor: projection.value?.dailyMinor ?? 0,
        ),
        if (categories.isNotEmpty) ...[
          SectionHeader(title: context.l10n.byCategory),
          CategoryBreakdown(totals: categories),
        ],
        SectionHeader(title: context.l10n.medicineCosts),
        AsyncValueView(
          value: projection,
          data: (p) => MedicineCostBreakdown(projection: p),
        ),
        SectionHeader(
          title: context.l10n.expenses,
          actionLabel: (expenses.value?.isEmpty ?? true)
              ? null
              : context.l10n.add,
          onAction: () => _openForm(context),
        ),
        AsyncValueView(
          value: expenses,
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.l10n.noExpenses,
                  message: context.l10n.expensesEmptyBody,
                  image: AppImages.medOther,
                  actionLabel: context.l10n.addExpense,
                  onAction: () => _openForm(context),
                )
              : Column(
                  children: [
                    for (final e in list)
                      ExpenseTile(
                        expense: e,
                        onTap: () =>
                            _openForm(context, ExpenseFormScreen(existing: e)),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
