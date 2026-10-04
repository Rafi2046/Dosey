import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/alarm_ports.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/medicines/data/prescription_scanner_service.dart';
import 'package:dosey/features/medicines/domain/scanned_doctor.dart';
import 'package:dosey/features/medicines/domain/scanned_medicine.dart';
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

/// iOS-style scheduler: records what the engine books ahead.
class FakeBookAheadScheduler extends FakeAlarmScheduler
    implements BookAheadScheduler {
  List<AlarmBooking> bookings = [];

  @override
  Future<void> replaceBookings(List<AlarmBooking> next) async =>
      bookings = next;
}

class FakeNotificationPresenter implements NotificationPresenter {
  /// Reminder id → occurrence, for every reminder in a shown notification.
  final Map<int, DateTime> showing = {};

  /// The reminder ids of each notification posted, in order.
  final List<List<int>> posted = [];

  @override
  Future<void> showAlarm(
    List<ReminderWithDetails> group,
    DateTime scheduledFor,
  ) async {
    posted.add([for (final d in group) d.reminder.id]);
    for (final d in group) {
      showing[d.reminder.id] = scheduledFor;
    }
  }

  @override
  Future<void> dismiss(int reminderId) async => showing.remove(reminderId);

  /// (medicine name, days left) of each low-stock notification.
  final List<(String, int)> lowStock = [];

  @override
  Future<void> showLowStock(Medicine medicine, int daysLeft) async =>
      lowStock.add((medicine.name, daysLeft));
}

class FakePermissionService implements PermissionService {
  /// [viaSettings]: requesting these only "opens Settings"; they stay denied
  /// until the test calls [grant] (the user switching them on).
  FakePermissionService([
    Set<AppPermission>? initial,
    this.viaSettings = const {},
  ]) : grantedSet = {...?initial};

  final Set<AppPermission> grantedSet;
  final Set<AppPermission> viaSettings;
  final List<AppPermission> requested = [];

  void grant(AppPermission permission) => grantedSet.add(permission);

  /// Set to simulate an iPhone; null = Android.
  ({bool sound, bool critical})? iosSound;
  int openedNotificationSettings = 0;

  @override
  Future<({bool sound, bool critical})?> iosSoundStatus() async => iosSound;

  @override
  Future<void> openNotificationSettings() async => openedNotificationSettings++;

  @override
  Future<Set<AppPermission>> granted() async => {...grantedSet};

  @override
  Future<void> request(AppPermission permission) async {
    requested.add(permission);
    if (!viaSettings.contains(permission)) grantedSet.add(permission);
  }
}

class FakePrescriptionScanner implements PrescriptionScannerService {
  FakePrescriptionScanner(this.result, {this.doctor});
  final List<ScannedMedicine> result;
  final ScannedDoctor? doctor;
  final List<String> scannedPaths = [];

  @override
  Future<List<String>> recognizeLines(String imagePath) async => const [];

  @override
  Future<ScannedPrescription> scan(String imagePath) async {
    scannedPaths.add(imagePath);
    return ScannedPrescription(doctor: doctor, medicines: result);
  }
}
