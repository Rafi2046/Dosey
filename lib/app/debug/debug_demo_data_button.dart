import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/widgets/pill_button.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/blood_pressure/providers/blood_pressure_providers.dart';
import '../../features/blood_sugar/providers/blood_sugar_providers.dart';
import '../../features/doctors/providers/doctors_providers.dart';
import '../../features/expenses/providers/expenses_providers.dart';
import '../../features/family_sharing/providers/shared_adherence_providers.dart';
import '../../features/medicines/providers/medicines_providers.dart';
import '../../features/profiles/providers/profiles_providers.dart';
import '../../features/records/providers/records_providers.dart';
import '../../features/reminders/providers/reminders_providers.dart';
import '../../features/settings/providers/settings_providers.dart';
import 'demo_data_seeder.dart';
import '../../core/localization/l10n.dart';

/// Debug-only: fills the app with realistic sample data.
class DebugDemoDataButton extends ConsumerWidget {
  const DebugDemoDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillButton(
      label: context.l10n.debugLoadDemo,
      tone: PillButtonTone.cream,
      trailingIcon: Icons.dataset_rounded,
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final loaded = context.l10n.debugDemoLoaded;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        await DemoDataSeeder.seed(
          ref.read(appDatabaseProvider),
          ref.read(remindersRepositoryProvider),
          ref.read(recordsRepositoryProvider),
        );

        ref.invalidate(todayScheduleProvider);
        ref.invalidate(remindersProvider);
        ref.invalidate(enabledRemindersProvider);
        ref.invalidate(upcomingRemindersProvider);
        ref.invalidate(missedDosesProvider);
        ref.invalidate(medicinesProvider);
        ref.invalidate(activeMedicinesProvider);
        ref.invalidate(doctorsWithStatsProvider);
        ref.invalidate(recordSummariesProvider);
        ref.invalidate(bloodPressureReadingsProvider);
        ref.invalidate(bloodSugarReadingsProvider);
        ref.invalidate(monthExpensesProvider);
        ref.invalidate(monthExpenseTotalProvider);
        ref.invalidate(monthCategoryTotalsProvider);
        ref.invalidate(expenseTrendProvider);
        ref.invalidate(medicineCostProjectionProvider);
        ref.invalidate(currentMonthExpenseTotalProvider);
        ref.invalidate(profilesProvider);
        ref.invalidate(userNameProvider);

        final user = ref.read(currentUserProvider);
        if (user != null) {
          final schedule = await ref.read(todayScheduleProvider.future);
          if (schedule.isNotEmpty) {
            final repo = ref.read(sharedAdherenceRepositoryProvider);
            await repo.syncTodaySchedule(
              patientUid: user.uid,
              patientName: user.displayName ?? user.email?.split('@').first,
              occurrences: schedule,
            );
          }
        }

        messenger.showSnackBar(SnackBar(content: Text(loaded)));
      },
    );
  }
}

