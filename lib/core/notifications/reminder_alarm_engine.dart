import '../../features/reminders/data/reminders_repository.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import 'alarm_ports.dart';

enum AlarmAction { taken, skip, snooze }

/// Core alarm logic, shared by the UI isolate, alarm callbacks and
/// notification-action handlers. The database is the source of truth; OS
/// alarms are a disposable projection of `Reminders.nextTriggerAt`.
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

  static int snoozeAlarmId(int reminderId) =>
      AppConstants.snoozeIdOffset + reminderId;

  static Map<String, dynamic> _params(DateTime at, {bool snooze = false}) => {
    AppConstants.alarmParamScheduledFor: at.toIso8601String(),
    AppConstants.alarmParamIsSnooze: snooze,
  };

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Makes the OS alarm for [r] match its DB state.
  Future<void> sync(Reminder r) async {
    final next = r.nextTriggerAt;
    if (!r.isEnabled || next == null) {
      await _scheduler.cancel(r.id);
      return;
    }
    await _scheduler.schedule(
      alarmId: r.id,
      at: next,
      params: _params(next),
      critical: r.isCritical,
    );
  }

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
      final updated = await _reminders.refreshNextTrigger(r.id, now: now);
      await sync(updated);
    }
  }

  // ── Alarm fired (background isolate) ──────────────────────────────────────

  Future<void> onAlarmFired(int alarmId, Map<String, dynamic> params) async {
    if (alarmId == AppConstants.resyncAlarmId) return resyncAll();

    final isSnooze =
        alarmId >= AppConstants.snoozeIdOffset &&
        alarmId < AppConstants.resyncAlarmId;
    final reminderId = isSnooze
        ? alarmId - AppConstants.snoozeIdOffset
        : alarmId;
    final details = await _reminders.getDetails(reminderId);
    if (details == null || !details.reminder.isEnabled) return;

    final now = _clock();
    final scheduledFor =
        DateTime.tryParse(
          params[AppConstants.alarmParamScheduledFor] as String? ?? '',
        ) ??
        now;

    // Arm the next occurrence first so a crash below can't break the chain.
    if (!isSnooze) {
      final after = now.isAfter(scheduledFor) ? now : scheduledFor;
      await sync(await _reminders.refreshNextTrigger(reminderId, now: after));
    }

    if (now.difference(scheduledFor) > AppConstants.missedThreshold) {
      await _reminders.logAction(
        reminderId: reminderId,
        scheduledFor: scheduledFor,
        status: ReminderLogStatus.missed,
      );
      return;
    }

    await _reminders.setRinging(reminderId, scheduledFor);
    await _notifier.showAlarm(details, scheduledFor);
  }

  // ── User actions (notification buttons or alarm screen) ───────────────────

  Future<void> handleAction({
    required int reminderId,
    required DateTime scheduledFor,
    required AlarmAction action,
  }) async {
    final status = switch (action) {
      AlarmAction.taken => ReminderLogStatus.taken,
      AlarmAction.skip => ReminderLogStatus.skipped,
      AlarmAction.snooze => ReminderLogStatus.snoozed,
    };
    await _reminders.logAction(
      reminderId: reminderId,
      scheduledFor: scheduledFor,
      status: status,
    );
    await _reminders.setRinging(reminderId, null);
    await _notifier.dismiss(reminderId);

    final snoozeId = snoozeAlarmId(reminderId);
    if (action != AlarmAction.snooze) {
      await _scheduler.cancel(snoozeId);
      return;
    }
    final reminder = await _reminders.getById(reminderId);
    final minutes =
        reminder?.snoozeMinutes ?? AppConstants.defaultSnoozeMinutes;
    await _scheduler.schedule(
      alarmId: snoozeId,
      at: _clock().add(Duration(minutes: minutes)),
      params: _params(scheduledFor, snooze: true),
      critical: reminder?.isCritical ?? true,
    );
  }
}
