// iOS only: books real notifications through the production path
// (ReminderAlarmEngine → IosNotificationScheduler → awesome_notifications)
// for two medicines due at the same minute, ~2 minutes ahead. When the test
// ends `flutter drive` closes the app, so iOS must deliver the notification
// with Dosey not running.
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/ios_notification_test.dart -d <simulator>

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dosey/core/constants/app_constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/alarm_runtime.dart';
import 'package:dosey/core/notifications/notification_service.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('books a grouped alarm that rings with the app closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Tap "Allow" on the notification prompt')),
        ),
      ),
    );
    await AppLocale.ensureInitialized();
    AppLocale.apply(AppLocale.english);
    await NotificationService.initialize();

    // The system prompt: a person taps "Allow" (iOS has no way to grant it
    // from outside the app).
    await PermissionService().request(AppPermission.notifications);
    for (
      var i = 0;
      i < 120 && !await AwesomeNotifications().isNotificationAllowed();
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
    }
    expect(await AwesomeNotifications().isNotificationAllowed(), isTrue);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final due = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 2));
    final repo = RemindersRepository(db);
    for (final (name, amount) in [('Metformin', 2.0), ('Calbo D', 1.0)]) {
      final med = await db
          .into(db.medicines)
          .insert(MedicinesCompanion.insert(name: name, startDate: now));
      await repo.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: name,
          startAt: due,
          medicineId: Value(med),
          repeatRule: const Value(RepeatRule.daily),
          doseAmount: Value(amount),
        ),
        now: now,
      );
    }

    await AlarmRuntime.engineFor(db).syncAll();

    final pending = await AwesomeNotifications().listScheduledNotifications();
    final first =
        pending
            .where(
              (n) =>
                  n.content?.id != null &&
                  n.content!.id! < AppConstants.snoozeIdOffset,
            )
            .toList()
          ..sort((a, b) => a.content!.id!.compareTo(b.content!.id!));
    // ignore: avoid_print
    print(
      'IOSNOTIF due=$due pending=${first.length} '
      'title="${first.first.content?.title}" '
      'body="${first.first.content?.body}" '
      'sound=${first.first.content?.customSound} '
      'group=${first.first.content?.groupKey}',
    );
    // One booking per day for the pair (7 days ahead), not one per medicine.
    expect(first, hasLength(7));
    expect(first.first.content?.title, 'Time for 2 medicines');
    expect(first.first.content?.customSound, AppConstants.iosAlarmSound);
  });
}
