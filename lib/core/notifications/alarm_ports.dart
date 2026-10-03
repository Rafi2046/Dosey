import '../../features/reminders/domain/reminder_with_details.dart';
import '../database/app_database.dart';

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

/// One notification booked with the OS ahead of time (iOS): reminders
/// [reminderIds] due at [at], shown as notification [id].
class AlarmBooking {
  const AlarmBooking({
    required this.id,
    required this.at,
    required this.reminderIds,
    required this.critical,
  });

  final int id;
  final DateTime at;
  final List<int> reminderIds;
  final bool critical;
}

/// A scheduler that can't run app code when an alarm fires (iOS: there's no
/// AlarmManager, and apps aren't woken for local notifications). Instead of
/// one alarm that re-arms the next, the engine books every upcoming
/// occurrence ahead as OS-delivered notifications.
abstract interface class BookAheadScheduler implements AlarmScheduler {
  /// Makes the OS's pending reminder notifications exactly [bookings].
  /// Snoozes (booked through [AlarmScheduler.schedule]) are left alone.
  Future<void> replaceBookings(List<AlarmBooking> bookings);
}

/// Shows/dismisses the ringing notification for a reminder occurrence.
abstract interface class NotificationPresenter {
  /// One notification for [group]: a single reminder, or several medicines
  /// due at the same minute (listed together, filed under the lowest id).
  Future<void> showAlarm(
    List<ReminderWithDetails> group,
    DateTime scheduledFor,
  );
  Future<void> dismiss(int reminderId);

  /// "Zulfidin is running low: about 3 days left."
  Future<void> showLowStock(Medicine medicine, int daysLeft);
}
