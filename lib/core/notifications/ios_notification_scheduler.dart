import 'package:awesome_notifications/awesome_notifications.dart';

import '../../features/reminders/data/reminders_repository.dart';
import '../constants/app_constants.dart';
import 'alarm_ports.dart';
import 'awesome_notification_presenter.dart';

/// [AlarmScheduler] for iOS, which has no AlarmManager: instead of waking a
/// background isolate at fire time, the notification itself is scheduled with
/// the OS. Only the next occurrence is booked; later ones are armed when the
/// app next runs `ReminderAlarmEngine.resyncAll` (every launch).
class IosNotificationScheduler implements AlarmScheduler {
  IosNotificationScheduler(this._reminders, this._presenter);

  final RemindersRepository _reminders;
  final AwesomeNotificationPresenter _presenter;

  @override
  Future<void> schedule({
    required int alarmId,
    required DateTime at,
    required Map<String, dynamic> params,
    required bool critical,
  }) async {
    final reminderId = alarmId >= AppConstants.snoozeIdOffset
        ? alarmId - AppConstants.snoozeIdOffset
        : alarmId;
    final details = await _reminders.getDetails(reminderId);
    if (details == null) return;
    final scheduledFor =
        DateTime.tryParse(
          params[AppConstants.alarmParamScheduledFor] as String? ?? '',
        ) ??
        at;
    await _presenter.schedule(details, scheduledFor, id: alarmId, at: at);
  }

  @override
  Future<void> cancel(int alarmId) => AwesomeNotifications().cancel(alarmId);
}
