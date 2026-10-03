import 'package:dosey/app/app.dart';
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
import 'package:dosey/core/localization/l10n.dart';

/// Tests run in English (the default for an en_US test device).
final en = lookupAppLocalizations(AppLocale.english);

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

  /// The user comes back to the app (e.g. from a system Settings page).
  Future<void> returnToApp(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
  }

  Future<String?> setting(WidgetTester tester, String key) => dbRun(
    tester,
    () async => (await (db.select(
      db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull())?.value,
  );

  testWidgets('onboarding: welcome → features → permissions → home', (
    tester,
  ) async {
    usePhoneSize(tester);
    // Like Android: only notifications is an in-app prompt.
    permissions = FakePermissionService({}, {
      AppPermission.exactAlarms,
      AppPermission.fullScreen,
      AppPermission.dnd,
    });
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text(en.onboardingChooseLanguage), findsOneWidget);
    await tester.tap(find.text(en.onboardingContinue));
    await settle(tester);
    expect(find.text(en.featureScanTitle), findsOneWidget);
    await tester.tap(find.text(en.next));
    await settle(tester);

    // Finish stays locked until the essentials are granted.
    expect(find.text(en.onboardingEssentialHint), findsOneWidget);
    await tester.tap(find.text(en.onboardingFinish));
    await settle(tester);
    expect(find.text(en.allowAll), findsOneWidget);

    // Allow all: notification prompt, then the exact-alarm Settings page.
    await tester.tap(find.text(en.allowAll));
    await settle(tester);
    expect(permissions.requested, [
      AppPermission.notifications,
      AppPermission.exactAlarms,
    ]);
    // User switches it on and comes back → the next page opens by itself.
    permissions.grant(AppPermission.exactAlarms);
    await returnToApp(tester);
    expect(permissions.requested.last, AppPermission.fullScreen);
    // Comes back without switching it on → it still moves on.
    await returnToApp(tester);
    expect(permissions.requested.last, AppPermission.dnd);
    permissions.grant(AppPermission.dnd);
    await returnToApp(tester);
    expect(permissions.requested, hasLength(4));

    expect(find.text(en.onboardingEssentialHint), findsNothing);
    await tester.tap(find.text(en.onboardingFinish));
    await settle(tester);
    expect(find.text(en.dashboardTitle), findsOneWidget);
    expect(await setting(tester, 'onboarding_done'), '1');
    await unmount(tester);
  });

  testWidgets('choosing বাংলা on the welcome page switches onboarding', (
    tester,
  ) async {
    addTearDown(() => AppLocale.apply(AppLocale.english));
    final bn = lookupAppLocalizations(AppLocale.bangla);
    usePhoneSize(tester);
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('বাংলা'));
    await settle(tester);
    expect(find.text(bn.onboardingChooseLanguage), findsOneWidget);
    expect(await setting(tester, AppLocale.settingKey), 'bn');

    await tester.tap(find.text(bn.onboardingContinue));
    await settle(tester);
    expect(find.text(bn.featureScanTitle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a revoked permission reopens onboarding at permissions', (
    tester,
  ) async {
    usePhoneSize(tester);
    await dbRun(
      tester,
      () => db
          .into(db.appSettings)
          .insert(
            AppSettingsCompanion.insert(key: 'onboarding_done', value: '1'),
          ),
    );
    permissions = FakePermissionService({AppPermission.notifications});
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text(en.onboardingChooseLanguage), findsNothing);
    expect(find.text(en.allowAll), findsOneWidget);
    await tester.tap(find.text(en.allowAll));
    await settle(tester);
    expect(permissions.requested.first, AppPermission.exactAlarms);
    await unmount(tester);
  });

  testWidgets('ringing reminder opens the alarm screen; Taken closes it', (
    tester,
  ) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text(en.dashboardTitle), findsOneWidget);

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
    await tester.tap(find.text(en.alarmMarkTaken));
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
