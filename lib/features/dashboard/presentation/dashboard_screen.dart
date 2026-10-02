import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/clock_providers.dart';
import '../../../core/widgets/section_header.dart';
import '../../expenses/presentation/widgets/expense_summary_widget.dart';
import '../../expenses/providers/expenses_providers.dart';
import '../../reminders/presentation/reminder_form_screen.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/low_stock_section.dart';
import 'widgets/today_reminder_stack.dart';
import 'widgets/upcoming_events_section.dart';

/// Home: today's stacked reminders, cost summary, low stock and upcoming
/// appointments. Tab switching is delegated to the shell via callbacks.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenReminders,
    required this.onOpenExpenses,
  });

  final VoidCallback onOpenReminders;
  final VoidCallback onOpenExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();
    final spent = ref.watch(currentMonthExpenseTotalProvider).value ?? 0;
    final projection = ref.watch(medicineCostProjectionProvider).value;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: AppSpacing.screenPadding.add(AppSpacing.listBottomPadding),
        children: [
          DashboardHeader(now: now, onBellTap: onOpenReminders),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              AppStrings.dashboardTitle,
              style: AppTextStyles.display,
            ),
          ),
          TodayReminderStack(
            onAddReminder: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ReminderFormScreen(),
              ),
            ),
          ),
          const LowStockSection(),
          UpcomingEventsSection(onSeeAll: onOpenReminders),
          SectionHeader(
            title: AppStrings.medicineCost,
            actionLabel: AppStrings.seeAll,
            onAction: onOpenExpenses,
          ),
          ExpenseSummaryWidget(
            spentMinor: spent,
            projectedMonthlyMinor: projection?.monthlyMinor ?? 0,
            projectedDailyMinor: projection?.dailyMinor ?? 0,
            onTap: onOpenExpenses,
          ),
        ],
      ),
    );
  }
}
