import 'dart:math' as math;

import '../../features/medicines/domain/stock_status.dart';
import '../../features/reminders/data/reminders_repository.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import 'alarm_ports.dart';

enum AlarmAction { taken, skip, snooze }

/// Core alarm logic, shared by the UI isolate, alarm callbacks and
/// notification-action handlers. The database is the source of truth; OS
/// alarms are a disposable projection of `Reminders.nextTriggerAt`.
///
/// Medicines due at the same minute ring as one group: a single OS alarm
/// (under the group's lowest reminder id, its "leader"), one notification
/// and one alarm screen listing them all, and one action for all of them.
/// Other reminders (appointments, tests…) ring on their own.
class ReminderAlarmEngine {
  ReminderAlarmEngine({
    required RemindersRepository reminders,
    required AlarmScheduler scheduler,
    required NotificationPresenter notifier,
    DateTime Function()? clock,
  }) : _reminders = reminders,
       _scheduler = scheduler,
       _notifier = notifier,
       _clock = clock ?? DateTime.now;

  final RemindersRepository _reminders;
  final AlarmScheduler _scheduler;
  final NotificationPresenter _notifier;
  final DateTime Function() _clock;

  static int snoozeAlarmId(int leaderId) =>
      AppConstants.snoozeIdOffset + leaderId;

  /// The id a group's alarm, notification and snooze are filed under.
  static int leaderOf(Iterable<int> reminderIds) => reminderIds.reduce(math.min);

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
    final all = await _reminders.getAll();
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
  }

  /// Recomputes every next trigger from "now" and re-arms all alarms.
  /// Runs on app start, after reboot, and on time/timezone changes.
  Future<void> resyncAll() async {
    final now = _clock();
    for (final r in await _reminders.getAll()) {
      await _reminders.refreshNextTrigger(r.id, now: now);
    }
    await syncAll();
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
        ? await _stillSnoozed(
            idsFromParams(params) ?? [leaderId],
            scheduledFor,
          )
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

    if (now.difference(scheduledFor) > AppConstants.missedThreshold) {
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

  /// A snoozed group, minus anything since taken or skipped (e.g. from the
  /// Home card) or disabled.
  Future<List<int>> _stillSnoozed(List<int> ids, DateTime at) async {
    final statuses = await _reminders.statusesFor(ids, at);
    final result = <int>[];
    for (final id in ids) {
      final status = statuses[id];
      if (status == ReminderLogStatus.taken ||
          status == ReminderLogStatus.skipped) {
        continue;
      }
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
  Future<void> handleAction({
    required List<int> reminderIds,
    required DateTime scheduledFor,
    required AlarmAction action,
  }) async {
    if (reminderIds.isEmpty) return;
    final status = switch (action) {
      AlarmAction.taken => ReminderLogStatus.taken,
      AlarmAction.skip => ReminderLogStatus.skipped,
      AlarmAction.snooze => ReminderLogStatus.snoozed,
    };
    final stockBefore = <int, StockStatus>{
      if (action == AlarmAction.taken)
        for (final id in reminderIds)
          if (await _reminders.stockStatusFor(id) case final s?) id: s,
    };
    await _reminders.logActions(
      reminderIds: reminderIds,
      scheduledFor: scheduledFor,
      status: status,
    );
    for (final id in reminderIds) {
      await _reminders.setRinging(id, null);
      await _notifier.dismiss(id);
    }
    for (final MapEntry(key: id, value: before) in stockBefore.entries) {
      await _warnIfNowLow(id, before);
    }

    final snoozeId = snoozeAlarmId(leaderOf(reminderIds));
    if (action != AlarmAction.snooze) {
      await _scheduler.cancel(snoozeId);
      return;
    }
    final group = [
      for (final id in reminderIds) ?await _reminders.getById(id),
    ];
    final minutes = group.isEmpty
        ? AppConstants.defaultSnoozeMinutes
        : group.map((r) => r.snoozeMinutes).reduce(math.min);
    await _scheduler.schedule(
      alarmId: snoozeId,
      at: _clock().add(Duration(minutes: minutes)),
      params: _params(scheduledFor, reminderIds, snooze: true),
      critical: group.isEmpty || group.any((r) => r.isCritical),
    );
  }
}
