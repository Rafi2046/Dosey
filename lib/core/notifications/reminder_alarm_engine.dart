import 'dart:math' as math;

import '../../features/medicines/domain/stock_status.dart';
import '../../features/reminders/data/reminders_repository.dart';
import '../../features/reminders/domain/missed_doses.dart';
import '../../features/reminders/domain/reminder_schedule.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../constants/app_constants.dart';
import '../home_widget/home_widget_sync.dart';
import '../database/app_database.dart';
import 'alarm_ports.dart';

enum AlarmAction {
  taken,
  skip,
  snooze,

  /// A missed dose the user took after all (from the dashboard).
  takenLate,
}

/// Core alarm logic, shared by the UI isolate, alarm callbacks and
/// notification-action handlers. The database is the source of truth; OS
/// alarms are a disposable projection of `Reminders.nextTriggerAt`.
///
/// Medicines due at the same minute ring as one group: a single OS alarm
/// (under the group's lowest reminder id, its "leader"), one notification
/// and one alarm screen listing them all, and one action for all of them.
/// Other reminders (appointments, tests…) ring on their own.
///
/// Platforms differ in what can run when an alarm is due:
/// - Android ([AlarmScheduler]): an exact alarm wakes the app, which rings
///   and then arms the next occurrence ([onAlarmFired]).
/// - iOS ([BookAheadScheduler]): nothing runs, so every occurrence of the
///   coming days is booked ahead as an OS notification ([syncAll]), and the
///   alarm screen opens when the user taps one ([ringFromNotification]).
class ReminderAlarmEngine {
  ReminderAlarmEngine({
    required RemindersRepository reminders,
    required AlarmScheduler scheduler,
    required NotificationPresenter notifier,
    HomeWidgetSync? homeWidget,
    DateTime Function()? clock,
  }) : _reminders = reminders,
       _scheduler = scheduler,
       _notifier = notifier,
       _homeWidget = homeWidget,
       _clock = clock ?? DateTime.now;

  final RemindersRepository _reminders;
  final AlarmScheduler _scheduler;
  final NotificationPresenter _notifier;

  /// Home screen widget, redrawn whenever what's next may have changed.
  final HomeWidgetSync? _homeWidget;
  final DateTime Function() _clock;

  static int snoozeAlarmId(int leaderId) =>
      AppConstants.snoozeIdOffset + leaderId;

  /// The id a group's alarm, notification and snooze are filed under.
  static int leaderOf(Iterable<int> reminderIds) =>
      reminderIds.reduce(math.min);

  static Map<String, dynamic> _params(
    DateTime at,
    List<int> reminderIds, {
    bool snooze = false,
  }) => {
    AppConstants.alarmParamScheduledFor: at.toIso8601String(),
    AppConstants.alarmParamIsSnooze: snooze,
    AppConstants.alarmParamReminderIds: reminderIds.join(','),
  };

  /// Reminder ids an alarm's params cover (null if it predates grouping).
  static List<int>? idsFromParams(Map<String, dynamic> params) {
    final raw = params[AppConstants.alarmParamReminderIds];
    if (raw is! String || raw.isEmpty) return null;
    final ids = [for (final s in raw.split(',')) ?int.tryParse(s)];
    return ids.isEmpty ? null : ids;
  }

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Makes every OS alarm match the database: one alarm per group of
  /// medicines due at the same minute (under its leader's id), one per other
  /// reminder, and none for disabled reminders or non-leader group members.
  Future<void> syncAll() async {
    await _syncAlarms();
    await _syncHeadsUps();
    await _homeWidget?.refresh();
  }

  /// Books each appointment, vaccine or test's heads-up ("also remind me a
  /// day before") for its next occurrence, and drops the rest. Plain
  /// scheduled notifications, the same on Android and iOS.
  Future<void> _syncHeadsUps() async {
    final now = _clock();
    for (final r in await _reminders.getAll()) {
      if (r.type == ReminderType.medicine) continue;
      final next = r.nextTriggerAt;
      final before = r.remindBeforeMinutes;
      final notifyAt = next == null || before == null || !r.isEnabled
          ? null
          : next.subtract(Duration(minutes: before));
      if (notifyAt != null && notifyAt.isAfter(now)) {
        if (await _reminders.getDetails(r.id) case final d?) {
          await _notifier.scheduleHeadsUp(d, next!, notifyAt: notifyAt);
          continue;
        }
      }
      await _notifier.cancelHeadsUp(r.id);
    }
  }

  Future<void> _syncAlarms() async {
    final all = await _reminders.getAll();
    if (_scheduler case final BookAheadScheduler ahead) {
      return ahead.replaceBookings(planBookings(all, _clock()));
    }
    final medicineGroups = <DateTime, List<Reminder>>{};
    final alone = <Reminder>[];
    for (final r in all) {
      final next = r.nextTriggerAt;
      if (!r.isEnabled || next == null) {
        await _scheduler.cancel(r.id);
      } else if (r.type == ReminderType.medicine) {
        (medicineGroups[next] ??= []).add(r);
      } else {
        alone.add(r);
      }
    }
    for (final r in alone) {
      await _schedule([r], r.nextTriggerAt!);
    }
    for (final MapEntry(key: at, value: group) in medicineGroups.entries) {
      await _schedule(group, at);
    }
  }

  /// iOS bookings for the next [AppConstants.bookAhead]: one per minute
  /// that has medicines due (all of them together, id from the time), and
  /// the next occurrence of each other reminder (id = reminder id). Capped
  /// at [AppConstants.bookAheadLimit], soonest first.
  static List<AlarmBooking> planBookings(List<Reminder> all, DateTime now) {
    final horizon = now.add(AppConstants.bookAhead);
    final medicineSlots = <DateTime, List<Reminder>>{};
    final bookings = <AlarmBooking>[];
    for (final r in all.where((r) => r.isEnabled)) {
      if (r.type != ReminderType.medicine) {
        final next = ReminderSchedule.nextFor(r, now);
        if (next != null && !next.isAfter(horizon)) {
          bookings.add(
            AlarmBooking(
              id: r.id,
              at: next,
              reminderIds: [r.id],
              critical: r.isCritical,
            ),
          );
        }
        continue;
      }
      var cursor = now;
      while (true) {
        final next = ReminderSchedule.nextFor(r, cursor);
        if (next == null || next.isAfter(horizon)) break;
        (medicineSlots[next] ??= []).add(r);
        cursor = next;
      }
    }
    for (final MapEntry(key: at, value: group) in medicineSlots.entries) {
      bookings.add(
        AlarmBooking(
          id: slotNotificationId(at),
          at: at,
          reminderIds: [for (final r in group) r.id]..sort(),
          critical: group.any((r) => r.isCritical),
        ),
      );
    }
    bookings.sort((a, b) => a.at.compareTo(b.at));
    return bookings.take(AppConstants.bookAheadLimit).toList();
  }

  /// iOS notification id of the medicines due at [at] (one per minute).
  static int slotNotificationId(DateTime at) =>
      AppConstants.slotIdOffset +
      at.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;

  Future<void> _schedule(List<Reminder> group, DateTime at) async {
    final ids = [for (final r in group) r.id]..sort();
    final leader = ids.first;
    for (final id in ids.skip(1)) {
      await _scheduler.cancel(id);
    }
    await _scheduler.schedule(
      alarmId: leader,
      at: at,
      params: _params(at, ids),
      critical: group.any((r) => r.isCritical),
    );
  }

  /// One reminder changed: regroup everything (a change can move it into or
  /// out of a group, or change who leads one).
  Future<void> sync(Reminder r) => syncAll();

  Future<void> cancel(int reminderId) async {
    await _scheduler.cancel(reminderId);
    await _scheduler.cancel(snoozeAlarmId(reminderId));
    await _notifier.dismiss(reminderId);
    await _notifier.cancelHeadsUp(reminderId);
  }

  /// Recomputes every next trigger from "now" and re-arms all alarms.
  /// Runs on app start, after reboot, and on time/timezone changes.
  Future<void> resyncAll() async {
    final now = _clock();
    for (final r in await _reminders.getAll()) {
      await _reminders.refreshNextTrigger(r.id, now: now);
    }
    await sweepMissed();
    await syncAll();
  }

  // ── Missed doses ──────────────────────────────────────────────────────────

  /// Logs every medicine dose of the last [AppConstants.missedSweepWindow]
  /// that nobody answered within [AppConstants.missedThreshold] as missed,
  /// and stops any of them still ringing. Runs on app start, after reboot
  /// and whenever an alarm fires, so history fills in even if the app is
  /// rarely opened.
  Future<void> sweepMissed() async {
    final now = _clock();
    final from = now.subtract(AppConstants.missedSweepWindow);
    final reminders = await _reminders.getAll();
    final overdue = MissedDoses.find(
      reminders,
      await _reminders.logsBetween(from, now),
      from: from,
      now: now,
    ).where((d) => !d.logged);
    final byTime = <DateTime, List<Reminder>>{};
    for (final d in overdue) {
      (byTime[d.at] ??= []).add(d.reminder);
    }
    for (final MapEntry(key: at, value: group) in byTime.entries) {
      await _markMissed(group, at);
    }
  }

  /// The user swiped away a dose's notification without answering it:
  /// still-open medicine doses of that occurrence are logged as missed.
  Future<void> onDismissed(List<int> reminderIds, DateTime scheduledFor) async {
    final statuses = await _reminders.statusesFor(reminderIds, scheduledFor);
    final open = <Reminder>[];
    for (final id in reminderIds) {
      if (!MissedDoses.isOpen(statuses[id])) continue;
      final r = await _reminders.getById(id);
      if (r != null && r.type == ReminderType.medicine) open.add(r);
    }
    if (open.isEmpty) return;
    await _markMissed(open, scheduledFor);
    await _scheduler.cancel(snoozeAlarmId(leaderOf(reminderIds)));
    await _homeWidget?.refresh();
  }

  Future<void> _markMissed(List<Reminder> group, DateTime at) async {
    await _reminders.logActions(
      reminderIds: [for (final r in group) r.id],
      scheduledFor: at,
      status: ReminderLogStatus.missed,
    );
    for (final r in group.where((r) => r.ringingFor == at)) {
      await _reminders.setRinging(r.id, null);
      await _notifier.dismiss(r.id);
    }
  }

  // ── Alarm fired (background isolate) ──────────────────────────────────────

  Future<void> onAlarmFired(int alarmId, Map<String, dynamic> params) async {
    if (alarmId == AppConstants.resyncAlarmId) return resyncAll();

    final isSnooze =
        alarmId >= AppConstants.snoozeIdOffset &&
        alarmId < AppConstants.resyncAlarmId;
    final leaderId = isSnooze ? alarmId - AppConstants.snoozeIdOffset : alarmId;
    final now = _clock();
    final scheduledFor =
        DateTime.tryParse(
          params[AppConstants.alarmParamScheduledFor] as String? ?? '',
        ) ??
        now;

    final ids = isSnooze
        ? await _stillSnoozed(idsFromParams(params) ?? [leaderId], scheduledFor)
        : await _dueTogether(leaderId, scheduledFor);
    if (ids.isEmpty) return;

    // Arm the next occurrence first so a crash below can't break the chain.
    if (!isSnooze) {
      final after = now.isAfter(scheduledFor) ? now : scheduledFor;
      for (final id in ids) {
        await _reminders.refreshNextTrigger(id, now: after);
      }
      await syncAll();
    }
    // Earlier doses left unanswered (e.g. alarm ignored hours ago).
    await sweepMissed();

    // A dose alarm delivered hours late (phone off…) is a miss, not a ring.
    // Snoozes always ring: the user asked to be reminded then.
    if (!isSnooze &&
        now.difference(scheduledFor) > AppConstants.missedThreshold) {
      await _reminders.logActions(
        reminderIds: ids,
        scheduledFor: scheduledFor,
        status: ReminderLogStatus.missed,
      );
      return;
    }

    final group = <ReminderWithDetails>[];
    for (final id in ids) {
      await _reminders.setRinging(id, scheduledFor);
      if (await _reminders.getDetails(id) case final d?) group.add(d);
    }
    await _notifier.showAlarm(group, scheduledFor);
  }

  /// Who rings with [leaderId]'s alarm at [at]: every enabled medicine due
  /// then, or just the reminder itself for other types.
  Future<List<int>> _dueTogether(int leaderId, DateTime at) async {
    final leader = await _reminders.getById(leaderId);
    if (leader != null && leader.type != ReminderType.medicine) {
      return leader.isEnabled ? [leader.id] : const [];
    }
    final due = [for (final r in await _reminders.getMedicinesDueAt(at)) r.id];
    if (due.isNotEmpty) return due;
    // Stale alarm (its time moved since it was armed): ring it alone, as
    // before grouping.
    return leader != null && leader.isEnabled ? [leader.id] : const [];
  }

  /// iOS fallback for Android's full-screen intent: when a booked
  /// notification is tapped (or arrives while Dosey is open), mark its
  /// medicines as ringing so the in-app alarm screen opens. Doses already
  /// taken or skipped, and very old notifications, are left alone.
  Future<void> ringFromNotification(
    List<int> reminderIds,
    DateTime scheduledFor,
  ) async {
    if (_clock().difference(scheduledFor) > AppConstants.missedThreshold) {
      return;
    }
    for (final id in await _stillSnoozed(reminderIds, scheduledFor)) {
      await _reminders.setRinging(id, scheduledFor);
    }
  }

  /// A snoozed group, minus anything since taken or skipped (e.g. from the
  /// Home card) or disabled.
  Future<List<int>> _stillSnoozed(List<int> ids, DateTime at) async {
    final statuses = await _reminders.statusesFor(ids, at);
    final result = <int>[];
    for (final id in ids) {
      if (statuses[id]?.isAnswered ?? false) continue;
      if ((await _reminders.getById(id))?.isEnabled ?? false) result.add(id);
    }
    return result;
  }

  // ── Stock ─────────────────────────────────────────────────────────────────

  /// Notifies once, when a dose moves the medicine into its refill-alert
  /// window (not again on every later dose).
  Future<void> _warnIfNowLow(int reminderId, StockStatus before) async {
    if (before.isLow) return;
    final after = await _reminders.stockStatusFor(reminderId);
    if (after == null || !after.isLow) return;
    await _notifier.showLowStock(after.medicine, after.daysLeft ?? 0);
  }

  // ── User actions (notification buttons or alarm screen) ───────────────────

  /// Applies [action] to every reminder in [reminderIds] (one, or a whole
  /// group ringing together) for the occurrence at [scheduledFor]. The logs
  /// are written in a single transaction.
  /// [notificationId]: the notification acted on, when it isn't filed under
  /// a reminder id (iOS time-slot notifications), so it's removed too.
  /// [snoozeFor]: how long a snooze lasts ("remind me later"); defaults to
  /// the group's shortest snooze setting.
  Future<void> handleAction({
    required List<int> reminderIds,
    required DateTime scheduledFor,
    required AlarmAction action,
    int? notificationId,
    Duration? snoozeFor,
  }) async {
    if (reminderIds.isEmpty) return;
    final status = switch (action) {
      AlarmAction.taken => ReminderLogStatus.taken,
      AlarmAction.skip => ReminderLogStatus.skipped,
      AlarmAction.snooze => ReminderLogStatus.snoozed,
      AlarmAction.takenLate => ReminderLogStatus.takenLate,
    };
    final stockBefore = <int, StockStatus>{
      if (status.isTaken)
        for (final id in reminderIds) id: ?await _reminders.stockStatusFor(id),
    };
    final group = [for (final id in reminderIds) ?await _reminders.getById(id)];
    final snoozeAt = _clock().add(
      snoozeFor ??
          Duration(
            minutes: group.isEmpty
                ? AppConstants.defaultSnoozeMinutes
                : group.map((r) => r.snoozeMinutes).reduce(math.min),
          ),
    );
    await _reminders.logActions(
      reminderIds: reminderIds,
      scheduledFor: scheduledFor,
      status: status,
      // A snooze records when it rings again; missed is counted from there.
      actedAt: action == AlarmAction.snooze ? snoozeAt : null,
    );
    for (final id in reminderIds) {
      await _reminders.setRinging(id, null);
      await _notifier.dismiss(id);
    }
    if (notificationId != null && !reminderIds.contains(notificationId)) {
      await _notifier.dismiss(notificationId);
    }
    for (final MapEntry(key: id, value: before) in stockBefore.entries) {
      await _warnIfNowLow(id, before);
    }

    // Taken/skipped doses drop off the widget; snoozed ones stay.
    await _homeWidget?.refresh();

    final snoozeId = snoozeAlarmId(leaderOf(reminderIds));
    if (action != AlarmAction.snooze) {
      await _scheduler.cancel(snoozeId);
      return;
    }
    await _scheduler.schedule(
      alarmId: snoozeId,
      at: snoozeAt,
      params: _params(scheduledFor, reminderIds, snooze: true),
      critical: group.isEmpty || group.any((r) => r.isCritical),
    );
  }
}
