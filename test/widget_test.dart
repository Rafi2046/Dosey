import 'package:dosey/app/app.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/alarm/presentation/alarm_ring_screen.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  late AppDatabase db;
  late FakePermissionService permissions;
  final now = DateTime(2026, 10, 3, 9, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    permissions = FakePermissionService();
  });
  tearDown(() => db.close());

  Widget app() => ProviderScope(
    overrides: testOverrides(db: db, now: now, permissions: permissions),
    child: const DoseyApp(),
  );

  testWidgets('onboarding gates on essential permissions', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text(AppStrings.permNotificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.onboardingEssentialHint), findsOneWidget);

    for (var i = 0; i < 2; i++) {
      final allow = find.text(AppStrings.allow).first;
      await tester.ensureVisible(allow);
      await tester.tap(allow);
      await settle(tester);
    }

    expect(permissions.requested, [
      AppPermission.notifications,
      AppPermission.exactAlarms,
    ]);
    expect(find.text(AppStrings.onboardingEssentialHint), findsNothing);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await settle(tester);
    expect(find.text(AppStrings.dashboardTitle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('ringing reminder opens the alarm screen; Taken closes it', (
    tester,
  ) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text(AppStrings.dashboardTitle), findsOneWidget);

    final at = DateTime(2026, 10, 3, 9);
    await dbRun(tester, () async {
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
    await tester.tap(find.text(AppStrings.alarmMarkTaken));
    await settle(tester);

    expect(find.byType(AlarmRingScreen), findsNothing);
    final log = await dbRun(
      tester,
      () => db.select(db.reminderLogs).getSingle(),
    );
    expect(log.status, ReminderLogStatus.taken);
    await unmount(tester);
  });
}
