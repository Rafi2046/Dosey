import '../../features/reminders/domain/reminder_with_details.dart';

/// Schedules exact OS alarms that wake the app's background isolate.
abstract interface class AlarmScheduler {
  /// [critical] alarms use `setAlarmClock` (exempt from Doze, shows the alarm
  /// icon); others use exact-while-idle alarms.
  Future<void> schedule({
    required int alarmId,
    required DateTime at,
    required Map<String, dynamic> params,
    required bool critical,
  });

  Future<void> cancel(int alarmId);
}

/// Shows/dismisses the ringing notification for a reminder occurrence.
abstract interface class NotificationPresenter {
  Future<void> showAlarm(ReminderWithDetails details, DateTime scheduledFor);
  Future<void> dismiss(int reminderId);
}
