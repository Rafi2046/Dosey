import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'alarm_ports.dart';
import 'background_entrypoints.dart';

/// [AlarmScheduler] backed by android_alarm_manager_plus. Every alarm runs
/// [onAlarmCallback] in a background isolate, even if the app was killed.
class AndroidAlarmScheduler implements AlarmScheduler {
  @override
  Future<void> schedule({
    required int alarmId,
    required DateTime at,
    required Map<String, dynamic> params,
    required bool critical,
  }) async {
    // Without SCHEDULE_EXACT_ALARM the plugin silently drops exact alarms,
    // so degrade to an inexact (but Doze-tolerant) alarm instead.
    final exactAllowed = await _canScheduleExact();
    await AndroidAlarmManager.oneShotAt(
      at,
      alarmId,
      onAlarmCallback,
      alarmClock: critical && exactAllowed,
      exact: exactAllowed,
      allowWhileIdle: true,
      wakeup: true,
      params: params,
    );
  }

  @override
  Future<void> cancel(int alarmId) => AndroidAlarmManager.cancel(alarmId);

  static Future<bool> _canScheduleExact() async {
    final granted = await AwesomeNotifications().checkPermissionList(
      permissions: const [NotificationPermission.PreciseAlarms],
    );
    return granted.contains(NotificationPermission.PreciseAlarms);
  }
}
