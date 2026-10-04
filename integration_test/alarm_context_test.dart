// Screenshots the full-screen alarm with its course countdown and
// previous-missed-dose warning, alone and grouped, in Bengali and English
// (build/screens/*.png via test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/alarm_context_test.dart -d <device>
//
// Uses an in-memory database and fake alarms, so it never touches the data
// or alarms of an installed copy of Dosey.

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/permission_service.dart';
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

  for (final locale in [AppLocale.bangla, AppLocale.english]) {
    final code = locale.languageCode;
    testWidgets('alarm card context ($code)', (tester) async {
      final l = lookupAppLocalizations(locale);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final ringAt = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );
      final missedAt = now.subtract(const Duration(hours: 3));
      final reminders = RemindersRepository(db);

      Future<int> medicine(String name, {DateTime? end}) => db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: name,
              startDate: today.subtract(const Duration(days: 1)),
              endDate: Value(end),
              mealRelation: const Value(MealRelation.afterMeal),
            ),
          );
      Future<Reminder> daily(
        int med,
        String title,
        DateTime at, {
        DateTime? editedAt,
      }) => reminders.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: title,
          startAt: DateTime(
            today.year,
            today.month,
            today.day - 1,
            at.hour,
            at.minute,
          ),
          medicineId: Value(med),
          repeatRule: const Value(RepeatRule.daily),
          doseAmount: const Value(2),
          updatedAt: Value(editedAt ?? today.subtract(const Duration(days: 1))),
        ),
        now: now,
      );

      // Napa: day 2 of a 7-day course, ringing now; its dose 3 h ago
      // (and yesterday's) went unanswered.
      final napa = await medicine(
        'Napa',
        end: today.add(const Duration(days: 5)),
      );
      final napaNow = await daily(napa, 'Napa', ringAt);
      await daily(napa, 'Napa', missedAt);
      // Seclo: ongoing, nothing missed, due at the same minute.
      final seclo = await medicine('Seclo');
      // Added just now, so it has no earlier doses to have missed.
      final secloNow = await daily(
        seclo,
        'Seclo',
        ringAt,
        editedAt: now.subtract(const Duration(minutes: 1)),
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
              permissions: FakePermissionService(AppPermission.values.toSet()),
            ),
            languageProvider.overrideWith(() => LanguageController(code)),
          ],
          child: const DoseyApp(),
        ),
      );
      if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
      await settle(tester);

      // Napa alone.
      await reminders.setRinging(napaNow.id, ringAt);
      await settle(tester, frames: 20);
      expect(find.byType(AlarmRingScreen), findsOneWidget);
      expect(find.text(l.alarmPreviousMissed), findsOneWidget);
      expect(
        find.text('${l.courseDayOf(2, 7)} · ${l.courseDaysLeft(5)}'),
        findsOneWidget,
      );
      await binding.takeScreenshot('alarm_context_single_$code');

      // Napa and Seclo together: only Napa gets the chips.
      await reminders.setRinging(secloNow.id, ringAt);
      await settle(tester, frames: 20);
      expect(find.text(l.alarmPreviousMissed), findsOneWidget);
      expect(find.text(l.courseDayOf(2, 7)), findsOneWidget);
      await binding.takeScreenshot('alarm_context_group_$code');
    });
  }
}
