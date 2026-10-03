import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/app/home_tab.dart';
import 'package:dosey/app/widgets/app_nav_bar.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/core/storage/file_storage_service.dart';
import 'package:dosey/core/widgets/amount_stepper.dart';
import 'package:dosey/core/widgets/app_text_field.dart';
import 'package:dosey/core/widgets/async_value_view.dart';
import 'package:dosey/features/medicines/domain/dose_time.dart';
import 'package:dosey/features/medicines/presentation/bulk/medicine_draft_card.dart';
import 'package:dosey/features/medicines/domain/scanned_medicine.dart';
import 'package:dosey/features/medicines/providers/medicines_providers.dart';
import 'package:dosey/features/records/data/records_repository.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import '../support/fakes.dart';
import '../support/harness.dart';
import 'package:dosey/core/localization/l10n.dart';

/// Tests run in English (the default for an en_US test device).
final en = lookupAppLocalizations(AppLocale.english);

/// 1×1 transparent PNG, so record thumbnails have a real file to load.
const _png = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

Future<void> _seed(AppDatabase db, DateTime now) async {
  final reminders = RemindersRepository(db);
  final doctors = <int>[];
  for (final (name, specialty) in [
    ('Dr. Farhana Rahman', 'Endocrinologist'),
    ('Dr. Kamal Hossain', 'Cardiologist'),
    ('Dr. Nusrat Jahan', 'General Physician'),
  ]) {
    doctors.add(
      await db
          .into(db.doctors)
          .insert(
            DoctorsCompanion.insert(
              name: name,
              specialty: Value(specialty),
              phone: const Value('+880 1711 000000'),
              clinic: const Value('Square Hospital, Dhaka'),
              consultationFeeMinor: const Value(100000),
            ),
          ),
    );
  }

  Future<int> medicine(
    String name,
    MedicineForm form,
    int price, {
    double? stock,
    double? refillAt,
    int doctor = 0,
  }) => db
      .into(db.medicines)
      .insert(
        MedicinesCompanion.insert(
          name: name,
          strength: const Value('500 mg'),
          form: Value(form),
          startDate: DateTime(2026, 9, 1),
          endDate: Value(DateTime(2026, 10, 30)),
          unitPriceMinor: Value(price),
          stockQuantity: Value(stock),
          refillThreshold: Value(refillAt),
          doctorId: Value(doctors[doctor]),
          notes: const Value('Take the insulin 30 minutes before your meal.'),
        ),
      );

  final metformin = await medicine(
    'Metformin',
    MedicineForm.tablet,
    800,
    stock: 3,
    refillAt: 5,
  );
  final vitD = await medicine(
    'Vitamin D',
    MedicineForm.capsule,
    1500,
    doctor: 1,
  );
  final insulin = await medicine(
    'Insulin',
    MedicineForm.injection,
    45000,
    doctor: 2,
  );

  for (final (med, title, hour) in [
    (metformin, 'Metformin', 8),
    (vitD, 'Vitamin D', 13),
    (insulin, 'Insulin', 20),
    (metformin, 'Metformin', 22),
  ]) {
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: title,
        startAt: DateTime(2026, 9, 1, hour),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
      ),
      now: now,
    );
  }
  await reminders.create(
    RemindersCompanion.insert(
      type: ReminderType.appointment,
      title: 'Diabetes follow-up',
      startAt: DateTime(2026, 10, 9, 17, 30),
      doctorId: Value(doctors.first),
      location: const Value('Square Hospital'),
    ),
    now: now,
  );
  await reminders.create(
    RemindersCompanion.insert(
      type: ReminderType.medicalTest,
      title: 'HbA1c blood test',
      startAt: DateTime(2026, 10, 5, 8),
      repeatRule: const Value(RepeatRule.weekly),
      weekdaysMask: const Value(1 | 16),
    ),
    now: now,
  );

  final src = File('${Directory.systemTemp.path}/dosey_smoke.png')
    ..writeAsBytesSync(_png);
  await RecordsRepository(db, FileStorageService(Directory.systemTemp)).create(
    RecordsCompanion.insert(
      type: RecordType.prescription,
      title: 'Endocrinology prescription',
      recordDate: DateTime(2026, 9, 28),
      doctorId: Value(doctors.first),
    ),
    [src.path, src.path],
  );

  for (final (title, cat, amount) in [
    ('Metformin strip', ExpenseCategory.medicine, 24000),
    ('Consultation', ExpenseCategory.consultation, 100000),
    ('HbA1c test', ExpenseCategory.test, 150000),
  ]) {
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            category: cat,
            title: title,
            amountMinor: amount,
            spentOn: DateTime(2026, 10, 2),
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 3, 10, 15);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpApp(
    WidgetTester tester, {
    List<Override> overrides = const [],
    FakeAlarmScheduler? scheduler,
  }) async {
    usePhoneSize(tester);
    await tester.runAsync(() => _seed(db, now));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(
            db: db,
            now: now,
            scheduler: scheduler,
            permissions: FakePermissionService(AppPermission.values.toSet()),
          ),
          ...overrides,
        ],
        child: const DoseyApp(),
      ),
    );
    await settle(tester);
  }

  /// Home, Reminders and Medicines are in the bar; the rest under More.
  Future<void> openTab(WidgetTester tester, HomeTab tab) async {
    final inBar = AppNavBar.primary.contains(tab);
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(inBar ? tab.label(en) : en.navMore),
      ),
    );
    await settle(tester);
    if (!inBar) {
      await tester.tap(find.text(tab.label(en)).last);
      await settle(tester);
    }
  }

  /// ListViews build lazily: drag the visible page until [text] is built
  /// and on screen.
  Future<Finder> scrollTo(WidgetTester tester, String text) async {
    final page = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;
    for (var i = 0; i < 30; i++) {
      final found = find.text(text).hitTestable();
      if (found.evaluate().isNotEmpty) return found.first;
      await tester.drag(page, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 50));
    }
    fail('"$text" not found after scrolling');
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = await scrollTo(tester, text);
    await tester.tap(finder);
    await settle(tester);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.pageBack();
    await settle(tester);
  }

  testWidgets('dashboard shows stacked doses, next-up and costs', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text(en.dashboardTitle), findsOneWidget);
    // 10:15 → 13:00 Vitamin D is next.
    expect(
      find.text(en.nextTypeIn(en.typeMedicine, '2 h 45 min')),
      findsOneWidget,
    );
    expect(await scrollTo(tester, 'Insulin'), findsOneWidget);
    expect(await scrollTo(tester, en.runningLow), findsOneWidget);
    expect(await scrollTo(tester, 'Diabetes follow-up'), findsOneWidget);
    expect(await scrollTo(tester, en.spentThisMonth), findsOneWidget);

    // Mark the 08:00 dose taken from the stack (scroll back to the top).
    await tester.drag(find.text(en.spentThisMonth), const Offset(0, 3000));
    await settle(tester);
    await tapText(tester, 'Metformin');
    await tapText(tester, en.alarmMarkTaken);
    final log = await dbRun(tester, () => db.select(db.reminderLogs).get());
    expect(log.single.status, ReminderLogStatus.taken);
    await unmount(tester);
  });

  testWidgets('every tab renders with data', (tester) async {
    await pumpApp(tester);

    await openTab(tester, HomeTab.reminders);
    expect(await scrollTo(tester, 'HbA1c blood test'), findsOneWidget);

    await openTab(tester, HomeTab.medicines);
    expect(find.text('Metformin 500 mg'), findsOneWidget);
    expect(find.text(en.lowStock), findsOneWidget);

    await openTab(tester, HomeTab.doctors);
    expect(find.text('Dr. Kamal Hossain'), findsOneWidget);

    await openTab(tester, HomeTab.records);
    expect(find.text('Endocrinology prescription'), findsOneWidget);

    await openTab(tester, HomeTab.expenses);
    expect(await scrollTo(tester, en.byCategory), findsOneWidget);
    expect(await scrollTo(tester, 'HbA1c test'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('detail screens render', (tester) async {
    await pumpApp(tester);

    await openTab(tester, HomeTab.medicines);
    await tapText(tester, 'Insulin 500 mg');
    expect(find.text(en.medicineTime), findsOneWidget);
    expect(find.text(en.changeSetting), findsOneWidget);
    await back(tester);

    await openTab(tester, HomeTab.doctors);
    await tapText(tester, 'Dr. Farhana Rahman');
    expect(await scrollTo(tester, en.doctorAppointments), findsOneWidget);
    expect(
      await scrollTo(tester, 'Endocrinology prescription'),
      findsOneWidget,
    );
    await back(tester);

    await openTab(tester, HomeTab.records);
    await tapText(tester, 'Endocrinology prescription');
    expect(find.text(en.addPages), findsOneWidget);
    await back(tester);
    await unmount(tester);
  });

  testWidgets('every form opens from the + sheet', (tester) async {
    await pumpApp(tester);

    for (final label in [
      en.addReminder,
      en.addDoctor,
      en.addRecord,
      en.addExpense,
    ]) {
      await tester.tap(find.byTooltip(en.add));
      await settle(tester);
      await tapText(tester, label);
      expect(find.byType(Form), findsOneWidget, reason: label);
      await back(tester);
    }

    // Medicine is two steps: type grid → form.
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    expect(find.text(en.chooseMedicineType), findsOneWidget);
    await tapText(tester, en.formCapsule);
    await tapText(tester, en.next);
    expect(find.byType(Form), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('adding a medicine with times creates its reminders', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    await tapText(tester, en.next);

    await tester.enterText(
      find.byType(TextFormField).first, // medicine name
      'Napa',
    );
    await tapText(tester, en.save);

    final meds = await dbRun(
      tester,
      () =>
          (db.select(db.medicines)..where((m) => m.name.equals('Napa'))).get(),
    );
    expect(meds, hasLength(1));
    await unmount(tester);
  });

  testWidgets('scanning a prescription pre-fills an editable form', (
    tester,
  ) async {
    final scanner = FakePrescriptionScanner([
      const ScannedMedicine(
        name: 'Napa Extra',
        strength: '500mg',
        form: MedicineForm.tablet,
        doses: [
          DoseTime(TimeOfDay(hour: 8, minute: 0), 2),
          DoseTime(TimeOfDay(hour: 21, minute: 0)),
        ],
        meal: MealRelation.afterMeal,
        durationDays: 7,
        dosePattern: '1+0+1',
      ),
    ]);
    await pumpApp(
      tester,
      overrides: [
        prescriptionScannerProvider.overrideWithValue(scanner),
        prescriptionImagePickerProvider.overrideWithValue(
          (_) async => '/tmp/rx.jpg',
        ),
      ],
    );
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    await tapText(tester, en.next);

    await tapText(tester, en.scanTitle);
    expect(scanner.scannedPaths, ['/tmp/rx.jpg']);
    // One medicine found: it fills this form directly.

    expect(find.widgetWithText(TextFormField, 'Napa Extra'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '500mg'), findsOneWidget);
    // Everything stays editable before saving.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Napa Extra'),
      'Napa',
    );

    // Below the fold: scrollTo fails the test if a chip is missing.
    await scrollTo(tester, '8:00 am · 2 tablet');
    // Change one time's amount: 9 pm goes from 1 to 1½ tablets.
    await tapText(tester, '9:00 pm · 1 tablet');
    await tester.tap(
      find.descendant(
        of: find.byType(AmountStepper),
        matching: find.byIcon(Icons.add_rounded),
      ),
    );
    await settle(tester);
    expect(find.text('1½ tablet'), findsOneWidget);
    await tapText(tester, en.done);
    await scrollTo(tester, '9:00 pm · 1.5 tablet');
    // The "review the fields" snackbar covers Save until it times out.
    expect(find.text(en.scanFilled), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
    await tapText(tester, en.save);

    final med = await dbRun(
      tester,
      () => (db.select(
        db.medicines,
      )..where((m) => m.name.equals('Napa'))).getSingle(),
    );
    expect(med.strength, '500mg');
    expect(med.mealRelation, MealRelation.afterMeal);
    // "x 7 days" → the 7th day, counting the start day.
    expect(
      med.endDate,
      DateUtils.dateOnly(med.startDate).add(const Duration(days: 6)),
    );
    final reminders = await dbRun(
      tester,
      () => (db.select(
        db.reminders,
      )..where((r) => r.medicineId.equals(med.id))).get(),
    );
    expect(
      {for (final r in reminders) r.startAt.hour: r.doseAmount},
      {8: 2.0, 21: 1.5},
    );
    await unmount(tester);
  });

  testWidgets('a multi-medicine scan is reviewed and saved in bulk', (
    tester,
  ) async {
    final scanner = FakePrescriptionScanner([
      const ScannedMedicine(
        name: 'Napa Extra',
        strength: '500mg',
        doses: [
          DoseTime(TimeOfDay(hour: 8, minute: 0), 2),
          DoseTime(TimeOfDay(hour: 21, minute: 0)),
        ],
        dosePattern: '2+0+1',
      ),
      const ScannedMedicine(name: 'Seclo', strength: '20mg'),
      const ScannedMedicine(
        name: 'Ambrox',
        form: MedicineForm.syrup,
        doses: [DoseTime(TimeOfDay(hour: 14, minute: 0), 10)],
      ),
    ]);
    await pumpApp(
      tester,
      overrides: [
        prescriptionScannerProvider.overrideWithValue(scanner),
        prescriptionImagePickerProvider.overrideWithValue(
          (_) async => '/tmp/rx.jpg',
        ),
      ],
    );
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    await tapText(tester, en.next);
    await tapText(tester, en.scanTitle);

    // Review screen lists all three, with the prescription's own pattern.
    expect(find.text(en.bulkTitle), findsOneWidget);
    expect(find.text(en.bulkAsWritten('2+0+1')), findsOneWidget);
    expect(find.text(en.bulkSaveAll(3)), findsOneWidget);

    // Seclo was misread: remove its card.
    final seclo = await scrollTo(tester, 'Seclo');
    await tester.tap(
      find.descendant(
        of: find.ancestor(of: seclo, matching: find.byType(MedicineDraftCard)),
        matching: find.byTooltip(en.bulkRemove),
      ),
    );
    await settle(tester);
    expect(find.byType(MedicineDraftCard), findsNWidgets(2));
    expect(find.text(en.bulkSaveAll(2)), findsOneWidget);

    // A medicine the scan missed: add it by hand.
    await tapText(tester, en.bulkAddAnother);
    final newCard = find.byType(MedicineDraftCard).last;
    final newName = find
        .descendant(of: newCard, matching: find.byType(TextFormField))
        .first;
    // Saving with the new card still blank is refused.
    await tester.tap(find.text(en.bulkSaveAll(3)));
    await settle(tester);
    expect(find.text(en.bulkFixMedicine(3)), findsOneWidget);
    await tester.enterText(newName, 'Omidon');
    await settle(tester);
    expect(find.text(en.bulkSaveAll(3)), findsOneWidget);

    await tester.pump(const Duration(seconds: 5)); // snackbar times out
    await settle(tester);
    await tester.tap(find.text(en.bulkSaveAll(3)));
    await settle(tester);

    final meds = await dbRun(tester, () => db.select(db.medicines).get());
    final byName = {for (final m in meds) m.name: m};
    expect(byName.keys, containsAll(['Napa Extra', 'Ambrox', 'Omidon']));
    expect(byName.keys, isNot(contains('Seclo')));
    expect(byName['Ambrox']!.doseUnit, 'ml');

    final reminders = await dbRun(tester, () => db.select(db.reminders).get());
    Map<int, double?> dosesOf(String name) => {
      for (final r in reminders)
        if (r.medicineId == byName[name]!.id) r.startAt.hour: r.doseAmount,
    };
    expect(dosesOf('Napa Extra'), {8: 2.0, 21: 1.0});
    expect(dosesOf('Ambrox'), {14: 10.0});
    expect(dosesOf('Omidon'), isEmpty);

    // Saving closes both the review screen and the Add Medicine form.
    expect(find.text(en.bulkTitle), findsNothing);
    expect(find.text(en.addMedicine), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'switching to Bengali in Settings re-labels the app and is saved',
    (tester) async {
      addTearDown(() => AppLocale.apply(AppLocale.english));
      final bn = lookupAppLocalizations(AppLocale.bangla);
      Future<String?> saved() => dbRun(
        tester,
        () async =>
            (await (db.select(db.appSettings)
                      ..where((s) => s.key.equals(AppLocale.settingKey)))
                    .getSingleOrNull())
                ?.value,
      );

      await pumpApp(tester);
      expect(find.text(en.dashboardTitle), findsOneWidget);

      await tester.tap(find.byTooltip(en.settingsTitle));
      await settle(tester);
      await tester.tap(find.text(en.languageBangla));
      await settle(tester);
      // The settings screen itself switches immediately…
      expect(find.text(bn.settingsTitle), findsOneWidget);
      expect(await saved(), 'bn');

      // …and so does everything behind it. (pageBack looks for an
      // English "Back" tooltip, so pop directly.)
      Navigator.of(tester.element(find.text(bn.settingsTitle))).pop();
      await settle(tester);
      expect(find.text(bn.dashboardTitle), findsOneWidget);
      expect(find.byTooltip(HomeTab.reminders.label(bn)), findsWidgets);

      // "Phone default" forgets the choice; the test device is English.
      await tester.tap(find.byTooltip(bn.settingsTitle));
      await settle(tester);
      await tester.tap(find.text(bn.languageSystem));
      await settle(tester);
      expect(find.text(en.settingsTitle), findsOneWidget);
      expect(await saved(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('dark mode switches the whole app in place and is saved', (
    tester,
  ) async {
    addTearDown(() => AppColors.apply(AppPalette.light));
    await pumpApp(tester);
    await tester.tap(find.byTooltip(en.settingsTitle));
    await settle(tester);

    await tapText(tester, en.themeDark);
    expect(AppColors.isDark, isTrue);
    // Still on Settings (no restart), now on the dark background.
    expect(find.text(en.settingsTitle), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, AppPalette.dark.cream);
    final saved = await dbRun(
      tester,
      () => (db.select(
        db.appSettings,
      )..where((s) => s.key.equals('theme'))).getSingle(),
    );
    expect(saved.value, 'dark');

    await tapText(tester, en.themeSystem);
    expect(AppColors.isDark, isFalse);
    await unmount(tester);
  });

  testWidgets('settings opens the legal pages and permissions', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip(en.settingsTitle));
    await settle(tester);
    expect(find.text(en.permissionsAllAllowed), findsOneWidget);

    for (final (title, firstHeading) in [
      (en.privacyPolicy, en.privacyShortTitle),
      (en.termsOfUse, en.termsUseTitle),
      (en.medicalDisclaimer, en.disclaimerAdviceTitle),
    ]) {
      await tapText(tester, title);
      expect(find.text(firstHeading), findsOneWidget);
      await back(tester);
    }

    await tapText(tester, en.settingsPermissions);
    expect(find.text(en.allSet), findsOneWidget);
    await back(tester);
    await unmount(tester);
  });

  testWidgets('delete all data wipes everything after two confirmations', (
    tester,
  ) async {
    final scheduler = FakeAlarmScheduler();
    await pumpApp(tester, scheduler: scheduler);
    Future<int> count(TableInfo table) =>
        dbRun(tester, () => db.select(table).get().then((rows) => rows.length));
    expect(await count(db.medicines), greaterThan(0));
    expect(scheduler.alarms, isNotEmpty);
    final photos = Directory(
      '${Directory.systemTemp.path}/${AppConstants.recordsFolder}',
    );
    expect(photos.existsSync(), isTrue);

    await tester.tap(find.byTooltip(en.settingsTitle));
    await settle(tester);

    // Backing out at the first step deletes nothing.
    await tapText(tester, en.deleteAllData);
    await tester.tap(find.text(en.cancel));
    await settle(tester);
    expect(await count(db.medicines), greaterThan(0));

    await tapText(tester, en.deleteAllData);
    expect(find.text(en.deleteAllTitle), findsOneWidget);
    await tester.tap(find.text(en.continueLabel));
    await settle(tester);
    expect(find.text(en.deleteAllConfirmTitle), findsOneWidget);
    await tester.tap(find.text(en.deleteEverything));
    // The wipe mixes DB work (advances with pumped frames) and real file
    // deletion (needs real time), so alternate both until it finishes.
    for (
      var i = 0;
      i < 20 && find.text(en.allDataDeleted).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await settle(tester, frames: 2);
    }
    await settle(tester);

    // Back on Home, told what happened.
    expect(find.text(en.dashboardTitle), findsOneWidget);
    expect(find.text(en.allDataDeleted), findsOneWidget);
    for (final table in <TableInfo>[
      db.medicines,
      db.reminders,
      db.reminderLogs,
      db.doctors,
      db.records,
      db.recordAttachments,
      db.expenses,
    ]) {
      expect(await count(table), 0, reason: table.actualTableName);
    }
    expect(scheduler.alarms, isEmpty);
    expect(photos.existsSync(), isFalse);
    await unmount(tester);
  });

  testWidgets('quick times: 2 tablets morning, lunch and dinner', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    await tapText(tester, en.next);
    await tester.enterText(find.byType(TextFormField).first, 'Zulfidin');

    // Morning, then make it 2 tablets…
    await tapText(tester, en.slotMorning);
    await tapText(tester, '8:00 am · 1 tablet');
    // Half steps: 1 → 1½ → 2.
    for (var i = 0; i < 2; i++) {
      await tester.tap(
        find.descendant(
          of: find.byType(AmountStepper),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await settle(tester);
    }
    await tapText(tester, en.done);
    // …and Lunch / Dinner pick up the same amount.
    await tapText(tester, en.slotLunch);
    await tapText(tester, en.slotDinner);
    await scrollTo(tester, '2:00 pm · 2 tablet');
    await scrollTo(tester, '9:00 pm · 2 tablet');

    // A quiet notification instead of a full alarm.
    await tapText(tester, en.ringAsAlarm);
    await tapText(tester, en.save);

    final med = await dbRun(
      tester,
      () => (db.select(
        db.medicines,
      )..where((m) => m.name.equals('Zulfidin'))).getSingle(),
    );
    final reminders = await dbRun(
      tester,
      () => (db.select(
        db.reminders,
      )..where((r) => r.medicineId.equals(med.id))).get(),
    );
    expect(
      {for (final r in reminders) r.startAt.hour: r.doseAmount},
      {8: 2.0, 14: 2.0, 21: 2.0},
    );
    expect(reminders.every((r) => !r.isCritical), isTrue);
    await unmount(tester);
  });

  testWidgets('loading shows a shimmer skeleton, not a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AsyncValueView<int>(
            value: const AsyncLoading(),
            data: (n) => Text('$n'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('stock calculator: boxes and strips become tablets', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip(en.add));
    await settle(tester);
    await tapText(tester, en.addMedicine);
    await tapText(tester, en.next);
    await tester.enterText(find.byType(TextFormField).first, 'Zulfidin');
    await tapText(tester, en.slotMorning);

    Future<void> fill(String label, String text) async {
      await scrollTo(tester, label);
      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == label,
          ),
          matching: find.byType(TextFormField),
        ),
        text,
      );
      await settle(tester);
    }

    await fill(en.unitsPerStrip('tablet'), '10');
    await fill(en.stripsPerBox, '10');
    await tapText(tester, en.addOneBox);
    await tapText(tester, en.addOneBox);
    expect(find.widgetWithText(TextFormField, '200'), findsOneWidget);
    // 1 tablet a day, alert 3 days before → about 3 tablets.
    await scrollTo(tester, en.refillAlertDays(3));
    expect(find.text(en.refillAlertUnits('3', 'tablet')), findsOneWidget);

    await tapText(tester, en.save);
    final med = await dbRun(
      tester,
      () => (db.select(
        db.medicines,
      )..where((m) => m.name.equals('Zulfidin'))).getSingle(),
    );
    expect(med.stockQuantity, 200);
    expect(med.unitsPerStrip, 10);
    expect(med.stripsPerBox, 10);
    expect(med.refillAlertDays, 3);
    expect(med.refillThreshold, isNull);
    await unmount(tester);
  });
}
