import 'package:dosey/core/notifications/alarm_ports.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/reminders/domain/reminder_with_details.dart';

class ScheduledAlarm {
  ScheduledAlarm(this.at, this.params, this.critical);
  final DateTime at;
  final Map<String, dynamic> params;
  final bool critical;
}

class FakeAlarmScheduler implements AlarmScheduler {
  final Map<int, ScheduledAlarm> alarms = {};

  @override
  Future<void> schedule({
    required int alarmId,
    required DateTime at,
    required Map<String, dynamic> params,
    required bool critical,
  }) async => alarms[alarmId] = ScheduledAlarm(at, params, critical);

  @override
  Future<void> cancel(int alarmId) async => alarms.remove(alarmId);
}

class FakeNotificationPresenter implements NotificationPresenter {
  final Map<int, DateTime> showing = {};

  @override
  Future<void> showAlarm(ReminderWithDetails d, DateTime scheduledFor) async =>
      showing[d.reminder.id] = scheduledFor;

  @override
  Future<void> dismiss(int reminderId) async => showing.remove(reminderId);
}

class FakePermissionService implements PermissionService {
  FakePermissionService([Set<AppPermission>? initial])
    : grantedSet = {...?initial};

  final Set<AppPermission> grantedSet;
  final List<AppPermission> requested = [];

  @override
  Future<Set<AppPermission>> granted() async => {...grantedSet};

  @override
  Future<void> request(AppPermission permission) async {
    requested.add(permission);
    grantedSet.add(permission);
  }
}
