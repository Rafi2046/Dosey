import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/constants.dart';
import '../../core/database/app_database.dart';
import '../../core/localization/l10n.dart';
import '../../core/utils/dose_unit.dart';
import '../../core/utils/enum_labels.dart';
import '../../features/records/data/records_repository.dart';
import '../../features/reminders/data/reminders_repository.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/providers/settings_providers.dart';

/// DEBUG / SCREENSHOTS: fills the database with comprehensive, authentic data
/// so every screen (Dashboard, Medicines, Reminders, Dose History, Blood Pressure,
/// Blood Sugar, Doctors, Medical Records, Expenses, Doctor PDF Report, Profiles)
/// looks completely populated, realistic, and presentation-ready.
abstract final class DemoDataSeeder {
  static Future<void> seed(
    AppDatabase db,
    RemindersRepository reminders,
    RecordsRepository records,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── 0. CLEAN RESET PREVIOUS DATA ──────────────────────────────────────────
    await db.transaction(() async {
      await db.delete(db.reminderLogs).go();
      await db.delete(db.reminders).go();
      await db.delete(db.bloodPressureReadings).go();
      await db.delete(db.bloodSugarReadings).go();
      await db.delete(db.expenses).go();
      await db.delete(db.recordAttachments).go();
      await db.delete(db.records).go();
      await db.delete(db.medicines).go();
      await db.delete(db.doctors).go();

      // Ensure Profile 1 is named and add additional family profiles for switcher
      await (db.delete(db.profiles)..where((p) => p.id.isNotValue(1))).go();
      await (db.update(db.profiles)..where((p) => p.id.equals(1))).write(
        const ProfilesCompanion(name: Value('Tanvir Ahmed'), colorIndex: Value(0)),
      );
      await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          name: 'Ammu (Mother)',
          colorIndex: const Value(1),
        ),
      );
      await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          name: 'Abbu (Father)',
          colorIndex: const Value(2),
        ),
      );
    });

    // Set User Name & Onboarding in AppSettings
    final settingsRepo = SettingsRepository(db);
    await settingsRepo.set(userNameKey, 'Tanvir Ahmed');
    await settingsRepo.set(onboardingDoneKey, '1');

    // ── 1. DOCTORS ────────────────────────────────────────────────────────────
    Future<int> insertDoctor({
      required String name,
      required String specialty,
      required String phone,
      required String clinic,
      required int consultationFeeMinor,
      String? email,
      String? address,
      String? notes,
    }) => db.into(db.doctors).insert(
      DoctorsCompanion.insert(
        name: name,
        specialty: Value(specialty),
        phone: Value(phone),
        email: Value(email),
        clinic: Value(clinic),
        address: Value(address),
        consultationFeeMinor: Value(consultationFeeMinor),
        notes: Value(notes),
      ),
    );

    final drFarhana = await insertDoctor(
      name: 'Dr. Farhana Rahman',
      specialty: 'Endocrinology',
      phone: '+880 1711 234567',
      email: 'dr.farhana@squarehospital.com',
      clinic: 'Square Hospital, Dhaka',
      address: '18/F Bir Uttam Qazi Nuruzzaman Sarak, West Panthapath, Dhaka',
      consultationFeeMinor: 150000,
      notes: 'Room 402, Level 4. Specialises in Type 2 Diabetes, thyroid disorders and metabolic health.',
    );

    final drKamal = await insertDoctor(
      name: 'Dr. Kamal Hossain',
      specialty: 'Cardiology',
      phone: '+880 1819 876543',
      email: 'kamal.cardio@unitedhospital.com.bd',
      clinic: 'United Hospital, Dhaka',
      address: 'Plot 15, Road 71, Gulshan 2, Dhaka 1212',
      consultationFeeMinor: 200000,
      notes: 'Cardiac OPD, Room 210. Senior Consultant in preventive cardiology and hypertension management.',
    );

    final drNusrat = await insertDoctor(
      name: 'Dr. Nusrat Jahan',
      specialty: 'General Physician',
      phone: '+880 1912 345678',
      email: 'dr.nusrat.jahan@evercarebd.com',
      clinic: 'Evercare Hospital, Dhaka',
      address: 'Plot 81, Block E, Bashundhara R/A, Dhaka 1229',
      consultationFeeMinor: 120000,
      notes: 'Morning clinic (10 AM - 1 PM). Primary care physician for routine follow-ups, flu vaccination and vit-D.',
    );

    final drAhsan = await insertDoctor(
      name: 'Dr. Ahsan Habib',
      specialty: 'Neurology',
      phone: '+880 1611 998877',
      email: 'ahsan.habib.neuro@gmail.com',
      clinic: 'Apollo Diagnostic Center, Dhanmondi',
      address: 'House 58, Road 2/A, Dhanmondi, Dhaka',
      consultationFeeMinor: 180000,
      notes: 'Specialist in diabetic neuropathy, migraine headaches and peripheral nerve disorders.',
    );

    final drSabrina = await insertDoctor(
      name: 'Dr. Sabrina Sharmin',
      specialty: 'Eye',
      phone: '+880 1712 554433',
      email: 'dr.sabrina.eye@visioncare.bd',
      clinic: 'Vision Eye Hospital, Dhaka',
      address: 'House 12, Road 4, Sector 3, Uttara, Dhaka',
      consultationFeeMinor: 100000,
      notes: 'Consultant Ophthalmologist. Annual diabetic retinopathy screenings and routine vision checks.',
    );

    // ── 2. MEDICINES ──────────────────────────────────────────────────────────
    Future<int> insertMedicine({
      required String name,
      required String strength,
      required MedicineForm form,
      required int unitPriceMinor,
      required int doctorId,
      required MealRelation mealRelation,
      double? stockQuantity,
      double? refillThreshold,
      int? unitsPerStrip,
      int? stripsPerBox,
      int? refillAlertDays,
      int daysAgo = 30,
      int daysAhead = 60,
      String? notes,
    }) => db.into(db.medicines).insert(
      MedicinesCompanion.insert(
        name: name,
        strength: Value(strength),
        form: Value(form),
        doseUnit: Value(DoseUnit.toStored(form.defaultUnit(AppLocale.l10n))),
        mealRelation: Value(mealRelation),
        doctorId: Value(doctorId),
        unitPriceMinor: Value(unitPriceMinor),
        stockQuantity: Value(stockQuantity),
        refillThreshold: Value(refillThreshold),
        unitsPerStrip: Value(unitsPerStrip),
        stripsPerBox: Value(stripsPerBox),
        refillAlertDays: Value(refillAlertDays),
        startDate: today.subtract(Duration(days: daysAgo)),
        endDate: Value(today.add(Duration(days: daysAhead))),
        notes: Value(notes),
      ),
    );

    final metformin = await insertMedicine(
      name: 'Metformin HCl',
      strength: '500 mg',
      form: MedicineForm.tablet,
      unitPriceMinor: 800, // ৳8.00 per tablet
      doctorId: drFarhana,
      mealRelation: MealRelation.afterMeal,
      stockQuantity: 4, // LOW STOCK TRIGGER (≤ 5)
      refillThreshold: 10,
      unitsPerStrip: 10,
      stripsPerBox: 5,
      refillAlertDays: 3,
      notes: 'Take immediately after lunch & dinner with a glass of water. Do not skip meals.',
    );

    final insulin = await insertMedicine(
      name: 'Insulin Glargine (Lantus)',
      strength: '100 IU/ml',
      form: MedicineForm.injection,
      unitPriceMinor: 45000, // ৳450 per unit pen
      doctorId: drFarhana,
      mealRelation: MealRelation.beforeMeal,
      stockQuantity: 28,
      refillThreshold: 10,
      refillAlertDays: 7,
      notes: 'Subcutaneous injection 30 minutes before breakfast. Rotate injection sites between abdomen & thigh.',
    );

    final atorvastatin = await insertMedicine(
      name: 'Atorvastatin (Lipitor)',
      strength: '10 mg',
      form: MedicineForm.tablet,
      unitPriceMinor: 1500, // ৳15.00 per tablet
      doctorId: drKamal,
      mealRelation: MealRelation.afterMeal,
      stockQuantity: 24,
      refillThreshold: 7,
      unitsPerStrip: 10,
      stripsPerBox: 3,
      refillAlertDays: 5,
      notes: 'Take once daily at bedtime for cholesterol control.',
    );

    final vitaminD = await insertMedicine(
      name: 'Vitamin D3 (Cholecalciferol)',
      strength: '20,000 IU',
      form: MedicineForm.capsule,
      unitPriceMinor: 2500, // ৳25.00 per capsule
      doctorId: drNusrat,
      mealRelation: MealRelation.afterMeal,
      stockQuantity: 8,
      refillThreshold: 4,
      unitsPerStrip: 4,
      stripsPerBox: 2,
      notes: 'Take once weekly after breakfast or lunch with milk or fat-containing meal for high absorption.',
    );

    final inhaler = await insertMedicine(
      name: 'Seretide Evohaler',
      strength: '125 / 25 mcg',
      form: MedicineForm.inhaler,
      unitPriceMinor: 85000, // ৳850 per canister
      doctorId: drNusrat,
      mealRelation: MealRelation.anytime,
      stockQuantity: 45,
      refillThreshold: 20,
      notes: '2 puffs twice daily (morning & night). Rinse mouth thoroughly with water after each inhalation.',
    );

    final eyeDrops = await insertMedicine(
      name: 'Moxifloxacin Eye Drops',
      strength: '0.5% w/v',
      form: MedicineForm.drops,
      unitPriceMinor: 18000, // ৳180 per 5ml bottle
      doctorId: drSabrina,
      mealRelation: MealRelation.anytime,
      stockQuantity: 15,
      refillThreshold: 5,
      notes: 'Instill 1 drop in both eyes three times daily.',
    );

    final gaviscon = await insertMedicine(
      name: 'Gaviscon Liquid Syrup',
      strength: '200 ml',
      form: MedicineForm.syrup,
      unitPriceMinor: 28000, // ৳280 per bottle
      doctorId: drNusrat,
      mealRelation: MealRelation.afterMeal,
      stockQuantity: 120,
      refillThreshold: 40,
      notes: '10 ml after dinner or as needed when feeling heartburn or acidity.',
    );

    final napaExtra = await insertMedicine(
      name: 'Napa Extra',
      strength: '500 mg + 65 mg',
      form: MedicineForm.tablet,
      unitPriceMinor: 300, // ৳3.00 per tablet
      doctorId: drNusrat,
      mealRelation: MealRelation.afterMeal,
      stockQuantity: 18,
      refillThreshold: 6,
      unitsPerStrip: 10,
      stripsPerBox: 5,
      notes: 'Take 1 tablet as needed for headache or body fever (Max 3 tablets daily).',
    );

    // ── 3. REMINDERS & SCHEDULE ───────────────────────────────────────────────
    final reminderList = <({Reminder reminder, int hour, int minute})>[];

    // Medicine Reminders
    final insulinRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Insulin Glargine',
        medicineId: Value(insulin),
        doseAmount: const Value(10.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 8, minutes: 30)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: insulinRem, hour: 8, minute: 30));

    final inhalerMornRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Seretide Inhaler (Morning)',
        medicineId: Value(inhaler),
        doseAmount: const Value(2.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 9, minutes: 0)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: inhalerMornRem, hour: 9, minute: 0));

    final metLunchRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Metformin (After Lunch)',
        medicineId: Value(metformin),
        doseAmount: const Value(1.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 13, minutes: 30)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: metLunchRem, hour: 13, minute: 30));

    final eyeDropsRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Moxifloxacin Eye Drops',
        medicineId: Value(eyeDrops),
        doseAmount: const Value(1.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 14, minutes: 0)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: eyeDropsRem, hour: 14, minute: 0));

    final inhalerNightRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Seretide Inhaler (Night)',
        medicineId: Value(inhaler),
        doseAmount: const Value(2.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 21, minutes: 0)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: inhalerNightRem, hour: 21, minute: 0));

    final metDinnerRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Metformin (After Dinner)',
        medicineId: Value(metformin),
        doseAmount: const Value(1.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 21, minutes: 30)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: metDinnerRem, hour: 21, minute: 30));

    final atorvaRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Atorvastatin (Bedtime)',
        medicineId: Value(atorvastatin),
        doseAmount: const Value(1.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 22, minutes: 30)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: atorvaRem, hour: 22, minute: 30));

    final gavisconRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Gaviscon Liquid Syrup',
        medicineId: Value(gaviscon),
        doseAmount: const Value(10.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 22, minutes: 0)),
        repeatRule: const Value(RepeatRule.daily),
      ),
    );
    reminderList.add((reminder: gavisconRem, hour: 22, minute: 0));

    final vitDRem = await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Vitamin D3 Capsule',
        medicineId: Value(vitaminD),
        doseAmount: const Value(1.0),
        startAt: today.subtract(const Duration(days: 30)).add(const Duration(hours: 10, minutes: 0)),
        repeatRule: const Value(RepeatRule.weekly),
        weekdaysMask: const Value(1), // Sunday
      ),
    );
    reminderList.add((reminder: vitDRem, hour: 10, minute: 0));

    // Doctor Appointments & Clinical Events
    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.appointment,
        title: 'Diabetes Follow-up & Diet Review',
        doctorId: Value(drFarhana),
        location: const Value('Square Hospital (OPD Room 402)'),
        startAt: today.add(const Duration(days: 3, hours: 17, minutes: 30)),
        remindBeforeMinutes: const Value(120),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.appointment,
        title: 'Routine Cardiac Consultation & ECG',
        doctorId: Value(drKamal),
        location: const Value('United Hospital (Room 210)'),
        startAt: today.add(const Duration(days: 10, hours: 18, minutes: 30)),
        remindBeforeMinutes: const Value(1440),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.appointment,
        title: 'Neuropathy Consultation & Nerve Check',
        doctorId: Value(drAhsan),
        location: const Value('Apollo Diagnostic Center, Dhanmondi'),
        startAt: today.add(const Duration(days: 18, hours: 19, minutes: 0)),
        remindBeforeMinutes: const Value(240),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicalTest,
        title: 'HbA1c & Fasting Lipid Profile Blood Test',
        location: const Value('Popular Diagnostic Center, Dhanmondi'),
        startAt: today.add(const Duration(days: 2, hours: 8, minutes: 0)),
        remindBeforeMinutes: const Value(720),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.medicalTest,
        title: 'Kidney Function Test (Creatinine & eGFR)',
        location: const Value('Labaid Diagnostic, Gulshan'),
        startAt: today.add(const Duration(days: 14, hours: 9, minutes: 0)),
        remindBeforeMinutes: const Value(120),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.vaccine,
        title: 'Annual Influenza Vaccine (Flu Shot)',
        location: const Value('Praava Health, Banani'),
        startAt: today.add(const Duration(days: 6, hours: 11, minutes: 0)),
        remindBeforeMinutes: const Value(180),
      ),
    );

    await reminders.create(
      RemindersCompanion.insert(
        type: ReminderType.vaccine,
        title: 'Hepatitis B Booster Dose',
        location: const Value('Square Hospital Vaccine Center'),
        startAt: today.add(const Duration(days: 25, hours: 15, minutes: 0)),
        remindBeforeMinutes: const Value(1440),
      ),
    );

    // ── 4. 30-DAY REMINDER LOGS (ADHERENCE & DOSE HISTORY) ────────────────────
    // Generate realistic logs for the past 30 days:
    // High adherence rate (~94%), with a few skips and late takes.
    for (var d = 30; d >= 1; d--) {
      final logDay = today.subtract(Duration(days: d));
      for (final item in reminderList) {
        final scheduledTime = DateTime(
          logDay.year,
          logDay.month,
          logDay.day,
          item.hour,
          item.minute,
        );

        // Deterministic realistic adherence pattern
        final dayMod = (d * 7 + item.hour) % 100;
        final ReminderLogStatus status;
        final DateTime? actedAt;

        if (dayMod < 3) {
          status = ReminderLogStatus.skipped;
          actedAt = scheduledTime.add(const Duration(minutes: 15));
        } else if (dayMod < 8) {
          status = ReminderLogStatus.takenLate;
          actedAt = scheduledTime.add(const Duration(hours: 1, minutes: 20));
        } else {
          status = ReminderLogStatus.taken;
          actedAt = scheduledTime.add(Duration(minutes: (dayMod % 12) + 2));
        }

        await db.into(db.reminderLogs).insert(
          ReminderLogsCompanion.insert(
            reminderId: item.reminder.id,
            scheduledFor: scheduledTime,
            status: status,
            actedAt: Value(actedAt),
          ),
        );
      }
    }

    // Today's Logs:
    // Mark doses that were due earlier today as taken, leaving upcoming ones pending
    for (final item in reminderList) {
      final scheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        item.hour,
        item.minute,
      );
      if (scheduledTime.isBefore(now)) {
        await db.into(db.reminderLogs).insert(
          ReminderLogsCompanion.insert(
            reminderId: item.reminder.id,
            scheduledFor: scheduledTime,
            status: ReminderLogStatus.taken,
            actedAt: Value(scheduledTime.add(const Duration(minutes: 5))),
          ),
        );
      }
    }

    // ── 5. BLOOD PRESSURE LOGS (14 ENTRIES ACROSS 14 DAYS) ────────────────────
    final bpEntries = [
      (0, 8, 0, 120, 78, 72, 'Morning resting check after 5 mins calm sitting'),
      (1, 20, 0, 124, 82, 75, 'Evening reading after returning from work'),
      (2, 8, 15, 118, 76, 70, 'Fasting morning reading, feels relaxed'),
      (3, 19, 30, 122, 80, 74, 'Post evening walk checkup'),
      (4, 21, 0, 128, 84, 78, 'Long workday, slightly fatigued'),
      (5, 9, 0, 119, 75, 69, 'Weekend morning resting check'),
      (6, 18, 45, 121, 79, 71, 'Pre-dinner baseline reading'),
      (7, 8, 30, 125, 81, 76, 'Morning check before breakfast'),
      (8, 8, 0, 117, 74, 68, 'Morning resting after light breathing exercise'),
      (9, 19, 0, 123, 80, 73, 'Evening routine reading'),
      (10, 8, 30, 126, 82, 77, 'After morning brisk walk'),
      (11, 8, 15, 120, 78, 72, 'Normal resting check'),
      (12, 20, 30, 122, 79, 74, 'Night reading before bedtime'),
      (13, 8, 0, 118, 77, 70, 'Baseline weekly evaluation'),
    ];

    for (final (daysAgo, h, m, sys, dia, pulse, note) in bpEntries) {
      await db.into(db.bloodPressureReadings).insert(
        BloodPressureReadingsCompanion.insert(
          systolic: sys,
          diastolic: dia,
          pulse: Value(pulse),
          measuredAt: today.subtract(Duration(days: daysAgo)).add(Duration(hours: h, minutes: m)),
          note: Value(note),
        ),
      );
    }

    // ── 6. BLOOD SUGAR LOGS (14 ENTRIES ACROSS 14 DAYS) ──────────────────────
    final sugarEntries = [
      (0, 7, 30, 5.4, SugarContext.fasting, 'Fasting 9 hours overnight'),
      (1, 14, 30, 7.2, SugarContext.afterMeal, '2 hours post lunch (rice & chicken curry)'),
      (2, 7, 45, 5.6, SugarContext.fasting, 'Morning fasting reading'),
      (3, 19, 0, 6.8, SugarContext.beforeMeal, 'Before dinner check'),
      (4, 22, 0, 7.9, SugarContext.afterMeal, '2 hours after heavy dinner'),
      (5, 23, 0, 5.8, SugarContext.bedtime, 'Bedtime blood glucose check'),
      (6, 8, 0, 5.3, SugarContext.fasting, 'Fasting morning check'),
      (7, 10, 30, 7.4, SugarContext.afterMeal, '2 hours post breakfast (oats & egg)'),
      (8, 16, 0, 6.2, SugarContext.random, 'Mid-afternoon snack check'),
      (9, 7, 30, 5.5, SugarContext.fasting, 'Morning fasting check'),
      (10, 15, 0, 7.8, SugarContext.afterMeal, '2 hours post lunch'),
      (11, 22, 45, 5.9, SugarContext.bedtime, 'Bedtime reading'),
      (12, 7, 45, 5.4, SugarContext.fasting, 'Morning fasting check'),
      (13, 21, 30, 7.1, SugarContext.afterMeal, '2 hours post dinner'),
    ];

    for (final (daysAgo, h, m, mmol, context, note) in sugarEntries) {
      await db.into(db.bloodSugarReadings).insert(
        BloodSugarReadingsCompanion.insert(
          mmol: mmol,
          context: context,
          measuredAt: today.subtract(Duration(days: daysAgo)).add(Duration(hours: h, minutes: m)),
          note: Value(note),
        ),
      );
    }

    // ── 7. MEDICAL RECORDS & ATTACHMENTS (ALL CATEGORIES) ────────────────────
    final rxBytes = await rootBundle.load(AppImages.samplePrescription);
    final rxTmp = File('${(await getTemporaryDirectory()).path}/demo_rx.jpg')
      ..writeAsBytesSync(rxBytes.buffer.asUint8List());

    final labBytes = await rootBundle.load(AppImages.sampleLabReport);
    final labTmp = File('${(await getTemporaryDirectory()).path}/demo_lab.jpg')
      ..writeAsBytesSync(labBytes.buffer.asUint8List());

    // Record 1: Prescription (2 pages)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.prescription,
        title: 'Endocrinology Prescription & Advice',
        recordDate: today.subtract(const Duration(days: 15)),
        doctorId: Value(drFarhana),
        notes: const Value('Metformin 500mg BD and Insulin Glargine 10 units prescribed. Regular glucose charting advised.'),
      ),
      [rxTmp.path, rxTmp.path],
    );

    // Record 2: Test Report (1 page)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.testReport,
        title: 'Lipid Profile & Liver Function Panel',
        recordDate: today.subtract(const Duration(days: 10)),
        doctorId: Value(drKamal),
        notes: const Value('Total Cholesterol: 185 mg/dL, HDL: 48 mg/dL, LDL: 104 mg/dL, Triglycerides: 155 mg/dL. Normal limits.'),
      ),
      [labTmp.path],
    );

    // Record 3: Test Report (1 page)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.testReport,
        title: 'HbA1c & Fasting Plasma Glucose',
        recordDate: today.subtract(const Duration(days: 8)),
        doctorId: Value(drFarhana),
        notes: const Value('HbA1c: 6.7% (Target < 7.0%, well controlled). Fasting glucose: 5.4 mmol/L.'),
      ),
      [labTmp.path],
    );

    // Record 4: Vaccine Certificate (1 page)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.vaccineCertificate,
        title: 'Influenza Vaccine Certificate 2026',
        recordDate: today.subtract(const Duration(days: 28)),
        doctorId: Value(drNusrat),
        notes: const Value('Quadrivalent Inactivated Flu Vaccine administered in left deltoid.'),
      ),
      [rxTmp.path],
    );

    // Record 5: Invoice (1 page)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.invoice,
        title: 'Square Hospital Pharmacy Invoice',
        recordDate: today.subtract(const Duration(days: 14)),
        doctorId: Value(drFarhana),
        notes: const Value('Purchased monthly refill of Metformin, Insulin Glargine, and BD Micro-Fine needles.'),
      ),
      [labTmp.path],
    );

    // Record 6: Other / Medical Summary (1 page)
    await records.create(
      RecordsCompanion.insert(
        type: RecordType.other,
        title: 'Annual Diabetic Eye Screening Report',
        recordDate: today.subtract(const Duration(days: 20)),
        doctorId: Value(drSabrina),
        notes: const Value('Fundoscopy normal. No microaneurysms or signs of diabetic retinopathy. Visual acuity 6/6 OU.'),
      ),
      [rxTmp.path],
    );

    // ── 8. EXPENSES (6-MONTH HISTORICAL TREND & CATEGORIES) ───────────────────
    // Current Month Expenses:
    final currentMonthExpenses = [
      ('Metformin & Atorvastatin Monthly Supply', ExpenseCategory.medicine, 145000, 2, metformin, drFarhana),
      ('Insulin Glargine Lantus 100IU Pen', ExpenseCategory.medicine, 135000, 5, insulin, drFarhana),
      ('Dr. Farhana Rahman Consultation', ExpenseCategory.consultation, 150000, 8, null, drFarhana),
      ('HbA1c & Fasting Lipid Profile Test', ExpenseCategory.test, 220000, 10, null, drFarhana),
      ('Seretide Evohaler Inhaler', ExpenseCategory.medicine, 85000, 12, inhaler, drNusrat),
      ('Accu-Chek Blood Glucose Test Strips (50 pcs)', ExpenseCategory.other, 95000, 15, null, null),
      ('Dr. Sabrina Sharmin Eye Checkup', ExpenseCategory.consultation, 100000, 18, null, drSabrina),
      ('Influenza Vaccine Dose', ExpenseCategory.vaccine, 120000, 20, null, drNusrat),
      ('Napa Extra 1 Box (100 tablets)', ExpenseCategory.medicine, 30000, 22, napaExtra, drNusrat),
      ('Vitamin D3 20,000 IU 2 Strips', ExpenseCategory.medicine, 20000, 25, vitaminD, drNusrat),
      ('Dr. Ahsan Habib Neuropathy Checkup', ExpenseCategory.consultation, 180000, 26, null, drAhsan),
    ];

    for (final (title, category, amount, daysAgo, medId, docId) in currentMonthExpenses) {
      final spentDate = today.subtract(
        Duration(days: daysAgo.clamp(0, today.day > 1 ? today.day - 1 : 0)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          category: category,
          title: title,
          amountMinor: amount,
          spentOn: spentDate,
          medicineId: Value(medId),
          doctorId: Value(docId),
        ),
      );
    }

    // Historical Expenses (Months -1 to -5 for 6-Month Trend Chart):
    final historicalMonths = [
      // 1 month ago
      (1, [
        ('Monthly Medicines Refill', ExpenseCategory.medicine, 280000, 10),
        ('Dr. Kamal Cardiology Follow-up', ExpenseCategory.consultation, 200000, 15),
        ('ECG & Echocardiogram Test', ExpenseCategory.test, 180000, 18),
        ('Hepatitis B Booster Dose', ExpenseCategory.vaccine, 120000, 22),
      ]),
      // 2 months ago
      (2, [
        ('Insulin & Oral Hypoglycemics', ExpenseCategory.medicine, 310000, 8),
        ('Dr. Farhana Follow-up', ExpenseCategory.consultation, 150000, 12),
        ('Omron Digital BP Monitor', ExpenseCategory.other, 250000, 20),
      ]),
      // 3 months ago
      (3, [
        ('Prescription Refill', ExpenseCategory.medicine, 265000, 5),
        ('Specialist Consultations', ExpenseCategory.consultation, 320000, 14),
        ('Comprehensive Blood & Urine Panel', ExpenseCategory.test, 240000, 20),
      ]),
      // 4 months ago
      (4, [
        ('Quarterly Medicine Stock', ExpenseCategory.medicine, 290000, 7),
        ('General Physician Checkup', ExpenseCategory.consultation, 120000, 15),
        ('Serum Creatinine & Electrolytes', ExpenseCategory.test, 150000, 22),
      ]),
      // 5 months ago
      (5, [
        ('Monthly Prescriptions', ExpenseCategory.medicine, 275000, 6),
        ('Cardiology Consultation', ExpenseCategory.consultation, 200000, 12),
        ('Cardiac Stress Test (ETT)', ExpenseCategory.test, 300000, 25),
      ]),
    ];

    for (final (monthOffset, entries) in historicalMonths) {
      final targetMonth = DateTime(today.year, today.month - monthOffset, 15);
      for (final (title, category, amount, day) in entries) {
        final spentDate = DateTime(targetMonth.year, targetMonth.month, day);
        await db.into(db.expenses).insert(
          ExpensesCompanion.insert(
            category: category,
            title: title,
            amountMinor: amount,
            spentOn: spentDate,
          ),
        );
      }
    }
  }
}

