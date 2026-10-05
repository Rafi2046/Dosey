import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';

import '../../features/reminders/domain/reminder_text.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../database/app_database.dart';
import '../constants/constants.dart';
import '../utils/date_format.dart';
import '../utils/enum_labels.dart';
import '../../features/profiles/presentation/profile_widgets.dart';
import 'alarm_ports.dart';
import 'notification_channels.dart';
import 'reminder_alarm_engine.dart';
import '../localization/l10n.dart';

/// [NotificationPresenter] backed by awesome_notifications. Critical
/// reminders use the alarm category + full-screen intent so they wake the
/// device, appear over the lock screen and loop until acted on.
class AwesomeNotificationPresenter implements NotificationPresenter {
  static const _html = HtmlEscape();

  @override
  Future<void> showAlarm(
    List<ReminderWithDetails> group,
    DateTime scheduledFor,
  ) => schedule(
    group,
    scheduledFor,
    id: ReminderAlarmEngine.leaderOf(group.map((d) => d.reminder.id)),
  );

  /// Posts the alarm now, or at [at] when given (iOS pre-scheduling, where no
  /// background code runs at fire time). [id] differs for snoozes.
  Future<void> schedule(
    List<ReminderWithDetails> group,
    DateTime scheduledFor, {
    required int id,
    DateTime? at,
  }) {
    final l10n = AppLocale.l10n;
    final r = group.first.reminder;
    final critical = group.any((d) => d.reminder.isCritical);
    final grouped = group.length > 1;
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
        title: grouped
            ? l10n.alarmGroupNotifTitle(group.length)
            : _titleFor(l10n, group.first),
        // Several medicines: one line each, with that time's dose. Android
        // renders the body as HTML (a plain "\n" shows as a space), so lines
        // are joined with <br> and escaped; iOS shows plain text, where
        // "\n" is the line break and tags would be stripped.
        body: grouped
            ? [
                for (final d in group)
                  Platform.isIOS
                      ? '${_titleFor(l10n, d)} — ${ReminderText.body(l10n, d)}'
                      : _html.convert(
                          '${_titleFor(l10n, d)} — ${ReminderText.body(l10n, d)}',
                        ),
              ].join(Platform.isIOS ? '\n' : '<br>')
            : ReminderText.body(l10n, group.first),
        notificationLayout: grouped
            ? NotificationLayout.BigText
            : NotificationLayout.Default,
        category: critical
            ? NotificationCategory.Alarm
            : NotificationCategory.Reminder,
        wakeUpScreen: critical,
        fullScreenIntent: critical,
        locked: critical,
        autoDismissible: !critical,
        color: r.type.color,
        // iOS: stack Dosey's reminders in one Notification Center thread
        // per type, and ring with the bundled alarm tone (the channel's
        // ringtone setting is Android-only).
        groupKey: Platform.isIOS ? 'dosey.${r.type.name}' : null,
        customSound: Platform.isIOS && critical
            ? AppConstants.iosAlarmSound
            : null,
        payload: NotificationPayload.encode([
          for (final d in group) d.reminder.id,
        ], scheduledFor),
      ),
      actionButtons: _buttons(r.type, grouped: grouped),
    );
  }

  /// "Ammu: Napa" for a family member's dose; just "Napa" for the user's.
  static String _titleFor(AppLocalizations l10n, ReminderWithDetails d) =>
      switch (familyMemberName(l10n, d.profile)) {
        final name? => l10n.notifForProfile(name, d.reminder.title),
        null => d.reminder.title,
      };

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

  @override
  Future<void> scheduleHeadsUp(
    ReminderWithDetails details,
    DateTime eventAt, {
    required DateTime notifyAt,
  }) {
    final l10n = AppLocale.l10n;
    final r = details.reminder;
    return AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
        date: notifyAt,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: AppConstants.headsUpIdOffset + r.id,
        channelKey: AppConstants.channelGentle,
        title: l10n.headsUpTitle(_titleFor(l10n, details)),
        body:
            '${AppDateFormat.dateTime(eventAt)}${l10n.notifDoseSeparator}'
            '${ReminderText.body(l10n, details)}',
        category: NotificationCategory.Reminder,
        color: r.type.color,
      ),
    );
  }

  @override
  Future<void> cancelHeadsUp(int reminderId) =>
      AwesomeNotifications().cancel(AppConstants.headsUpIdOffset + reminderId);

  static List<NotificationActionButton> _buttons(
    ReminderType type, {
    required bool grouped,
  }) => [
    NotificationActionButton(
      key: AppConstants.actionTaken,
      label: grouped
          ? AppLocale.l10n.notifAllTaken
          : type == ReminderType.medicine
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

/// Encodes which occurrence a notification belongs to: every reminder it
/// covers (one, or a group of medicines) and the scheduled time.
abstract final class NotificationPayload {
  static Map<String, String> encode(
    List<int> reminderIds,
    DateTime scheduledFor,
  ) => {
    AppConstants.payloadReminderIds: reminderIds.join(','),
    // Kept so the format stays readable by older code paths.
    AppConstants.payloadReminderId:
        '${ReminderAlarmEngine.leaderOf(reminderIds)}',
    AppConstants.payloadScheduledFor: scheduledFor.toIso8601String(),
  };

  static (List<int>, DateTime)? decode(Map<String, String?>? payload) {
    final at = DateTime.tryParse(
      payload?[AppConstants.payloadScheduledFor] ?? '',
    );
    final ids = [
      for (final s in (payload?[AppConstants.payloadReminderIds] ?? '').split(
        ',',
      ))
        ?int.tryParse(s),
    ];
    // Notifications posted before grouping only carry one id.
    if (ids.isEmpty) {
      final single = int.tryParse(
        payload?[AppConstants.payloadReminderId] ?? '',
      );
      if (single != null) ids.add(single);
    }
    return ids.isEmpty || at == null ? null : (ids, at);
  }
}
