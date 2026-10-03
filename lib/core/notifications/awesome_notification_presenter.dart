import 'package:awesome_notifications/awesome_notifications.dart';

import '../../features/reminders/domain/reminder_text.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../database/app_database.dart';
import '../constants/constants.dart';
import '../utils/enum_labels.dart';
import 'alarm_ports.dart';
import 'notification_channels.dart';
import '../localization/l10n.dart';

/// [NotificationPresenter] backed by awesome_notifications. Critical
/// reminders use the alarm category + full-screen intent so they wake the
/// device, appear over the lock screen and loop until acted on.
class AwesomeNotificationPresenter implements NotificationPresenter {
  @override
  Future<void> showAlarm(ReminderWithDetails details, DateTime scheduledFor) =>
      schedule(details, scheduledFor, id: details.reminder.id);

  /// Posts the alarm now, or at [at] when given (iOS pre-scheduling, where no
  /// background code runs at fire time). [id] differs for snoozes.
  Future<void> schedule(
    ReminderWithDetails details,
    DateTime scheduledFor, {
    required int id,
    DateTime? at,
  }) {
    final r = details.reminder;
    final critical = r.isCritical;
    return AwesomeNotifications().createNotification(
      schedule: at == null
          ? null
          : NotificationCalendar.fromDate(
              date: at,
              allowWhileIdle: true,
              preciseAlarm: true,
            ),
      content: NotificationContent(
        id: id,
        channelKey: NotificationChannels.keyFor(r.type, critical: critical),
        title: r.title,
        body: ReminderText.body(AppLocale.l10n, details),
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

  /// A normal (non-alarm) notification on the gentle channel.
  @override
  Future<void> showLowStock(Medicine medicine, int daysLeft) {
    final l10n = AppLocale.l10n;
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: AppConstants.lowStockIdOffset + medicine.id,
        channelKey: AppConstants.channelGentle,
        title: l10n.lowStockTitle(medicine.name),
        body: l10n.lowStockBody(daysLeft),
        category: NotificationCategory.Reminder,
        color: AppColors.accent,
      ),
    );
  }

  static List<NotificationActionButton> _buttons(ReminderType type) => [
    NotificationActionButton(
      key: AppConstants.actionTaken,
      label: type == ReminderType.medicine
          ? AppLocale.l10n.notifTaken
          : AppLocale.l10n.alarmDone,
      color: AppColors.mint,
      actionType: ActionType.SilentBackgroundAction,
    ),
    NotificationActionButton(
      key: AppConstants.actionSnooze,
      label: AppLocale.l10n.notifSnooze,
      actionType: ActionType.SilentBackgroundAction,
    ),
    if (type == ReminderType.medicine)
      NotificationActionButton(
        key: AppConstants.actionSkip,
        label: AppLocale.l10n.notifSkip,
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
