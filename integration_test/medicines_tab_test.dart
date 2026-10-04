// Screenshots the Medicines tab's cards (course day, stock, cost, warnings)
// in Bengali (build/screens/*.png via test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/medicines_tab_test.dart -d <device>
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('medicines tab (bn)', (tester) async {
    final l = lookupAppLocalizations(AppLocale.bangla);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repo = RemindersRepository(db);

    final kamal = await db
        .into(db.doctors)
        .insert(DoctorsCompanion.insert(name: 'Dr. Kamal Hossain'));
    final farhana = await db
        .into(db.doctors)
        .insert(DoctorsCompanion.insert(name: 'Dr. Farhana Rahman'));

    for (final (name, form, unit, doctor, startDaysAgo, days, stock, price) in [
      (
        'Atorvastatin',
        MedicineForm.tablet,
        'tablet',
        kamal,
        20,
        36,
        20.0,
        1200,
      ),
      ('Insulin', MedicineForm.injection, 'unit', farhana, 20, 36, null, 45000),
      ('Metformin', MedicineForm.tablet, 'tablet', farhana, 60, null, 2.0, 300),
      ('Vitamin D', MedicineForm.capsule, 'capsule', null, 10, null, null, 0),
    ]) {
      final start = today.subtract(Duration(days: startDaysAgo));
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: name,
              strength: const Value('10 mg'),
              form: Value(form),
              doseUnit: Value(unit),
              doctorId: Value(doctor),
              startDate: start,
              endDate: Value(
                days == null ? null : start.add(Duration(days: days - 1)),
              ),
              stockQuantity: Value(stock),
              unitPriceMinor: Value(price),
              refillAlertDays: Value(stock == null ? null : 3),
              mealRelation: const Value(MealRelation.afterMeal),
            ),
          );
      await repo.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: name,
          startAt: start.add(const Duration(hours: 9)),
          medicineId: Value(med),
          repeatRule: const Value(RepeatRule.daily),
          doseAmount: const Value(1),
        ),
        now: now,
      );
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

    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byTooltip(l.navMedicines),
      ),
    );
    await settle(tester);
    expect(find.text(l.courseDayOf(21, 36)), findsNWidgets(2));
    expect(find.text(l.lowStock), findsOneWidget);
    await binding.takeScreenshot('medicines_tab_compact_bn');
  });
}
