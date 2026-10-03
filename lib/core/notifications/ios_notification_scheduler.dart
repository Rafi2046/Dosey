import 'package:awesome_notifications/awesome_notifications.dart';

import '../../features/reminders/data/reminders_repository.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../constants/app_constants.dart';
import 'alarm_ports.dart';
import 'awesome_notification_presenter.dart';
import 'reminder_alarm_engine.dart';

/// [AlarmScheduler] for iOS, which has no AlarmManager and doesn't run app
/// code when a local notification fires. The engine books every occurrence
/// of the coming days here ([replaceBookings]) as notifications the OS
/// delivers on its own, with the sound, grouping and buttons already in
/// them. Bookings are refreshed whenever reminders change and on every
/// launch (`ReminderAlarmEngine.resyncAll`).
class IosNotificationScheduler implements BookAheadScheduler {
  IosNotificationScheduler(this._reminders, this._presenter);

  final RemindersRepository _reminders;
  final AwesomeNotificationPresenter _presenter;

  Future<List<ReminderWithDetails>> _group(List<int> ids) async => [
    for (final id in ids) ?await _reminders.getDetails(id),
  ];

  @override
  Future<void> replaceBookings(List<AlarmBooking> bookings) async {
    final wanted = {for (final b in bookings) b.id};
    // Drop bookings that are no longer wanted (time changed, reminder off
    // or deleted, old one-per-reminder bookings). Snoozes and low-stock
    // notifications live at or above snoozeIdOffset and are kept.
    for (final pending
        in await AwesomeNotifications().listScheduledNotifications()) {
      final id = pending.content?.id;
      if (id != null &&
          id < AppConstants.snoozeIdOffset &&
          !wanted.contains(id)) {
        await AwesomeNotifications().cancelSchedule(id);
      }
    }
    for (final b in bookings) {
      final group = await _group(b.reminderIds);
      if (group.isEmpty) continue;
      // Same id: rebooking replaces the previous version.
      await _presenter.schedule(group, b.at, id: b.id, at: b.at);
    }
  }

  /// Snoozes (and anything else booked one at a time).
  @override
  Future<void> schedule({
    required int alarmId,
    required DateTime at,
    required Map<String, dynamic> params,
    required bool critical,
  }) async {
    final leaderId = alarmId >= AppConstants.snoozeIdOffset
        ? alarmId - AppConstants.snoozeIdOffset
        : alarmId;
    // Grouped medicines: one notification listing them all.
    final group = await _group(
      ReminderAlarmEngine.idsFromParams(params) ?? [leaderId],
    );
    if (group.isEmpty) return;
    final scheduledFor =
        DateTime.tryParse(
          params[AppConstants.alarmParamScheduledFor] as String? ?? '',
        ) ??
        at;
    await _presenter.schedule(group, scheduledFor, id: alarmId, at: at);
  }

  @override
  Future<void> cancel(int alarmId) => AwesomeNotifications().cancel(alarmId);
}
