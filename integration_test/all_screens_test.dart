// Walks every screen of the app on a real device/simulator with sample
// data, saving a screenshot of each (build/screens/*.png via
// test_driver/integration_test.dart). Any layout or runtime error fails it.
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/all_screens_test.dart -d <device>
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

Future<void> _seed(AppDatabase db, DateTime now) async {
  final reminders = RemindersRepository(db);
  final today = DateTime(now.year, now.month, now.day);
  final doctor = await db
      .into(db.doctors)
      .insert(
        DoctorsCompanion.insert(
          name: 'Dr. Farhana Rahman',
          specialty: const Value('Endocrinology'),
          phone: const Value('01711000000'),
          clinic: const Value('Square Hospital, Dhaka'),
          consultationFeeMinor: const Value(100000),
        ),
      );
  Future<int> medicine(String name, double stock, int price) => db
      .into(db.medicines)
      .insert(
        MedicinesCompanion.insert(
          name: name,
          strength: const Value('500 mg'),
          startDate: today,
          doctorId: Value(doctor),
          stockQuantity: Value(stock),
          unitPriceMinor: Value(price),
          refillAlertDays: const Value(5),
        ),
      );
  final metformin = await medicine('Metformin', 40, 300);
  final calbo = await medicine('Calbo D', 6, 500);
  for (final (med, title, hour, amount) in [
    (metformin, 'Metformin', 8, 1.0),
    (metformin, 'Metformin', 21, 2.0),
    (calbo, 'Calbo D', 21, 1.0), // shares 9 pm with Metformin
  ]) {
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: title,
        startAt: today.add(Duration(hours: hour)),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        doseAmount: Value(amount),
      ),
      now: now,
    );
  }
  await reminders.create(
    RemindersCompanion.insert(
      type: ReminderType.appointment,
      title: 'Diabetes follow-up',
      startAt: today.add(const Duration(days: 2, hours: 17)),
      doctorId: Value(doctor),
      location: const Value('Square Hospital'),
    ),
    now: now,
  );
  await db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          type: RecordType.prescription,
          title: 'Endocrinology prescription',
          recordDate: today,
          doctorId: Value(doctor),
        ),
      );
  await db
      .into(db.expenses)
      .insert(
        ExpensesCompanion.insert(
          category: ExpenseCategory.medicine,
          title: 'Metformin strip',
          amountMinor: 4500,
          spentOn: today,
          medicineId: Value(metformin),
        ),
      );
  for (final (sys, dia, pulse, daysAgo) in [
    (128, 84, 72, 0),
    (135, 88, 75, 2),
    (122, 79, 70, 4),
  ]) {
    await db
        .into(db.bloodPressureReadings)
        .insert(
          BloodPressureReadingsCompanion.insert(
            systolic: sys,
            diastolic: dia,
            pulse: Value(pulse),
            measuredAt: now.subtract(Duration(days: daysAgo, hours: 1)),
          ),
        );
  }
  for (final (mmol, ctx, daysAgo) in [
    (6.4, SugarContext.fasting, 0),
    (8.9, SugarContext.afterMeal, 1),
    (5.4, SugarContext.fasting, 3),
  ]) {
    await db
        .into(db.bloodSugarReadings)
        .insert(
          BloodSugarReadingsCompanion.insert(
            mmol: mmol,
            context: ctx,
            measuredAt: now.subtract(Duration(days: daysAgo, hours: 2)),
          ),
        );
  }
  await db
      .into(db.appSettings)
      .insert(AppSettingsCompanion.insert(key: 'user_name', value: 'Rafi'));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  var shot = 0;

  Future<void> snap(WidgetTester tester, String name) async {
    await settle(tester);
    shot++;
    await binding.takeScreenshot('${shot.toString().padLeft(2, '0')}_$name');
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

  Future<void> back(WidgetTester tester) async {
    await tester.pageBack();
    await settle(tester);
  }

  Future<void> nav(WidgetTester tester, String tooltip) async {
    final target = find.descendant(
      of: find.byType(AppNavBar),
      matching: find.byTooltip(tooltip),
    );
    // The nav bar slides away while scrolling; give it time to come back.
    for (var i = 0; i < 30 && target.hitTestable().evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (target.evaluate().isEmpty) {
      final tips = [
        for (final e in find.byType(Tooltip).evaluate())
          (e.widget as Tooltip).message,
      ];
      fail('nav "$tooltip" not found; tooltips on screen: $tips');
    }
    await tester.tap(target);
    await settle(tester);
  }

  Future<void> pumpDosey(
    WidgetTester tester,
    AppDatabase db, {
    bool granted = true,
  }) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          db: db,
          now: now,
          // Onboarding only shows while permissions are missing.
          permissions: FakePermissionService(
            granted ? AppPermission.values.toSet() : {},
          ),
        ),
        child: const DoseyApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('every screen renders', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    await _seed(db, now);
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: onboardingDoneKey, value: '1'),
        );
    await pumpDosey(tester, db);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    await snap(tester, 'home');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await snap(tester, 'home_lower');

    await nav(tester, en.navReminders);
    await snap(tester, 'reminders');
    await tapText(tester, 'Diabetes follow-up');
    await snap(tester, 'reminder_form');
    await back(tester);

    await nav(tester, en.navMedicines);
    await snap(tester, 'medicines');
    await tapText(tester, 'Metformin 500 mg');
    await snap(tester, 'medicine_detail');
    await back(tester);

    await nav(tester, en.navMore);
    await snap(tester, 'more_sheet');
    await tapText(tester, en.navDoctors);
    await snap(tester, 'doctors');
    await tapText(tester, 'Dr. Farhana Rahman');
    await snap(tester, 'doctor_detail');
    await back(tester);

    await nav(tester, en.navMore);
    await tapText(tester, en.navRecords);
    await snap(tester, 'records');
    await tapText(tester, 'Endocrinology prescription');
    await snap(tester, 'record_detail');
    await back(tester);

    await nav(tester, en.navMore);
    await tapText(tester, en.navExpenses);
    await snap(tester, 'expenses');

    await nav(tester, en.navMore);
    await tapText(tester, en.bpShortTitle);
    await snap(tester, 'blood_pressure');
    await tapText(tester, en.bpAdd);
    await snap(tester, 'blood_pressure_form');
    await back(tester);
    await back(tester);

    await nav(tester, en.navMore);
    await tapText(tester, en.sugarShortTitle);
    await snap(tester, 'blood_sugar');
    await tapText(tester, en.sugarAdd);
    await snap(tester, 'blood_sugar_form');
    await back(tester);
    await back(tester);

    // The + sheet and every form it opens.
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await snap(tester, 'add_sheet');
    for (final (label, name) in [
      (en.addReminder, 'form_reminder'),
      (en.addDoctor, 'form_doctor'),
      (en.addRecord, 'form_record'),
      (en.addExpense, 'form_expense'),
    ]) {
      await tapText(tester, label);
      await snap(tester, name);
      await back(tester);
      await tester.tap(find.byTooltip(en.add));
      await settle(tester);
    }
    await tapText(tester, en.addMedicine);
    await snap(tester, 'medicine_type');
    await tapText(tester, en.next);
    await snap(tester, 'form_medicine');
    await back(tester);
    await back(tester);

    // Settings and everything under it.
    await nav(tester, en.navHome);
    // Home is still scrolled down from the "home_lower" shot.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await settle(tester);
    await tester.tap(find.byTooltip(en.settingsTitle));
    await settle(tester);
    await snap(tester, 'settings');
    await tapText(tester, 'Rafi');
    await snap(tester, 'settings_name_sheet');
    await tester.tapAt(const Offset(20, 80)); // dismiss the sheet
    await settle(tester);
    await tapText(tester, en.settingsPermissions);
    await snap(tester, 'permissions');
    await back(tester);
    for (final (title, name) in [
      (en.privacyPolicy, 'privacy'),
      (en.termsOfUse, 'terms'),
      (en.medicalDisclaimer, 'disclaimer'),
    ]) {
      await tapText(tester, title);
      await snap(tester, name);
      await back(tester);
    }
    await back(tester);

    // A grouped alarm ringing (two medicines due at 9 pm).
    final repo = RemindersRepository(db);
    final at = DateTime(now.year, now.month, now.day, 21);
    for (final r in await repo.getAll()) {
      if (r.type == ReminderType.medicine && r.startAt.hour == 21) {
        await repo.setRinging(r.id, at);
      }
    }
    await settle(tester);
    await snap(tester, 'alarm_grouped');
    await tapText(tester, en.alarmMarkAllTaken);
    await snap(tester, 'home_after_taken');
  });

  testWidgets('onboarding renders', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpDosey(tester, db, granted: false);
    // Android can only screenshot the Flutter view as an image.
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await snap(tester, 'onboarding_welcome');
    await tapText(tester, en.onboardingContinue);
    await snap(tester, 'onboarding_name');
    await tapText(tester, en.skip);
    await snap(tester, 'onboarding_features');
    await tapText(tester, en.next);
    await snap(tester, 'onboarding_permissions');
  });
}
