import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock_providers.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../expenses/presentation/widgets/expense_summary_widget.dart';
import '../../expenses/providers/expenses_providers.dart';
import '../../reminders/presentation/reminder_form_screen.dart';
import '../../blood_pressure/providers/blood_pressure_providers.dart';
import '../../blood_sugar/providers/blood_sugar_providers.dart';
import '../../family_sharing/presentation/widgets/caregiver_monitoring_card.dart';
import '../../family_sharing/providers/family_share_providers.dart';
import '../../family_sharing/providers/shared_adherence_providers.dart';
import 'widgets/animated_dashboard_title.dart';
import 'widgets/blood_pressure_section.dart';
import 'widgets/blood_sugar_section.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/low_stock_section.dart';
import 'widgets/missed_doses_card.dart';
import 'widgets/today_reminder_stack.dart';
import 'widgets/upcoming_events_section.dart';
import '../../../core/localization/l10n.dart';

/// Home: missed doses, today's stacked reminders, cost summary, low stock and upcoming
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
    // Keep shared adherence sync alive for patient
    ref.watch(sharedAdherenceAutoSyncProvider);

    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();
    final spent = ref.watch(currentMonthExpenseTotalProvider).value ?? 0;
    final projection = ref.watch(medicineCostProjectionProvider).value;

    return TabScrollView(
      // Everything below the greeting, profile and title shimmers while
      // refreshing.
      refreshFrom: 3,
      onRefresh: () async {
        ref.invalidate(todayScheduleProvider);
        ref.invalidate(missedDosesProvider);
        ref.invalidate(activeMedicinesProvider);
        ref.invalidate(remindersProvider);
        ref.invalidate(caregiverSharesProvider);
        ref.invalidate(currentMonthExpenseTotalProvider);
        ref.invalidate(medicineCostProjectionProvider);
        ref.invalidate(bloodPressureReadingsProvider);
        ref.invalidate(bloodSugarReadingsProvider);
      },
      children: [
        DashboardHeader(
          now: now,
          name: ref.watch(userNameProvider).value,
          onBellTap: onOpenReminders,
        ),
        AnimatedDashboardTitle(
          title: context.l10n.dashboardTitle,
        ),
        const MissedDosesCard(),
        // Caregiver active monitoring card (if monitoring a linked family member)
        const CaregiverMonitoringCard(),
        TodayReminderStack(
          onAddReminder: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ReminderFormScreen()),
          ),
        ),
        const LowStockSection(),
        const BloodPressureSection(),
        const BloodSugarSection(),
        UpcomingEventsSection(onSeeAll: onOpenReminders),
        SectionHeader(
          title: context.l10n.medicineCost,
          actionLabel: context.l10n.seeAll,
          onAction: onOpenExpenses,
        ),
        ExpenseSummaryWidget(
          spentMinor: spent,
          projectedMonthlyMinor: projection?.monthlyMinor ?? 0,
          projectedDailyMinor: projection?.dailyMinor ?? 0,
          onTap: onOpenExpenses,
        ),
      ],
    );
  }
}
