import 'dart:io';

import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/database/database_provider.dart';
import 'package:dosey/core/notifications/notification_providers.dart';
import 'package:dosey/core/notifications/reminder_alarm_engine.dart';
import 'package:dosey/core/storage/storage_providers.dart';
import 'package:dosey/core/utils/clock_providers.dart';
import 'package:dosey/features/onboarding/providers/permissions_provider.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Provider overrides that replace every platform/timer dependency, so widget
/// tests run against an in-memory DB with no plugins and no pending timers.
List<Override> testOverrides({
  required AppDatabase db,
  required DateTime now,
  FakePermissionService? permissions,
  FakeAlarmScheduler? scheduler,
  FakeNotificationPresenter? notifier,
}) => [
  appDatabaseProvider.overrideWithValue(db),
  documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
  permissionServiceProvider.overrideWithValue(
    permissions ?? FakePermissionService(),
  ),
  alarmChannelRefresherProvider.overrideWithValue(() async {}),
  alarmEngineProvider.overrideWith(
    (ref) => ReminderAlarmEngine(
      reminders: RemindersRepository(db),
      scheduler: scheduler ?? FakeAlarmScheduler(),
      notifier: notifier ?? FakeNotificationPresenter(),
      clock: () => now,
    ),
  ),
  // The real clocks sleep until the next minute/day, which would leave
  // timers pending when the test ends.
  minuteTickerProvider.overrideWith((ref) => Stream.value(now)),
  currentDayProvider.overrideWith(
    (ref) => Stream.value(DateTime(now.year, now.month, now.day)),
  ),
];

/// Realistic phone viewport (1080×2400 @ 2.75x ≈ Galaxy A52).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

/// Pumps frames so streams and DB work queued in the fake zone complete.
Future<void> settle(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Runs a DB op in the fake-async zone, pumping until done (`runAsync`
/// would deadlock: Drift work queued in the fake zone needs pumps).
Future<T> dbRun<T>(WidgetTester tester, Future<T> Function() op) async {
  T? result;
  var done = false;
  op().then((value) {
    result = value;
    done = true;
  });
  for (var i = 0; i < 100 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'DB operation did not complete');
  return result as T;
}

/// Unmounts so Drift's stream-cleanup timers fire before the binding
/// checks for pending timers.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
