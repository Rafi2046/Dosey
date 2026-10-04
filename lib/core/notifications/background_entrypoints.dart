import 'dart:io';

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

/// awesome_notifications action callback (Taken / Snooze / Skip buttons,
/// or a tap on the notification itself).
///
/// A plain tap opens the app. On Android the alarm callback has already
/// marked the reminders as ringing, so the alarm screen shows by itself. On
/// iOS nothing ran when the notification fired, so the tap is what raises
/// the in-app alarm screen (iOS has no full-screen intent).
@pragma('vm:entry-point')
Future<void> onNotificationAction(ReceivedAction received) async {
  final occurrence = NotificationPayload.decode(received.payload);
  if (occurrence == null) return;
  final (reminderIds, scheduledFor) = occurrence;
  final action = switch (received.buttonKeyPressed) {
    AppConstants.actionTaken => AlarmAction.taken,
    AppConstants.actionSkip => AlarmAction.skip,
    AppConstants.actionSnooze => AlarmAction.snooze,
    _ => null,
  };
  final engine = await AlarmRuntime.engine();
  if (action == null) {
    if (Platform.isIOS) {
      await engine.ringFromNotification(reminderIds, scheduledFor);
    }
    return;
  }

  // A grouped alarm's buttons act on every medicine it lists.
  await engine.handleAction(
    notificationId: received.id,
    reminderIds: reminderIds,
    scheduledFor: scheduledFor,
    action: action,
  );
}

/// iOS: a reminder notification arrived while Dosey is open. Show the alarm
/// screen right away, as Android's full-screen intent would.
@pragma('vm:entry-point')
Future<void> onNotificationDisplayed(ReceivedNotification shown) async {
  if (!Platform.isIOS) return;
  final occurrence = NotificationPayload.decode(shown.payload);
  if (occurrence == null) return;
  final (reminderIds, scheduledFor) = occurrence;
  final engine = await AlarmRuntime.engine();
  await engine.ringFromNotification(reminderIds, scheduledFor);
}

/// A reminder notification was swiped away without Taken / Skip / Snooze:
/// its doses count as missed. (Critical alarms are locked and can't be
/// swiped; this covers gentle reminders. Dismissing from code, as after an
/// answer, doesn't trigger it.)
@pragma('vm:entry-point')
Future<void> onNotificationDismissed(ReceivedAction received) async {
  final occurrence = NotificationPayload.decode(received.payload);
  if (occurrence == null) return;
  final (reminderIds, scheduledFor) = occurrence;
  final engine = await AlarmRuntime.engine();
  await engine.onDismissed(reminderIds, scheduledFor);
}
