import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/expenses_providers.dart';
import 'expense_form_screen.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/expense_summary_widget.dart';
import 'widgets/expense_tile.dart';
import 'widgets/medicine_cost_breakdown.dart';
import 'widgets/month_switcher.dart';

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
    final total = ref.watch(monthExpenseTotalProvider).value ?? 0;
    final projection = ref.watch(medicineCostProjectionProvider);
    final categories = ref.watch(monthCategoryTotalsProvider).value ?? const {};
    final expenses = ref.watch(monthExpensesProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: AppSpacing.screenPadding.add(AppSpacing.listBottomPadding),
        children: [
          const ScreenHeader(title: ExpenseStrings.expensesTitle),
          MonthSwitcher(
            month: month,
            onPrevious: monthNotifier.previous,
            onNext: monthNotifier.next,
          ),
          AppSpacing.gapLg,
          ExpenseSummaryWidget(
            spentMinor: total,
            projectedMonthlyMinor: projection.value?.monthlyMinor ?? 0,
            projectedDailyMinor: projection.value?.dailyMinor ?? 0,
          ),
          if (categories.isNotEmpty) ...[
            const SectionHeader(title: ExpenseStrings.byCategory),
            CategoryBreakdown(totals: categories),
          ],
          const SectionHeader(title: ExpenseStrings.medicineCosts),
          AsyncValueView(
            value: projection,
            data: (p) => MedicineCostBreakdown(projection: p),
          ),
          SectionHeader(
            title: ExpenseStrings.expenses,
            actionLabel: AppStrings.add,
            onAction: () => _openForm(context),
          ),
          AsyncValueView(
            value: expenses,
            data: (list) => list.isEmpty
                ? const EmptyState(
                    title: ExpenseStrings.noExpenses,
                    image: AppImages.medTablet,
                  )
                : Column(
                    children: [
                      for (final e in list)
                        ExpenseTile(
                          expense: e,
                          onTap: () => _openForm(
                            context,
                            ExpenseFormScreen(existing: e),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
