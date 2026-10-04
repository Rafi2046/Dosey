// Screenshots the dose history screen with a week of mixed outcomes, in
// Bengali (build/screens/*.png via test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/dose_history_test.dart -d <device>
//
// Uses an in-memory database and fake alarms, so it never touches the data
// or alarms of an installed copy of Dosey.

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/app/widgets/app_nav_bar.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/permission_service.dart';
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

  testWidgets('dose history (bn)', (tester) async {
    final l = lookupAppLocalizations(AppLocale.bangla);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repo = RemindersRepository(db);

    // Two medicines, twice a day (08:00 and 20:00), for the last week.
    final weekAgo = today.subtract(const Duration(days: 6));
    final ids = <String, List<Reminder>>{};
    for (final name in ['Napa', 'Seclo']) {
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: name,
              strength: const Value('500 mg'),
              startDate: weekAgo,
            ),
          );
      for (final hour in [8, 20]) {
        (ids[name] ??= []).add(
          await repo.create(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: name,
              startAt: weekAgo.add(Duration(hours: hour)),
              medicineId: Value(med),
              repeatRule: const Value(RepeatRule.daily),
              updatedAt: Value(weekAgo),
            ),
            now: now,
          ),
        );
      }
    }
    // Mostly taken; a few late, skipped; the rest left unanswered (missed).
    for (var d = 0; d < 7; d++) {
      final day = weekAgo.add(Duration(days: d));
      for (final (i, r) in [...ids['Napa']!, ...ids['Seclo']!].indexed) {
        final at = DateTime(day.year, day.month, day.day, r.startAt.hour);
        if (at.isAfter(now)) continue;
        final status = switch ((d + i) % 7) {
          0 => null, // missed
          1 => ReminderLogStatus.takenLate,
          2 => ReminderLogStatus.skipped,
          _ => ReminderLogStatus.taken,
        };
        if (status != null) {
          await repo.logAction(
            reminderId: r.id,
            scheduledFor: at,
            status: status,
          );
        }
      }
    }
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
            permissions: FakePermissionService(AppPermission.values.toSet()),
          ),
          languageProvider.overrideWith(() => LanguageController('bn')),
        ],
        child: const DoseyApp(),
      ),
    );
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await settle(tester);

    // More › Dose history.
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(l.navMore),
      ),
    );
    await settle(tester);
    await binding.takeScreenshot('history_00_more_sheet_bn');
    await tester.tap(find.text(l.historyLink));
    await settle(tester);
    expect(find.text(l.historyAdherence), findsOneWidget);
    await binding.takeScreenshot('history_01_week_bn');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await settle(tester);
    await binding.takeScreenshot('history_02_scrolled_bn');

    // A missed dose can be marked as taken late from here.
    final missed = find.text(l.missed).hitTestable();
    for (var i = 0; i < 20 && missed.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(missed, findsWidgets);
    await tester.tap(missed.first);
    await settle(tester);
    await binding.takeScreenshot('history_03_mark_late_bn');
    await tester.tap(find.text(l.takenLate).last);
    await settle(tester);
    await binding.takeScreenshot('history_04_after_late_bn');
  });
}
