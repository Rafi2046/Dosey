import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/constants.dart';
import '../../core/database/app_database.dart';
import '../../core/widgets/pill_button.dart';
import '../../features/medicines/providers/medicines_providers.dart';
import '../../features/reminders/providers/reminders_providers.dart';

/// Debug-only: creates a medicine + one-shot critical reminder at the next-but-
/// one minute, to exercise the whole alarm pipeline on a real device.
class DebugTestAlarmButton extends ConsumerWidget {
  const DebugTestAlarmButton({super.key});

  static const Duration _lead = Duration(minutes: 2);

  Future<void> _schedule(
    WidgetRef ref,
    ScaffoldMessengerState messenger,
  ) async {
    final now = DateTime.now();
    final at = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(_lead);
    final medicineId = await ref
        .read(medicinesRepositoryProvider)
        .create(
          MedicinesCompanion.insert(
            name: AppStrings.debugTestAlarmTitle,
            startDate: now,
            mealRelation: const Value(MealRelation.afterMeal),
          ),
        );
    await ref
        .read(remindersRepositoryProvider)
        .create(
          RemindersCompanion.insert(
            type: ReminderType.medicine,
            title: AppStrings.debugTestAlarmTitle,
            description: const Value(AppStrings.debugTestAlarmBody),
            startAt: at,
            medicineId: Value(medicineId),
          ),
        );
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.debugTestAlarmScheduled)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillButton(
      label: AppStrings.debugTestAlarm,
      tone: PillButtonTone.cream,
      trailingIcon: Icons.alarm_add_rounded,
      onPressed: () => _schedule(ref, ScaffoldMessenger.of(context)),
    );
  }
}
