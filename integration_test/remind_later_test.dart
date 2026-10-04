// Screenshots "Remind me later" on the full-screen alarm, in Bengali
// (build/screens/*.png via test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/remind_later_test.dart -d <device>
//
// Uses an in-memory database and fake alarms, so it never touches the data
// or alarms of an installed copy of Dosey.

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/core/notifications/reminder_alarm_engine.dart';
import 'package:dosey/features/alarm/presentation/alarm_ring_screen.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:dosey/features/settings/providers/settings_providers.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('remind me later (bn)', (tester) async {
    final l = lookupAppLocalizations(AppLocale.bangla);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final at = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final repo = RemindersRepository(db);
    final scheduler = FakeAlarmScheduler();

    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            startDate: at,
            mealRelation: const Value(MealRelation.afterMeal),
          ),
        );
    final r = await repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Napa',
        startAt: at,
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        doseAmount: const Value(2),
      ),
      now: now,
    );
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: onboardingDoneKey, value: '1'),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(
            db: db,
            now: now,
            scheduler: scheduler,
            permissions: FakePermissionService(AppPermission.values.toSet()),
          ),
          languageProvider.overrideWith(() => LanguageController('bn')),
        ],
        child: const DoseyApp(),
      ),
    );
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await settle(tester);

    await repo.setRinging(r.id, at);
    await settle(tester, frames: 20);
    expect(find.byType(AlarmRingScreen), findsOneWidget);
    await binding.takeScreenshot('remind_later_01_alarm_bn');

    await tester.tap(find.text(l.remindLater));
    await settle(tester);
    await binding.takeScreenshot('remind_later_02_sheet_bn');

    await tester.tap(find.text(l.remindLaterIn(l.inHoursMinutes(2, 0))));
    await settle(tester, frames: 20);
    expect(find.byType(AlarmRingScreen), findsNothing);
    final snooze = scheduler.alarms[ReminderAlarmEngine.snoozeAlarmId(r.id)]!;
    expect(
      snooze.at.difference(DateTime.now()).inMinutes,
      inInclusiveRange(118, 120),
    );
    final log = await db.select(db.reminderLogs).getSingle();
    expect(log.status, ReminderLogStatus.snoozed);
    await binding.takeScreenshot('remind_later_03_home_bn');
  });
}
