// Walks the newer features on a real device, in Bengali, saving a screenshot
// of each (build/screens/*.png via test_driver/integration_test.dart):
// backup and restore, the doctor report, App lock, medicine name
// suggestions, appointment heads-ups, family profiles, empty records.
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/new_features_test.dart -d <device>
//
// Uses an in-memory database and fake alarms, so it never touches the data
// or alarms of an installed copy of Dosey. The share sheet and the phone's
// lock prompt are faked (they're system UI a test can't drive).

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/app/widgets/app_nav_bar.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/core/utils/share_providers.dart';
import 'package:dosey/core/widgets/back_arrow_button.dart';
import 'package:dosey/core/widgets/suggest_field.dart';
import 'package:dosey/features/alarm/presentation/alarm_ring_screen.dart';
import 'package:dosey/features/lock/providers/app_lock_providers.dart';
import 'package:dosey/features/medicines/providers/medicines_providers.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:dosey/features/settings/providers/settings_providers.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final l = lookupAppLocalizations(AppLocale.bangla);
  var shot = 0;
  var surfaceReady = false;

  Future<void> snap(WidgetTester tester, String name) async {
    await settle(tester);
    if (Platform.isAndroid && !surfaceReady) {
      await binding.convertFlutterSurfaceToImage();
      surfaceReady = true;
      await settle(tester);
    }
    shot++;
    await binding.takeScreenshot(
      'new_${shot.toString().padLeft(2, '0')}_$name',
    );
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    final page = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    // Back to the top first: the target may be above.
    for (var i = 0; i < 12; i++) {
      if (find.text(text).hitTestable().evaluate().isNotEmpty) return;
      await tester.drag(page, const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 50));
    }
    for (var i = 0; i < 25; i++) {
      if (find.text(text).hitTestable().evaluate().isNotEmpty) return;
      await tester.drag(page, const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('"$text" not found');
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await scrollTo(tester, text);
    await tester.tap(find.text(text).hitTestable().first);
    await settle(tester);
  }

  /// The on-screen back arrow (pageBack looks for an English "Back").
  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byType(BackArrowButton).hitTestable().last);
    await settle(tester);
  }

  Future<void> nav(WidgetTester tester, String tooltip) async {
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(tooltip),
      ),
    );
    await settle(tester);
  }

  testWidgets('new features (bn)', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repo = RemindersRepository(db);
    File? shared;
    var owner = false;

    final napa = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            strength: const Value('500 mg'),
            startDate: today.subtract(const Duration(days: 5)),
            endDate: Value(today.add(const Duration(days: 4))),
          ),
        );
    await repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Napa',
        startAt: today.subtract(const Duration(days: 5, hours: -8)),
        medicineId: Value(napa),
        repeatRule: const Value(RepeatRule.daily),
      ),
      now: now,
    );
    await db
        .into(db.bloodPressureReadings)
        .insert(
          BloodPressureReadingsCompanion.insert(
            systolic: 132,
            diastolic: 86,
            measuredAt: now.subtract(const Duration(days: 1)),
          ),
        );
    await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            type: RecordType.testReport,
            title: 'CBC',
            recordDate: today,
          ),
        );
    for (final (key, value) in [
      (onboardingDoneKey, '1'),
      ('user_name', 'রাফি'),
    ]) {
      await db
          .into(db.appSettings)
          .insert(AppSettingsCompanion.insert(key: key, value: value));
    }
    await (db.update(db.profiles)..where((p) => p.id.equals(1))).write(
      const ProfilesCompanion(name: Value('রাফি')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(
            db: db,
            now: now,
            permissions: FakePermissionService(AppPermission.values.toSet()),
          ),
          languageProvider.overrideWith(() => LanguageController('bn')),
          fileSharerProvider.overrideWithValue((file, _) async {
            shared = file;
            return true;
          }),
          appLockAuthProvider.overrideWithValue((_) async => owner),
        ],
        child: const DoseyApp(),
      ),
    );
    await settle(tester);

    // ── Settings: backup, restore, App lock, family profiles ──────────────
    await tester.tap(find.byTooltip(l.settingsTitle));
    await settle(tester);
    await snap(tester, 'settings_top');
    await scrollTo(tester, l.restoreTitle);
    await snap(tester, 'settings_data');

    // A real backup file, written on the device.
    await tapText(tester, l.backupTitle);
    for (var i = 0; i < 40 && shared == null; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(shared, isNotNull);
    expect(shared!.lengthSync(), greaterThan(1000));
    await snap(tester, 'after_backup');

    // App lock can't be turned on without the owner.
    await scrollTo(tester, l.appLockTitle);
    await tester.tap(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.text(l.appLockTitle),
                  matching: find.byType(Row),
                )
                .first,
            matching: find.byType(Switch),
          )
          .first,
      warnIfMissed: false,
    );
    await settle(tester);
    expect(
      await (db.select(
        db.appSettings,
      )..where((s) => s.key.equals(appLockKey))).getSingleOrNull(),
      isNull,
    );

    // Its "set a screen lock first" message would cover the next button.
    ScaffoldMessenger.of(
      tester.element(find.text(l.appLockTitle)),
    ).clearSnackBars();
    await settle(tester);

    // Family profiles: add Ammu.
    await tapText(tester, l.profilesTitle);
    await tester.tap(find.text(l.profileAdd));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'আম্মু');
    await tester.tap(find.text(l.save));
    await settle(tester);
    await snap(tester, 'profiles');
    await back(tester);
    await settle(tester);
    await back(tester);
    await settle(tester);

    // ── Home: the profile pill and switcher ───────────────────────────────
    expect(find.text('রাফি'), findsWidgets);
    await snap(tester, 'home_with_profiles');
    await tester.tap(find.text('রাফি').last);
    await settle(tester);
    await snap(tester, 'profile_switcher');
    await tester.tap(find.text('আম্মু').last);
    await settle(tester);
    await nav(tester, l.navMedicines);
    await snap(tester, 'ammu_medicines_empty');

    // ── Ammu's alarm, while Rafi's profile is open ───────────────────────
    await nav(tester, l.navHome);
    await tester.tap(find.text('আম্মু').first);
    await settle(tester);
    await tester.tap(find.text('রাফি').last);
    await settle(tester);
    final ammu = (await (db.select(
      db.profiles,
    )..where((p) => p.name.equals('আম্মু'))).getSingle()).id;
    final seclo = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Seclo',
            strength: const Value('20 mg'),
            startDate: today,
            profileId: Value(ammu),
          ),
        );
    final at = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final ammuDose = await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            type: ReminderType.medicine,
            title: 'Seclo',
            startAt: at,
            medicineId: Value(seclo),
            profileId: Value(ammu),
          ),
        );
    await repo.setRinging(ammuDose, at);
    await settle(tester, frames: 20);
    expect(find.byType(AlarmRingScreen), findsOneWidget);
    await snap(tester, 'alarm_for_ammu');
    await tapText(tester, l.alarmMarkTaken);

    // ── Restore the backup taken before Ammu existed ──────────────────────
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppNavBar)),
    );
    await container
        .read(backupServiceProvider)
        .restore(
          shared!.readAsBytesSync(),
          workDir: Directory.systemTemp.createTempSync('dosey_restore_test'),
        );
    expect((await db.select(db.profiles).get()).map((p) => p.name), ['রাফি']);

    // ── Doctor report ─────────────────────────────────────────────────────
    await nav(tester, l.navMore);
    await tapText(tester, l.reportShowDoctor);
    await snap(tester, 'doctor_report');
    shared = null;
    await tester.tap(find.text(l.reportShare));
    for (var i = 0; i < 60 && shared == null; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(shared!.path, endsWith('.png'));
    expect(shared!.lengthSync(), greaterThan(10000));
    await back(tester);
    await settle(tester);

    // ── Medicine name suggestions ─────────────────────────────────────────
    await tester.tap(find.byTooltip(l.add));
    await settle(tester);
    await tapText(tester, l.addMedicine);
    await tapText(tester, l.next);
    await container.read(medicineNamesProvider.future);
    await tester.enterText(
      find.descendant(
        of: find.byWidgetPredicate((w) => w is SuggestField),
        matching: find.byType(TextFormField),
      ),
      'nap',
    );
    await settle(tester);
    await snap(tester, 'name_suggestions');
    await back(tester);
    await settle(tester);
    await back(tester);
    await settle(tester);

    // ── Appointment heads-up choice ───────────────────────────────────────
    await tester.tap(find.byTooltip(l.add));
    await settle(tester);
    await tapText(tester, l.addReminder);
    await tapText(tester, l.typeAppointment);
    await scrollTo(tester, l.headsUpLabel);
    await snap(tester, 'appointment_heads_up');
    await back(tester);
    await settle(tester);

    // ── A record without pages ────────────────────────────────────────────
    await nav(tester, l.navMore);
    await tapText(tester, l.navRecords);
    await tapText(tester, 'CBC');
    await snap(tester, 'record_no_pages');
    await back(tester);
    await settle(tester);

    // ── App lock ──────────────────────────────────────────────────────────
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: appLockKey, value: '1'));
    container
      ..invalidate(appLockEnabledProvider)
      ..read(appLockedProvider.notifier).lock();
    await settle(tester, frames: 20);
    expect(find.text(l.appLockLocked), findsOneWidget);
    await snap(tester, 'lock_screen');
    owner = true;
    await tester.tap(find.text(l.appLockUnlock));
    await settle(tester);
    expect(find.text(l.appLockLocked), findsNothing);
  });
}
