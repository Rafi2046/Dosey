import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock_providers.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/reminders_repository.dart';
import '../domain/dose_history.dart';
import '../domain/missed_doses.dart';
import '../domain/reminder_schedule.dart';
import '../domain/reminder_with_details.dart';
import '../domain/scheduled_occurrence.dart';

/// The open profile's reminders (what the screens list and add to).
final remindersRepositoryProvider = Provider<RemindersRepository>(
  (ref) => RemindersRepository(
    ref.watch(appDatabaseProvider),
    profileId: ref.watch(activeProfileIdProvider),
  ),
);

/// Every profile's reminders: for alarms, which ring for everyone in the
/// family whichever profile is open.
final allRemindersRepositoryProvider = Provider<RemindersRepository>(
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
  (ref) => ref.watch(allRemindersRepositoryProvider).watchRinging(),
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

final _logsBetweenProvider = StreamProvider.autoDispose
    .family<List<ReminderLog>, (DateTime, DateTime)>(
      (ref, range) => ref
          .watch(remindersRepositoryProvider)
          .watchLogsBetween(range.$1, range.$2),
    );

/// Medicine doses from today and the previous
/// [AppConstants.missedDosesShownDays] that were missed and not since marked
/// as taken late, oldest first. Includes doses the background sweep hasn't
/// logged yet (status null), so Home is right the minute one becomes missed.
final missedDosesProvider = FutureProvider<List<ScheduledOccurrence>>((
  ref,
) async {
  final day = await ref.watch(currentDayProvider.future);
  final now = await ref.watch(minuteTickerProvider.future);
  final reminders = await ref.watch(enabledRemindersProvider.future);
  final from = DateTime(
    day.year,
    day.month,
    day.day - AppConstants.missedDosesShownDays,
  );
  final until = DateTime(day.year, day.month, day.day + 1);
  final logs = await ref.watch(_logsBetweenProvider((from, until)).future);

  final details = {for (final d in reminders) d.reminder.id: d};
  return [
    for (final missed in MissedDoses.find(
      [for (final d in reminders) d.reminder],
      logs,
      from: from,
      now: now,
    ))
      ScheduledOccurrence(
        details: details[missed.reminder.id]!,
        at: missed.at,
        status: missed.logged ? ReminderLogStatus.missed : null,
      ),
  ];
});

/// Medicine doses of the last `days` days (today included), newest first;
/// only one medicine's when `medicineId` is given.
final doseHistoryProvider = FutureProvider.autoDispose
    .family<DoseHistory, ({int days, int? medicineId})>((ref, query) async {
      final day = await ref.watch(currentDayProvider.future);
      final now = await ref.watch(minuteTickerProvider.future);
      final reminders = await ref.watch(remindersProvider.future);
      final from = DateTime(day.year, day.month, day.day - query.days + 1);
      final until = DateTime(day.year, day.month, day.day + 1);
      final logs = await ref.watch(_logsBetweenProvider((from, until)).future);
      return DoseHistory.build(
        reminders,
        logs,
        from: from,
        now: now,
        medicineId: query.medicineId,
      );
    });

/// Medicines with a dose missed before [at] (since the day before), for the
/// alarm ringing at [at]. Read once when the alarm opens rather than kept
/// live: it can't change while the alarm rings, and a live chain of
/// providers here broke the alarm screen when a second medicine joined it.
final medicinesMissedBeforeProvider = FutureProvider.autoDispose
    .family<Set<int>, DateTime>((ref, at) async {
      final repo = ref.watch(allRemindersRepositoryProvider);
      final from = DateTime(
        at.year,
        at.month,
        at.day - AppConstants.missedDosesShownDays,
      );
      return {
        for (final d in MissedDoses.find(
          await repo.getAll(),
          await repo.logsBetween(from, at),
          from: from,
          now: at,
        ))
          ?d.reminder.medicineId,
      };
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
      return ref.watch(remindersProvider).whenData(
            (list) => type == null
                ? list
                : list.where((d) => d.reminder.type == type).toList(),
          );
    });

/// Upcoming appointments, vaccines and tests (not daily medicine doses).
final upcomingEventsProvider = Provider<AsyncValue<List<ReminderWithDetails>>>(
  (ref) => ref.watch(upcomingRemindersProvider).whenData(
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
