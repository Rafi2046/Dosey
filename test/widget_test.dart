import 'package:dosey/app/app.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/alarm/presentation/alarm_ring_screen.dart';
import 'package:dosey/app/widgets/app_nav_bar.dart';
import 'package:dosey/features/lock/providers/app_lock_providers.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:dosey/core/widgets/app_switch.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

  testWidgets('onboarding: welcome → name → features → permissions → home', (
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

    // Name: the button reads "Skip" until something is typed.
    expect(find.text(en.onboardingNameTitle), findsOneWidget);
    expect(find.text(en.skip), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Rafi ');
    await settle(tester);
    expect(find.text(en.skip), findsNothing);
    await tester.tap(find.text(en.onboardingContinue));
    await settle(tester);
    expect(await setting(tester, 'user_name'), 'Rafi');

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
    expect(findDashboardTitle(en.dashboardTitle), findsOneWidget);
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
    expect(find.text(bn.onboardingNameTitle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the name can be skipped', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.text(en.onboardingContinue));
    await settle(tester);

    await tester.tap(find.text(en.skip));
    await settle(tester);
    expect(find.text(en.featureScanTitle), findsOneWidget);
    expect(await setting(tester, 'user_name'), isNull);
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

  testWidgets('medicines ringing together share one screen; '
      '"All taken" logs them all', (tester) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);

    final at = DateTime(2026, 10, 3, 23);
    await dbRun(tester, () async {
      for (final name in ['Zulfidin', 'Calbo D']) {
        final med = await db
            .into(db.medicines)
            .insert(
              MedicinesCompanion.insert(
                name: name,
                startDate: DateTime(2026),
                stockQuantity: const Value(10),
              ),
            );
        final id = await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                type: ReminderType.medicine,
                title: name,
                startAt: at,
                medicineId: Value(med),
              ),
            );
        await RemindersRepository(db).setRinging(id, at);
      }
    });
    await settle(tester);

    // One screen listing both, not two screens in a row.
    expect(find.byType(AlarmRingScreen), findsOneWidget);
    expect(find.text(en.alarmGroupCount(2)), findsOneWidget);
    expect(find.text('Zulfidin'), findsOneWidget);
    expect(find.text('Calbo D'), findsOneWidget);

    await tester.tap(find.text(en.alarmMarkAllTaken));
    await settle(tester);

    expect(find.byType(AlarmRingScreen), findsNothing);
    final logs = await dbRun(tester, () => db.select(db.reminderLogs).get());
    expect(logs.map((l) => l.status), [
      ReminderLogStatus.taken,
      ReminderLogStatus.taken,
    ]);
    final stock = await dbRun(tester, () => db.select(db.medicines).get());
    expect(stock.map((m) => m.stockQuantity), [9, 9]);
    await unmount(tester);
  });

  testWidgets('ringing reminder opens the alarm screen; Taken closes it', (
    tester,
  ) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);
    expect(findDashboardTitle(en.dashboardTitle), findsOneWidget);

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

  testWidgets('medicine picker with no medicines offers to add one', (
    tester,
  ) async {
    usePhoneSize(tester);
    permissions = FakePermissionService(AppPermission.values.toSet());
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tester.tap(find.text(en.addReminder).last);
    await settle(tester);
    await tester.tap(find.text(en.choose).first);
    await settle(tester);

    // Not a blank sheet: it says why and what to do.
    expect(find.text(en.medicinePickerEmpty), findsOneWidget);
    await tester.tap(find.text(en.addNewMedicine));
    await settle(tester);
    await tester.tap(find.text(en.next));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Zulfidin');
    await tester.tap(find.text(en.save));
    // Saving, popping both screens, then looking up the new medicine.
    for (
      var i = 0;
      i < 5 && find.text(en.addReminder).evaluate().isEmpty;
      i++
    ) {
      await settle(tester);
    }

    // Then the lookup that selects it (more DB round trips).
    for (var i = 0; i < 10 && find.text('Zulfidin').evaluate().isEmpty; i++) {
      await settle(tester);
    }

    // Back on the reminder, with the new medicine already chosen.
    expect(find.text(en.addReminder), findsOneWidget);
    expect(find.text('Zulfidin'), findsWidgets);
    expect(find.text(en.selectMedicineError), findsNothing);
    await unmount(tester);
  });

  testWidgets('the alarm card shows the course day and an earlier missed '
      'dose, and stays stable when a second medicine joins it', (tester) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await tester.pumpWidget(app());
    await settle(tester);

    // 09:30 now. Napa: day 3 of 7, daily 09:30, and daily 06:00 since
    // yesterday, never answered (missed today). Seclo: added just now.
    final at = DateTime(2026, 10, 3, 9, 30);
    final (napaId, secloId) = await dbRun(tester, () async {
      final repo = RemindersRepository(db);
      Future<int> add(
        String name,
        String time,
        DateTime? end,
        DateTime edited,
      ) async {
        final med = await db
            .into(db.medicines)
            .insert(
              MedicinesCompanion.insert(
                name: name,
                startDate: DateTime(2026, 10, 1),
                endDate: Value(end),
              ),
            );
        final [h, m] = [for (final p in time.split(':')) int.parse(p)];
        final r = await repo.create(
          RemindersCompanion.insert(
            type: ReminderType.medicine,
            title: name,
            startAt: DateTime(2026, 10, 1, h, m),
            medicineId: Value(med),
            repeatRule: const Value(RepeatRule.daily),
            updatedAt: Value(edited),
          ),
          now: now,
        );
        return r.id;
      }

      final napa = await add(
        'Napa',
        '09:30',
        DateTime(2026, 10, 7),
        DateTime(2026, 10, 3),
      );
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: 'Napa',
              startAt: DateTime(2026, 10, 1, 6),
              medicineId: Value((await repo.getById(napa))!.medicineId!),
              repeatRule: const Value(RepeatRule.daily),
              updatedAt: Value(DateTime(2026, 10, 3)),
            ),
          );
      final seclo = await add(
        'Seclo',
        '09:30',
        null,
        DateTime(2026, 10, 3, 9, 29),
      );
      return (napa, seclo);
    });
    await settle(tester);

    await dbRun(tester, () => RemindersRepository(db).setRinging(napaId, at));
    await settle(tester);
    expect(find.byType(AlarmRingScreen), findsOneWidget);
    expect(find.text(en.alarmPreviousMissed), findsOneWidget);
    expect(
      find.text('${en.courseDayOf(3, 7)} · ${en.courseDaysLeft(4)}'),
      findsOneWidget,
    );

    // Seclo rings at the same minute: one grouped card, Napa's chips only.
    await dbRun(tester, () => RemindersRepository(db).setRinging(secloId, at));
    await settle(tester);
    expect(find.text(en.alarmGroupCount(2)), findsOneWidget);
    expect(find.text(en.alarmPreviousMissed), findsOneWidget);
    expect(find.text(en.courseDayOf(3, 7)), findsOneWidget);
    await unmount(tester);
  });

  group('app lock', () {
    late bool owner;
    late List<String> asked;
    late DateTime clock;

    Widget lockedApp() => ProviderScope(
      overrides: [
        ...testOverrides(db: db, now: now, permissions: permissions),
        appLockAuthProvider.overrideWithValue((reason) async {
          asked.add(reason);
          return owner;
        }),
        appLockClockProvider.overrideWithValue(() => clock),
      ],
      child: const DoseyApp(),
    );

    setUp(() {
      owner = false;
      asked = [];
      clock = DateTime(2026, 10, 3, 9);
    });

    Future<void> turnOn(WidgetTester tester) => dbRun(
      tester,
      () => db
          .into(db.appSettings)
          .insert(AppSettingsCompanion.insert(key: appLockKey, value: '1')),
    );

    testWidgets('locked at start until the owner unlocks; locks again after '
        'time away', (tester) async {
      usePhoneSize(tester);
      permissions.grantedSet.addAll(AppPermission.values);
      await turnOn(tester);
      await tester.pumpWidget(lockedApp());
      await settle(tester);

      // Asked straight away; a failed attempt keeps it locked.
      expect(find.text(en.appLockLocked), findsOneWidget);
      expect(asked, [en.appLockReason]);
      expect(findDashboardTitle(en.dashboardTitle).hitTestable(), findsNothing);

      owner = true;
      await tester.tap(find.text(en.appLockUnlock));
      await settle(tester);
      expect(find.text(en.appLockLocked), findsNothing);
      expect(
        findDashboardTitle(en.dashboardTitle).hitTestable(),
        findsOneWidget,
      );

      // A short trip away doesn't lock; a longer one does.
      void away(Duration d) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        clock = clock.add(d);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      }

      owner = false;
      away(const Duration(seconds: 10));
      await settle(tester);
      expect(find.text(en.appLockLocked), findsNothing);
      away(const Duration(seconds: 31));
      await settle(tester);
      expect(find.text(en.appLockLocked), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a ringing alarm shows even while locked', (tester) async {
      usePhoneSize(tester);
      permissions.grantedSet.addAll(AppPermission.values);
      await turnOn(tester);
      await tester.pumpWidget(lockedApp());
      await settle(tester);
      expect(find.text(en.appLockLocked), findsOneWidget);

      final at = DateTime(2026, 10, 3, 9);
      await dbRun(tester, () async {
        final med = await db
            .into(db.medicines)
            .insert(
              MedicinesCompanion.insert(
                name: 'Napa',
                startDate: DateTime(2026),
              ),
            );
        final id = await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                type: ReminderType.medicine,
                title: 'Napa',
                startAt: at,
                medicineId: Value(med),
              ),
            );
        await RemindersRepository(db).setRinging(id, at);
      });
      await settle(tester);
      expect(find.byType(AlarmRingScreen), findsOneWidget);
      expect(find.text(en.appLockLocked), findsNothing);
      await unmount(tester);
    });

    testWidgets('turning it on in Settings needs the owner first', (
      tester,
    ) async {
      usePhoneSize(tester);
      permissions.grantedSet.addAll(AppPermission.values);
      await tester.pumpWidget(lockedApp());
      await settle(tester);
      await tester.tap(find.byTooltip(en.settingsTitle));
      await settle(tester);

      Future<String?> stored() => setting(tester, appLockKey);
      // Not confirmed: stays off, with a hint.
      await tester.tap(
        find.descendant(
          of: find
              .ancestor(
                of: find.text(en.appLockTitle),
                matching: find.byType(Row),
              )
              .first,
          matching: find.byType(AppSwitch),
        ),
      );
      await settle(tester);
      expect(await stored(), isNull);
      expect(find.text(en.appLockUnavailable), findsOneWidget);

      owner = true;
      await tester.tap(
        find.descendant(
          of: find
              .ancestor(
                of: find.text(en.appLockTitle),
                matching: find.byType(Row),
              )
              .first,
          matching: find.byType(AppSwitch),
        ),
      );
      await settle(tester);
      expect(await stored(), '1');
      // Just unlocked to switch it on: not locked out right away.
      expect(find.text(en.appLockLocked), findsNothing);
      await unmount(tester);
    });
  });

  testWidgets('a family member gets their own medicines, and their alarm '
      'rings (named) whoever is open', (tester) async {
    usePhoneSize(tester);
    permissions.grantedSet.addAll(AppPermission.values);
    await dbRun(
      tester,
      () => db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(name: 'Napa', startDate: DateTime(2026)),
          ),
    );
    await tester.pumpWidget(app());
    await settle(tester);
    // One profile: no switcher anywhere.
    expect(find.byIcon(Icons.expand_more_rounded), findsNothing);
    expect(find.text(en.profileMe), findsNothing);

    // Settings › Family profiles › Add "Ammu".
    await tester.tap(find.byTooltip(en.settingsTitle));
    await settle(tester);
    await tester.tap(find.text(en.profilesTitle));
    await settle(tester);
    await tester.tap(find.text(en.profileAdd));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'Ammu');
    await tester.tap(find.text(en.save));
    await settle(tester);
    expect(find.text('Ammu'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);

    // Home now shows whose day it is; switch to Ammu.
    expect(find.text(en.profileMe), findsOneWidget);
    await tester.tap(find.text(en.profileMe));
    await settle(tester);
    expect(find.text(en.profileSwitchTitle), findsOneWidget);
    await tester.tap(find.text('Ammu').last);
    await settle(tester);
    expect(find.text('Ammu'), findsOneWidget);

    // Her medicines tab is empty; mine had Napa.
    final ids = await dbRun(tester, () async {
      final ammu = (await (db.select(
        db.profiles,
      )..where((p) => p.name.equals('Ammu'))).getSingle()).id;
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: 'Seclo',
              startDate: DateTime(2026),
              profileId: Value(ammu),
            ),
          );
      return (ammu, med);
    });
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(en.navMedicines),
      ),
    );
    await settle(tester);
    expect(find.textContaining('Seclo'), findsOneWidget);
    expect(find.textContaining('Napa'), findsNothing);

    // Back to me; Ammu's dose rings anyway, labelled with her name.
    await tester.tap(find.text('Ammu'));
    await settle(tester);
    await tester.tap(find.text(en.profileMe).last);
    await settle(tester);
    final at = DateTime(2026, 10, 3, 9);
    await dbRun(tester, () async {
      final id = await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: 'Seclo',
              startAt: at,
              medicineId: Value(ids.$2),
              profileId: Value(ids.$1),
            ),
          );
      await RemindersRepository(db).setRinging(id, at);
    });
    await settle(tester);
    expect(find.byType(AlarmRingScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlarmRingScreen),
        matching: find.text('Ammu'),
      ),
      findsOneWidget,
    );
    await unmount(tester);
  });
}
