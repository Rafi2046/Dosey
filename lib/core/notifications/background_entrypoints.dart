import 'package:awesome_notifications/awesome_notifications.dart';

import '../constants/app_constants.dart';
import 'alarm_runtime.dart';
import 'awesome_notification_presenter.dart';
import 'reminder_alarm_engine.dart';

// Top-level entry points invoked by native code. They may run in a fresh
// background isolate, so they must not rely on any UI/Riverpod state.

/// android_alarm_manager_plus callback for reminder, snooze and resync alarms.
@pragma('vm:entry-point')
Future<void> onAlarmCallback(int alarmId, Map<String, dynamic> params) async {
  final engine = await AlarmRuntime.engine();
  await AlarmRuntime.applySavedLanguage();
  await engine.onAlarmFired(alarmId, params);
}

/// awesome_notifications action callback (Taken / Snooze / Skip buttons).
/// A plain tap on the notification opens the app, which shows the alarm
/// screen from the reminder's `ringingFor` state, so it needs no handling here.
@pragma('vm:entry-point')
Future<void> onNotificationAction(ReceivedAction received) async {
  final occurrence = NotificationPayload.decode(received.payload);
  final action = switch (received.buttonKeyPressed) {
    AppConstants.actionTaken => AlarmAction.taken,
    AppConstants.actionSkip => AlarmAction.skip,
    AppConstants.actionSnooze => AlarmAction.snooze,
    _ => null,
  };
  if (occurrence == null || action == null) return;

  final (reminderId, scheduledFor) = occurrence;
  final engine = await AlarmRuntime.engine();
  await engine.handleAction(
    reminderId: reminderId,
    scheduledFor: scheduledFor,
    action: action,
  );
}
