// Walks the missed-dose and course-countdown features on a real device,
// saving a screenshot of each step (build/screens/*.png via
// test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/adherence_test.dart -d <device>
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

final en = lookupAppLocalizations(AppLocale.english);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  var shot = 0;

  Future<void> snap(WidgetTester tester, String name) async {
    await settle(tester);
    shot++;
    await binding.takeScreenshot(
      'adherence_${shot.toString().padLeft(2, '0')}_$name',
    );
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final page = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    for (var i = 0; i < 20; i++) {
      final f = find.text(text).hitTestable();
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first);
        await settle(tester);
        return;
      }
      await tester.drag(page, const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('"$text" not found');
  }

  testWidgets('missed doses and course countdown', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // A daily dose 3 h ago, set up yesterday and never answered: missed
    // yesterday and today.
    final missedAt = now.subtract(const Duration(hours: 3));
    final reminders = RemindersRepository(db);

    final amoxicillin = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Amoxicillin',
            strength: const Value('500 mg'),
            form: const Value(MedicineForm.capsule),
            doseUnit: const Value('capsule'),
            // A 7-day course on its 3rd day.
            startDate: today.subtract(const Duration(days: 2)),
            endDate: Value(today.add(const Duration(days: 4))),
            stockQuantity: const Value(21),
          ),
        );
    final metformin = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Metformin',
            strength: const Value('500 mg'),
            startDate: today.subtract(const Duration(days: 30)),
            stockQuantity: const Value(40),
          ),
        );
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Amoxicillin',
        startAt: DateTime(
          today.year,
          today.month,
          today.day - 2,
          missedAt.hour,
          missedAt.minute,
        ),
        medicineId: Value(amoxicillin),
        repeatRule: const Value(RepeatRule.daily),
        updatedAt: Value(today.subtract(const Duration(days: 1))),
      ),
      now: now,
    );
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Metformin',
        startAt: today.subtract(const Duration(days: 30, hours: -23)),
        medicineId: Value(metformin),
        repeatRule: const Value(RepeatRule.daily),
      ),
      now: now,
    );
    for (final (key, value) in [
      (onboardingDoneKey, '1'),
      ('user_name', 'Rafi'),
    ]) {
      await db
          .into(db.appSettings)
          .insert(AppSettingsCompanion.insert(key: key, value: value));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          db: db,
          now: now,
          permissions: FakePermissionService(AppPermission.values.toSet()),
        ),
        child: const DoseyApp(),
      ),
    );
    // Android can only screenshot the Flutter view as an image.
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await settle(tester);

    // 1. Home: missed-doses warning, and the course pill on today's card.
    expect(find.text(en.missedDosesCount(2)), findsOneWidget);
    await snap(tester, 'home_missed_card');

    // 2. The sheet listing both doses.
    await tapText(tester, en.missedDosesCount(2));
    expect(find.text(en.takenLate), findsNWidgets(2));
    await snap(tester, 'missed_sheet');

    // 3. Mark one taken late, then the rest.
    await tester.tap(find.text(en.takenLate).first);
    await settle(tester);
    await snap(tester, 'missed_sheet_one_left');
    await tester.tap(find.text(en.takenLate).first);
    await settle(tester);
    expect(find.text(en.missedDosesTitle), findsNothing);
    expect(find.textContaining('missed dose'), findsNothing);
    await snap(tester, 'home_after_taken_late');
    final logs = await db.select(db.reminderLogs).get();
    expect(logs.map((l) => l.status).toSet(), {ReminderLogStatus.takenLate});
    final med = await (db.select(
      db.medicines,
    )..where((m) => m.id.equals(amoxicillin))).getSingle();
    expect(med.stockQuantity, 19);

    // 4. Medicines tab: countdown pill.
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(en.navMedicines),
      ),
    );
    await settle(tester);
    expect(find.text(en.courseDayOf(3, 7)), findsOneWidget);
    await snap(tester, 'medicines_countdown');

    // 5. Detail, then the form's course-duration picker.
    await tapText(tester, 'Amoxicillin 500 mg');
    await snap(tester, 'medicine_detail');
    await tapText(tester, en.changeSetting);
    await tapText(tester, en.courseDuration);
    await snap(tester, 'form_course_7_days');
    await tapText(tester, en.daysCount(3));
    await snap(tester, 'form_course_3_days');
    await tester.tap(find.text(en.saveChanges));
    await settle(tester);
    await snap(tester, 'detail_after_3_days');
    expect(
      find.text('${en.courseDayOf(3, 3)} · ${en.courseDaysLeft(0)}'),
      findsOneWidget,
    );
  });
}
