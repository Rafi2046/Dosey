// Screenshots for the user guide PDF, in English and the light look, with
// the demo data a reviewer sees. Saves build/screens/guide_*.png.
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/user_guide_screens_test.dart -d <device>

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/app/debug/demo_data_seeder.dart';
import 'package:dosey/app/widgets/app_nav_bar.dart';
import 'package:dosey/core/storage/file_storage_service.dart';
import 'package:dosey/features/doctors/domain/specialty.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/features/medicines/domain/dose_time.dart';
import 'package:dosey/features/medicines/domain/scanned_doctor.dart';
import 'package:dosey/features/medicines/domain/scanned_medicine.dart';
import 'package:dosey/features/medicines/providers/medicines_providers.dart';
import 'package:dosey/features/profiles/data/profiles_repository.dart';
import 'package:dosey/features/records/data/records_repository.dart';
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

final l = lookupAppLocalizations(AppLocale.english);

Future<void> _seed(AppDatabase db, DateTime now) async {
  final reminders = RemindersRepository(db);
  await DemoDataSeeder.seed(
    db,
    reminders,
    RecordsRepository(db, FileStorageService(Directory.systemTemp)),
  );
  final today = DateTime(now.year, now.month, now.day);
  // A week of dose history: mostly taken, a couple missed or skipped.
  for (final r in await reminders.getAll()) {
    if (r.type != ReminderType.medicine) continue;
    for (var d = 1; d <= 7; d++) {
      final at = today
          .subtract(Duration(days: d))
          .add(Duration(hours: r.startAt.hour, minutes: r.startAt.minute));
      final status = (d == 3 && r.startAt.hour == 13)
          ? ReminderLogStatus.missed
          : (d == 5 && r.startAt.hour == 22)
          ? ReminderLogStatus.skipped
          : ReminderLogStatus.taken;
      await reminders.logAction(
        reminderId: r.id,
        scheduledFor: at,
        status: status,
        actedAt: at.add(const Duration(minutes: 4)),
      );
    }
  }
  for (final (sys, dia, pulse, daysAgo) in [
    (128, 84, 72, 0),
    (135, 88, 75, 2),
    (122, 79, 70, 4),
    (126, 82, 71, 6),
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
    (7.6, SugarContext.afterMeal, 5),
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
  await ProfilesRepository(db).create('Ammu', colorIndex: 1);
  await db
      .into(db.appSettings)
      .insert(AppSettingsCompanion.insert(key: 'user_name', value: 'Rafi'));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final failed = <String>[];

  Future<void> snap(WidgetTester tester, String name) async {
    await settle(tester);
    await binding.takeScreenshot('guide_$name');
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final pages = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    for (var i = 0; i < 20; i++) {
      final f = find.text(text).hitTestable();
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first);
        await settle(tester);
        return;
      }
      if (pages.evaluate().isEmpty) break;
      await tester.drag(pages.last, const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('"$text" not found');
  }

  Future<void> back(WidgetTester tester) async {
    if (find.byTooltip('Back').hitTestable().evaluate().isNotEmpty) {
      await tester.pageBack();
    } else {
      await tester.binding.handlePopRoute();
    }
    await settle(tester);
  }

  Future<void> nav(WidgetTester tester, String tooltip) async {
    final target = find.descendant(
      of: find.byType(AppNavBar),
      matching: find.byTooltip(tooltip),
    );
    for (var i = 0; i < 30 && target.hitTestable().evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(target);
    await settle(tester);
  }

  /// Runs one part of the walk; a failure is noted and the walk goes on
  /// from Home.
  Future<void> part(
    WidgetTester tester,
    String name,
    Future<void> Function() body,
  ) async {
    try {
      await body();
    } on Object catch (e) {
      failed.add('$name: $e');
      for (var i = 0; i < 4; i++) {
        await tester.binding.handlePopRoute();
        await settle(tester);
      }
    }
  }

  Future<void> pumpDosey(
    WidgetTester tester,
    AppDatabase db, {
    bool granted = true,
  }) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            () => ThemeModeController(ThemeMode.light),
          ),
          languageProvider.overrideWith(() => LanguageController('en')),
          prescriptionImagePickerProvider.overrideWithValue(
            (_) async => '/tmp/rx.jpg',
          ),
          prescriptionScannerProvider.overrideWithValue(
            FakePrescriptionScanner(
              const [
                ScannedMedicine(
                  name: 'Napa Extra',
                  strength: '500mg',
                  form: MedicineForm.tablet,
                  doses: [
                    DoseTime(TimeOfDay(hour: 8, minute: 0)),
                    DoseTime(TimeOfDay(hour: 21, minute: 0)),
                  ],
                  meal: MealRelation.afterMeal,
                  durationDays: 7,
                  dosePattern: '1+0+1',
                ),
                ScannedMedicine(
                  name: 'Seclo',
                  strength: '20mg',
                  doses: [DoseTime(TimeOfDay(hour: 7, minute: 30))],
                  meal: MealRelation.beforeMeal,
                  durationDays: 14,
                  dosePattern: '1+0+0',
                ),
              ],
              doctor: const ScannedDoctor(
                name: 'Dr. Kamal Hossain',
                specialty: Specialty.cardiology,
              ),
            ),
          ),
          ...testOverrides(
            db: db,
            now: now,
            permissions: FakePermissionService(
              granted ? AppPermission.values.toSet() : {},
            ),
          ),
        ],
        child: const DoseyApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('onboarding', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpDosey(tester, db, granted: false);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await snap(tester, '00_onboarding_welcome');
    await tapText(tester, l.onboardingContinue);
    await snap(tester, '01_onboarding_name');
    await tapText(tester, l.skip);
    await snap(tester, '02_onboarding_features');
    await tapText(tester, l.next);
    await snap(tester, '03_onboarding_permissions');
  });

  testWidgets('every screen for the guide', (tester) async {
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

    await part(tester, 'home', () async {
      await snap(tester, '10_home');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await snap(tester, '11_home_lower');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await settle(tester);
    });

    await part(tester, 'dose sheet', () async {
      await tapText(tester, 'Vitamin D');
      await snap(tester, '12_dose_sheet');
      await tester.tapAt(const Offset(20, 80));
      await settle(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await settle(tester);
    });

    await part(tester, 'profile switcher', () async {
      await tapText(tester, 'Rafi');
      await snap(tester, '13_profile_switcher');
      await tester.tapAt(const Offset(20, 80));
      await settle(tester);
    });

    await part(tester, 'reminders', () async {
      await nav(tester, l.navReminders);
      await snap(tester, '20_reminders');
      await tapText(tester, 'Diabetes follow-up');
      await snap(tester, '21_reminder_form');
      await back(tester);
    });

    await part(tester, 'medicines', () async {
      await nav(tester, l.navMedicines);
      await snap(tester, '30_medicines');
      await tapText(tester, 'Metformin 500 mg');
      await snap(tester, '31_medicine_detail');
      await back(tester);
    });

    await part(tester, 'add sheet', () async {
      await tester.tap(find.byTooltip(l.add));
      await settle(tester);
      await snap(tester, '40_add_sheet');
      await tapText(tester, l.addMedicine);
      await snap(tester, '41_medicine_type');
      await tapText(tester, l.next);
      await snap(tester, '42_form_medicine');
      await back(tester);
      await back(tester);
    });

    await part(tester, 'scan', () async {
      await tester.tap(find.byTooltip(l.add));
      await settle(tester);
      await tapText(tester, l.scanTitle);
      await settle(tester, frames: 20);
      await snap(tester, '43_scan_result');
      await back(tester);
    });

    await part(tester, 'other forms', () async {
      for (final (label, name) in [
        (l.addReminder, '44_form_reminder'),
        (l.addDoctor, '45_form_doctor'),
        (l.addRecord, '46_form_record'),
        (l.addExpense, '47_form_expense'),
      ]) {
        await tester.tap(find.byTooltip(l.add));
        await settle(tester);
        await tapText(tester, label);
        await snap(tester, name);
        await back(tester);
      }
    });

    await part(tester, 'more', () async {
      await nav(tester, l.navMore);
      await snap(tester, '50_more_sheet');
      await tapText(tester, l.navDoctors);
      await snap(tester, '51_doctors');
      await tapText(tester, 'Dr. Farhana Rahman');
      await snap(tester, '52_doctor_detail');
      await back(tester);
    });

    await part(tester, 'records', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.navRecords);
      await snap(tester, '53_records');
      await tapText(tester, 'Endocrinology prescription');
      await snap(tester, '54_record_detail');
      await back(tester);
    });

    await part(tester, 'expenses', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.navExpenses);
      await snap(tester, '55_expenses');
    });

    await part(tester, 'history', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.historyLink);
      await snap(tester, '56_dose_history');
      await back(tester);
    });

    await part(tester, 'report', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.reportShowDoctor);
      await snap(tester, '57_report');
      await back(tester);
    });

    await part(tester, 'blood pressure', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.bpShortTitle);
      await snap(tester, '58_blood_pressure');
      await tapText(tester, l.bpAdd);
      await snap(tester, '59_blood_pressure_form');
      await back(tester);
      await back(tester);
    });

    await part(tester, 'blood sugar', () async {
      await nav(tester, l.navMore);
      await tapText(tester, l.sugarShortTitle);
      await snap(tester, '60_blood_sugar');
      await tapText(tester, l.sugarAdd);
      await snap(tester, '61_blood_sugar_form');
      await back(tester);
      await back(tester);
    });

    await part(tester, 'settings', () async {
      await nav(tester, l.navHome);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await settle(tester);
      await tester.tap(find.byTooltip(l.settingsTitle));
      await settle(tester);
      await snap(tester, '70_settings');
      await tapText(tester, l.profilesTitle);
      await snap(tester, '72_profiles');
      await back(tester);
      await tapText(tester, l.fsTitle);
      await settle(tester, frames: 20);
      await snap(tester, '73_family_sharing');
      await tester.tapAt(const Offset(20, 80));
      await settle(tester);
      await tester.drag(
        find.byType(Scrollable).last,
        const Offset(0, -700),
      );
      await snap(tester, '71_settings_lower');
      await tapText(tester, l.settingsPermissions);
      await snap(tester, '74_permissions');
      await back(tester);
      await back(tester);
    });

    await part(tester, 'alarm', () async {
      final repo = RemindersRepository(db);
      final at = DateTime(now.year, now.month, now.day, 21);
      for (final r in await repo.getAll()) {
        if (r.type == ReminderType.medicine && r.startAt.hour == 21) {
          await repo.setRinging(r.id, at);
        }
      }
      await settle(tester);
      await snap(tester, '80_alarm');
    });

    // ignore: avoid_print
    print('GUIDE PARTS FAILED: $failed');
  });
}
