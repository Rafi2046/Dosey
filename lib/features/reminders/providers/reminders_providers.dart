import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock_providers.dart';
import '../data/reminders_repository.dart';
import '../domain/reminder_schedule.dart';
import '../domain/reminder_with_details.dart';
import '../domain/scheduled_occurrence.dart';

final remindersRepositoryProvider = Provider<RemindersRepository>(
  (ref) => RemindersRepository(ref.watch(appDatabaseProvider)),
);

final remindersProvider = StreamProvider<List<ReminderWithDetails>>(
  (ref) => ref.watch(remindersRepositoryProvider).watchAll(),
);

final enabledRemindersProvider = StreamProvider<List<ReminderWithDetails>>(
  (ref) => ref.watch(remindersRepositoryProvider).watchEnabled(),
);

final upcomingRemindersProvider = StreamProvider<List<ReminderWithDetails>>(
  (ref) => ref.watch(remindersRepositoryProvider).watchUpcoming(),
);

/// Occurrences ringing right now; drives the full-screen alarm screen.
final ringingRemindersProvider = StreamProvider<List<ReminderWithDetails>>(
  (ref) => ref.watch(remindersRepositoryProvider).watchRinging(),
);

final remindersByMedicineProvider = StreamProvider.autoDispose
    .family<List<ReminderWithDetails>, int>(
      (ref, medicineId) =>
          ref.watch(remindersRepositoryProvider).watchByMedicine(medicineId),
    );

final _logsForDayProvider = StreamProvider.autoDispose
    .family<List<ReminderLog>, DateTime>(
      (ref, day) => ref
          .watch(remindersRepositoryProvider)
          .watchLogsBetween(day, DateTime(day.year, day.month, day.day + 1)),
    );

/// Every occurrence due today, in time order, with its taken/skipped status.
final todayScheduleProvider = FutureProvider<List<ScheduledOccurrence>>((
  ref,
) async {
  final day = await ref.watch(currentDayProvider.future);
  final reminders = await ref.watch(enabledRemindersProvider.future);
  final logs = await ref.watch(_logsForDayProvider(day).future);

  final statusByKey = {
    for (final log in logs) (log.reminderId, log.scheduledFor): log.status,
  };

  return [
    for (final details in reminders)
      for (final at in ReminderSchedule.occurrencesOn(details.reminder, day))
        ScheduledOccurrence(
          details: details,
          at: at,
          status: statusByKey[(details.reminder.id, at)],
        ),
  ]..sort((a, b) => a.at.compareTo(b.at));
});

/// Type filter on the reminders screen (null = all).
final reminderTypeFilterProvider =
    NotifierProvider<ReminderTypeFilter, ReminderType?>(ReminderTypeFilter.new);

class ReminderTypeFilter extends Notifier<ReminderType?> {
  @override
  ReminderType? build() => null;

  void select(ReminderType? type) => state = type;
}

final filteredRemindersProvider =
    Provider<AsyncValue<List<ReminderWithDetails>>>((ref) {
      final type = ref.watch(reminderTypeFilterProvider);
      return ref
          .watch(remindersProvider)
          .whenData(
            (list) => type == null
                ? list
                : list.where((d) => d.reminder.type == type).toList(),
          );
    });

/// Upcoming appointments, vaccines and tests (not daily medicine doses).
final upcomingEventsProvider = Provider<AsyncValue<List<ReminderWithDetails>>>(
  (ref) => ref
      .watch(upcomingRemindersProvider)
      .whenData(
        (list) => list
            .where((d) => d.reminder.type != ReminderType.medicine)
            .toList(),
      ),
);

final remindersByDoctorProvider = Provider.autoDispose
    .family<AsyncValue<List<ReminderWithDetails>>, int>(
      (ref, doctorId) => ref
          .watch(remindersProvider)
          .whenData(
            (list) =>
                list.where((d) => d.reminder.doctorId == doctorId).toList(),
          ),
    );
