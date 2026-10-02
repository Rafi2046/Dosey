import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/constants.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/enum_labels.dart';
import '../../features/records/data/records_repository.dart';
import '../../features/reminders/data/reminders_repository.dart';

/// DEBUG ONLY: fills an empty install with realistic data so every screen
/// can be reviewed. Never referenced from release code paths.
abstract final class DemoDataSeeder {
  static Future<void> seed(
    AppDatabase db,
    RemindersRepository reminders,
    RecordsRepository records,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Future<int> doctor(String name, String specialty) => db
        .into(db.doctors)
        .insert(
          DoctorsCompanion.insert(
            name: name,
            specialty: Value(specialty),
            phone: const Value('+880 1711 000000'),
            clinic: const Value('Square Hospital, Dhaka'),
            consultationFeeMinor: const Value(100000),
          ),
        );
    final endo = await doctor('Dr. Farhana Rahman', 'Endocrinologist');
    final cardio = await doctor('Dr. Kamal Hossain', 'Cardiologist');
    final gp = await doctor('Dr. Nusrat Jahan', 'General Physician');

    Future<int> medicine(
      String name,
      String strength,
      MedicineForm form,
      int price,
      int doctorId, {
      double? stock,
      String? notes,
    }) => db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: name,
            strength: Value(strength),
            form: Value(form),
            doseUnit: Value(form.defaultUnit),
            startDate: today.subtract(const Duration(days: 20)),
            endDate: Value(today.add(const Duration(days: 15))),
            unitPriceMinor: Value(price),
            stockQuantity: Value(stock),
            refillThreshold: Value(stock == null ? null : 5),
            doctorId: Value(doctorId),
            notes: Value(notes),
            mealRelation: const Value(MealRelation.afterMeal),
          ),
        );
    final metformin = await medicine(
      'Metformin',
      '500 mg',
      MedicineForm.tablet,
      800,
      endo,
      stock: 4, //
    );
    final vitD = await medicine(
      'Vitamin D',
      '1000 IU',
      MedicineForm.capsule,
      1500,
      gp,
      stock: 30,
    );
    final insulin = await medicine(
      'Insulin',
      '10 units',
      MedicineForm.injection,
      45000,
      endo,
      notes: 'Take 30 minutes before your morning meal. Rotate sites.',
    );
    final atorva = await medicine(
      'Atorvastatin',
      '10 mg',
      MedicineForm.tablet,
      1200,
      cardio,
      stock: 20,
    );

    for (final (id, title, hour, minute) in [
      (insulin, 'Insulin', 9, 0),
      (metformin, 'Metformin', 13, 30),
      (vitD, 'Vitamin D', 17, 25),
      (metformin, 'Metformin', 21, 0),
      (atorva, 'Atorvastatin', 22, 0),
    ]) {
      await reminders.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: title,
          medicineId: Value(id),
          startAt: today
              .subtract(const Duration(days: 20))
              .add(Duration(hours: hour, minutes: minute)),
          repeatRule: const Value(RepeatRule.daily),
        ),
      );
    }
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.appointment,
        title: 'Diabetes follow-up',
        doctorId: Value(endo),
        location: const Value('Square Hospital'),
        startAt: today.add(const Duration(days: 4, hours: 17, minutes: 30)),
      ),
    );
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicalTest,
        title: 'HbA1c blood test',
        startAt: today.add(const Duration(days: 2, hours: 8)),
      ),
    );
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.vaccine,
        title: 'Flu shot',
        startAt: today.add(const Duration(days: 9, hours: 11)),
      ),
    );

    // A prescription "photo" from a bundled asset.
    final bytes = await rootBundle.load(AppImages.medOther);
    final tmp = File('${(await getTemporaryDirectory()).path}/demo_rx.png')
      ..writeAsBytesSync(bytes.buffer.asUint8List());
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.prescription,
        title: 'Endocrinology prescription',
        recordDate: today.subtract(const Duration(days: 20)),
        doctorId: Value(endo),
      ),
      [tmp.path, tmp.path],
    );
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.testReport,
        title: 'Lipid profile',
        recordDate: today.subtract(const Duration(days: 7)),
        doctorId: Value(cardio),
      ),
      [tmp.path],
    );

    for (final (title, category, amount, daysAgo) in [
      ('Metformin strip', ExpenseCategory.medicine, 24000, 1),
      ('Insulin pen', ExpenseCategory.medicine, 135000, 3),
      ('Dr. Farhana consultation', ExpenseCategory.consultation, 100000, 5),
      ('Lipid profile test', ExpenseCategory.test, 150000, 7),
    ]) {
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              category: category,
              title: title,
              amountMinor: amount,
              // Keep them inside the current month.
              spentOn: today.subtract(
                Duration(days: daysAgo.clamp(0, today.day - 1)),
              ),
            ),
          );
    }
  }
}
