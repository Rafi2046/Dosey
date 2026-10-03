import 'package:awesome_notifications/awesome_notifications.dart';

import '../../features/reminders/domain/reminder_text.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../constants/constants.dart';
import '../database/enums.dart';
import '../utils/enum_labels.dart';
import 'alarm_ports.dart';
import 'notification_channels.dart';

/// [NotificationPresenter] backed by awesome_notifications. Critical
/// reminders use the alarm category + full-screen intent so they wake the
/// device, appear over the lock screen and loop until acted on.
class AwesomeNotificationPresenter implements NotificationPresenter {
  @override
  Future<void> showAlarm(ReminderWithDetails details, DateTime scheduledFor) {
    final r = details.reminder;
    final critical = r.isCritical;
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: r.id,
        channelKey: NotificationChannels.keyFor(r.type, critical: critical),
        title: r.title,
        body: ReminderText.body(details),
        category: critical
            ? NotificationCategory.Alarm
            : NotificationCategory.Reminder,
        wakeUpScreen: critical,
        fullScreenIntent: critical,
        locked: critical,
        autoDismissible: !critical,
        color: r.type.color,
        payload: NotificationPayload.encode(r.id, scheduledFor),
      ),
      actionButtons: _buttons(r.type),
    );
  }

  @override
  Future<void> dismiss(int reminderId) =>
      AwesomeNotifications().dismiss(reminderId);

  static List<NotificationActionButton> _buttons(ReminderType type) => [
    NotificationActionButton(
      key: AppConstants.actionTaken,
      label: type == ReminderType.medicine
          ? NotificationStrings.notifTaken
          : AlarmStrings.alarmDone,
      color: AppColors.mint,
      actionType: ActionType.SilentBackgroundAction,
    ),
    NotificationActionButton(
      key: AppConstants.actionSnooze,
      label: NotificationStrings.notifSnooze,
      actionType: ActionType.SilentBackgroundAction,
    ),
    if (type == ReminderType.medicine)
      NotificationActionButton(
        key: AppConstants.actionSkip,
        label: NotificationStrings.notifSkip,
        actionType: ActionType.SilentBackgroundAction,
      ),
  ];
}

/// Encodes which occurrence a notification belongs to.
abstract final class NotificationPayload {
  static Map<String, String> encode(int reminderId, DateTime scheduledFor) => {
    AppConstants.payloadReminderId: '$reminderId',
    AppConstants.payloadScheduledFor: scheduledFor.toIso8601String(),
  };

  static (int, DateTime)? decode(Map<String, String?>? payload) {
    final id = int.tryParse(payload?[AppConstants.payloadReminderId] ?? '');
    final at = DateTime.tryParse(
      payload?[AppConstants.payloadScheduledFor] ?? '',
    );
    return id == null || at == null ? null : (id, at);
  }
}
