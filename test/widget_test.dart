import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/database/database_provider.dart';
import 'package:dosey/core/notifications/notification_providers.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/core/notifications/reminder_alarm_engine.dart';
import 'package:dosey/core/storage/storage_providers.dart';
import 'package:dosey/features/alarm/presentation/alarm_ring_screen.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeAlarmScheduler scheduler;
  late FakeNotificationPresenter notifier;
  late FakePermissionService permissions;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeAlarmScheduler();
    notifier = FakeNotificationPresenter();
    permissions = FakePermissionService();
  });
  tearDown(() => db.close());

  Widget app() => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
      permissionServiceProvider.overrideWithValue(permissions),
      alarmEngineProvider.overrideWith(
        (ref) => ReminderAlarmEngine(
          reminders: RemindersRepository(db),
          scheduler: scheduler,
          notifier: notifier,
        ),
      ),
    ],
    child: const DoseyApp(),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('onboarding gates on essential permissions', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text(AppStrings.permNotificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.onboardingEssentialHint), findsOneWidget);

    // Grant both essentials via their "Allow" pills.
    await tester.tap(find.text(AppStrings.allow).first);
    await settle(tester);
    await tester.tap(find.text(AppStrings.allow).first);
    await settle(tester);

    expect(permissions.requested, [
      AppPermission.notifications,
      AppPermission.exactAlarms,
    ]);
    expect(find.text(AppStrings.onboardingEssentialHint), findsNothing);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await settle(tester);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('ringing reminder opens the alarm screen; Taken closes it', (
    tester,
  ) async {
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text(AppStrings.tagline), findsOneWidget);

    final at = DateTime.now().copyWith(
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    await tester.runAsync(() async {
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: 'Insulin',
              startDate: DateTime(2026),
            ),
          );
      final id = await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: 'Insulin',
              startAt: at,
              medicineId: Value(med),
            ),
          );
      await RemindersRepository(db).setRinging(id, at);
    });
    await settle(tester);

    expect(find.byType(AlarmRingScreen), findsOneWidget);
    expect(find.text(AppStrings.alarmMarkTaken), findsOneWidget);

    await tester.tap(find.text(AppStrings.alarmMarkTaken));
    await settle(tester);

    expect(find.byType(AlarmRingScreen), findsNothing);
    final log = await tester.runAsync(
      () => db.select(db.reminderLogs).getSingle(),
    );
    expect(log!.status, ReminderLogStatus.taken);
  });
}
