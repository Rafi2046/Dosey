import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../features/reminders/data/reminders_repository.dart';
import '../database/app_database.dart';
import 'android_alarm_scheduler.dart';
import 'awesome_notification_presenter.dart';
import 'notification_service.dart';
import 'reminder_alarm_engine.dart';

/// Per-isolate access to the alarm engine for code that runs outside the
/// widget tree: alarm callbacks and notification-action handlers.
///
/// The UI isolate calls [adopt] with its database so everything shares one
/// connection; background isolates lazily open their own (Drift's
/// `shareAcrossIsolates` routes it to the same server when the app is alive).
abstract final class AlarmRuntime {
  static AppDatabase? _db;
  static ReminderAlarmEngine? _engine;
  static Future<ReminderAlarmEngine>? _starting;

  static void adopt(AppDatabase db) {
    _db = db;
    _engine = null;
  }

  static Future<ReminderAlarmEngine> engine() =>
      _engine != null ? Future.value(_engine) : (_starting ??= _start());

  static ReminderAlarmEngine engineFor(AppDatabase db) => ReminderAlarmEngine(
    reminders: RemindersRepository(db),
    scheduler: AndroidAlarmScheduler(),
    notifier: AwesomeNotificationPresenter(),
  );

  static Future<ReminderAlarmEngine> _start() async {
    if (_db == null) {
      // Background isolate: plugins implemented in Dart (path_provider) must
      // be registered manually before use.
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      await NotificationService.initialize();
      _db = AppDatabase();
    }
    return _engine = engineFor(_db!);
  }
}
