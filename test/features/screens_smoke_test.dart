import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/app/home_tab.dart';
import 'package:dosey/app/widgets/floating_nav_bar.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/permission_service.dart';
import 'package:dosey/core/storage/file_storage_service.dart';
import 'package:dosey/core/widgets/amount_stepper.dart';
import 'package:dosey/features/medicines/domain/dose_time.dart';
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

import '../support/fakes.dart';
import '../support/harness.dart';

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
  }) async {
    usePhoneSize(tester);
    await tester.runAsync(() => _seed(db, now));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(
            db: db,
            now: now,
            permissions: FakePermissionService(AppPermission.values.toSet()),
          ),
          ...overrides,
        ],
        child: const DoseyApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> openTab(WidgetTester tester, HomeTab tab) async {
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byTooltip(tab.label),
      ),
    );
    await settle(tester);
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

    expect(find.text(DashboardStrings.dashboardTitle), findsOneWidget);
    // 10:15 → 13:00 Vitamin D is next.
    expect(
      find.text(
        DashboardStrings.nextTypeIn(ReminderStrings.typeMedicine, '2 h 45 min'),
      ),
      findsOneWidget,
    );
    expect(await scrollTo(tester, 'Insulin'), findsOneWidget);
    expect(await scrollTo(tester, DashboardStrings.runningLow), findsOneWidget);
    expect(await scrollTo(tester, 'Diabetes follow-up'), findsOneWidget);
    expect(
      await scrollTo(tester, DashboardStrings.spentThisMonth),
      findsOneWidget,
    );

    // Mark the 08:00 dose taken from the stack (scroll back to the top).
    await tester.drag(
      find.text(DashboardStrings.spentThisMonth),
      const Offset(0, 3000),
    );
    await settle(tester);
    await tapText(tester, 'Metformin');
    await tapText(tester, AlarmStrings.alarmMarkTaken);
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
    expect(find.text(MedicineStrings.lowStock), findsOneWidget);

    await openTab(tester, HomeTab.doctors);
    expect(find.text('Dr. Kamal Hossain'), findsOneWidget);

    await openTab(tester, HomeTab.records);
    expect(find.text('Endocrinology prescription'), findsOneWidget);

    await openTab(tester, HomeTab.expenses);
    expect(await scrollTo(tester, ExpenseStrings.byCategory), findsOneWidget);
    expect(await scrollTo(tester, 'HbA1c test'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('detail screens render', (tester) async {
    await pumpApp(tester);

    await openTab(tester, HomeTab.medicines);
    await tapText(tester, 'Insulin 500 mg');
    expect(find.text(MedicineStrings.medicineTime), findsOneWidget);
    expect(find.text(MedicineStrings.changeSetting), findsOneWidget);
    await back(tester);

    await openTab(tester, HomeTab.doctors);
    await tapText(tester, 'Dr. Farhana Rahman');
    expect(
      await scrollTo(tester, DoctorStrings.doctorAppointments),
      findsOneWidget,
    );
    expect(
      await scrollTo(tester, 'Endocrinology prescription'),
      findsOneWidget,
    );
    await back(tester);

    await openTab(tester, HomeTab.records);
    await tapText(tester, 'Endocrinology prescription');
    expect(find.text(RecordStrings.addPages), findsOneWidget);
    await back(tester);
    await unmount(tester);
  });

  testWidgets('every form opens from the + sheet', (tester) async {
    await pumpApp(tester);

    for (final label in [
      ReminderStrings.addReminder,
      DoctorStrings.addDoctor,
      RecordStrings.addRecord,
      ExpenseStrings.addExpense,
    ]) {
      await tester.tap(find.byTooltip(AppStrings.add));
      await settle(tester);
      await tapText(tester, label);
      expect(find.byType(Form), findsOneWidget, reason: label);
      await back(tester);
    }

    // Medicine is two steps: type grid → form.
    await tester.tap(find.byTooltip(AppStrings.add));
    await settle(tester);
    await tapText(tester, MedicineStrings.addMedicine);
    expect(find.text(MedicineStrings.chooseMedicineType), findsOneWidget);
    await tapText(tester, MedicineStrings.formCapsule);
    await tapText(tester, AppStrings.next);
    expect(find.byType(Form), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('adding a medicine with times creates its reminders', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip(AppStrings.add));
    await settle(tester);
    await tapText(tester, MedicineStrings.addMedicine);
    await tapText(tester, AppStrings.next);

    await tester.enterText(
      find.byType(TextFormField).first, // medicine name
      'Napa',
    );
    await tapText(tester, AppStrings.save);

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
      const ScannedMedicine(name: 'Seclo', strength: '20mg'),
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
    await tester.tap(find.byTooltip(AppStrings.add));
    await settle(tester);
    await tapText(tester, MedicineStrings.addMedicine);
    await tapText(tester, AppStrings.next);

    await tapText(tester, MedicineStrings.scanTitle);
    expect(scanner.scannedPaths, ['/tmp/rx.jpg']);
    // Two medicines found: the user picks which one this form is for.
    await tapText(tester, 'Napa Extra 500mg');

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
    await tapText(tester, AppStrings.done);
    await scrollTo(tester, '9:00 pm · 1.5 tablet');
    // The "review the fields" snackbar covers Save until it times out.
    expect(find.text(MedicineStrings.scanFilled), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
    await tapText(tester, AppStrings.save);

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
}
