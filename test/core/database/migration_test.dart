import 'dart:io';

import 'package:dosey/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exact v2 / v3 schemas, dumped from sqlite_master before each change.
final _v2Schema = File(
  'test/core/database/fixtures/schema_v2.sql',
).readAsStringSync();
final _v3Schema = File(
  'test/core/database/fixtures/schema_v3.sql',
).readAsStringSync();
final _v4Schema = File(
  'test/core/database/fixtures/schema_v4.sql',
).readAsStringSync();
final _v5Schema = File(
  'test/core/database/fixtures/schema_v5.sql',
).readAsStringSync();
final _v6Schema = File(
  'test/core/database/fixtures/schema_v6.sql',
).readAsStringSync();
final _v7Schema = File(
  'test/core/database/fixtures/schema_v7.sql',
).readAsStringSync();

/// A v7 database (heads-ups) with one of everything, before profiles.
AppDatabase _openV7({String? userName}) => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v7Schema);
      raw.execute('PRAGMA user_version = 7');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_unit, meal_relation,
            unit_price_minor, stock_quantity, start_date)
        VALUES (1, 'Napa', 'tablet', 'tablet', 'afterMeal', 100, 20, 0);
        INSERT INTO reminders (id, type, title, medicine_id, start_at,
            repeat_rule, is_critical, is_enabled, snooze_minutes, dose_amount,
            remind_before_minutes)
        VALUES (10, 'medicine', 'Napa', 1, 1000, 'daily', 1, 1, 10, 1.0, NULL),
               (11, 'appointment', 'Dr visit', NULL, 5000, 'once', 0, 1, 10,
                NULL, 1440);
        INSERT INTO reminder_logs (reminder_id, scheduled_for, status)
        VALUES (10, 1000, 'taken');
        INSERT INTO records (id, type, title, record_date)
        VALUES (1, 'prescription', 'Rx', 0);
        INSERT INTO expenses (category, title, amount_minor, spent_on)
        VALUES ('medicine', 'Napa strip', 500, 0);
        INSERT INTO blood_pressure_readings (systolic, diastolic, measured_at)
        VALUES (128, 84, 1000);
        INSERT INTO blood_sugar_readings (mmol, context, measured_at)
        VALUES (6.4, 'fasting', 1000);
      ''');
      if (userName != null) {
        raw.execute(
          "INSERT INTO app_settings (key, value) VALUES ('user_name', '$userName')",
        );
      }
    },
  ),
);

/// A v6 database (blood sugar log) with real data, before heads-ups.
AppDatabase _openV6() => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v6Schema);
      raw.execute('PRAGMA user_version = 6');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_unit, meal_relation,
            unit_price_minor, stock_quantity, start_date)
        VALUES (1, 'Napa', 'tablet', 'tablet', 'afterMeal', 100, 20, 0);
        INSERT INTO reminders (id, type, title, medicine_id, start_at,
            repeat_rule, is_critical, is_enabled, snooze_minutes, dose_amount)
        VALUES (10, 'medicine', 'Napa', 1, 1000, 'daily', 1, 1, 10, 1.0),
               (11, 'appointment', 'Dr visit', NULL, 5000, 'once', 0, 1, 10,
                NULL);
        INSERT INTO reminder_logs (reminder_id, scheduled_for, status)
        VALUES (10, 1000, 'missed');
        INSERT INTO blood_sugar_readings (mmol, context, measured_at)
        VALUES (6.4, 'fasting', 1000);
      ''');
    },
  ),
);

/// A v5 database (blood pressure log) with real data, before blood sugar.
AppDatabase _openV5() => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v5Schema);
      raw.execute('PRAGMA user_version = 5');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_unit, meal_relation,
            unit_price_minor, stock_quantity, start_date)
        VALUES (1, 'Metformin', 'tablet', 'tablet', 'afterMeal', 300, 60, 0);
        INSERT INTO blood_pressure_readings (systolic, diastolic, measured_at)
        VALUES (128, 84, 1000);
        INSERT INTO app_settings (key, value) VALUES ('user_name', 'Rafi');
      ''');
    },
  ),
);

/// A v4 database (stock planning) with real data, before blood pressure.
AppDatabase _openV4() => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v4Schema);
      raw.execute('PRAGMA user_version = 4');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_unit, meal_relation,
            unit_price_minor, stock_quantity, start_date, refill_alert_days)
        VALUES (1, 'Zulfidin', 'tablet', 'tablet', 'afterMeal', 300, 40, 0, 5);
        INSERT INTO reminders (id, type, title, medicine_id, start_at,
            repeat_rule, is_critical, is_enabled, snooze_minutes, dose_amount)
        VALUES (10, 'medicine', 'Zulfidin', 1, 1000, 'daily', 1, 1, 10, 2.0);
        INSERT INTO reminder_logs (reminder_id, scheduled_for, status)
        VALUES (10, 1000, 'taken');
        INSERT INTO app_settings (key, value) VALUES ('user_name', 'Rafi');
      ''');
    },
  ),
);

/// A v3 database (dose per reminder, settings table) with real data.
AppDatabase _openV3() => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v3Schema);
      raw.execute('PRAGMA user_version = 3');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_unit, meal_relation,
            unit_price_minor, stock_quantity, refill_threshold, start_date)
        VALUES (1, 'Zulfidin', 'tablet', 'tablet', 'afterMeal', 300, 40, 12, 0);
        INSERT INTO reminders (id, type, title, medicine_id, start_at,
            repeat_rule, is_critical, is_enabled, snooze_minutes, dose_amount)
        VALUES (10, 'medicine', 'Zulfidin', 1, 1000, 'daily', 1, 1, 10, 2.0);
        INSERT INTO reminder_logs (reminder_id, scheduled_for, status)
        VALUES (10, 1000, 'taken');
        INSERT INTO app_settings (key, value) VALUES ('locale', 'bn');
      ''');
    },
  ),
);

/// A v2 database holding real-looking data, as an existing user would have.
AppDatabase _openV2() => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v2Schema);
      raw.execute('PRAGMA user_version = 2');
      raw.execute('''
        INSERT INTO medicines (id, name, form, dose_amount, dose_unit,
            meal_relation, unit_price_minor, stock_quantity, start_date)
        VALUES (1, 'Napa', 'tablet', 2.0, 'tablet', 'afterMeal', 250, 20, 0),
               (2, 'Ambrox', 'syrup', 5.0, 'ml', 'anytime', 10, NULL, 0);
        INSERT INTO reminders (id, type, title, medicine_id, start_at,
            repeat_rule, is_critical, is_enabled, snooze_minutes)
        VALUES (10, 'medicine', 'Napa', 1, 1000, 'daily', 1, 1, 10),
               (11, 'medicine', 'Napa', 1, 2000, 'daily', 1, 1, 10),
               (12, 'medicine', 'Ambrox', 2, 3000, 'daily', 1, 1, 10),
               (13, 'appointment', 'Dr visit', NULL, 4000, 'once', 0, 1, 10);
        INSERT INTO reminder_logs (reminder_id, scheduled_for, status)
        VALUES (10, 1000, 'taken');
        INSERT INTO expenses (category, title, amount_minor, medicine_id,
            spent_on)
        VALUES ('medicine', 'Napa strip', 500, 1, 0);
      ''');
    },
  ),
);

Future<List<String>> _schema(AppDatabase db) async => [
  for (final row
      in await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE sql IS NOT NULL "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get())
    row.read<String>('sql').replaceAll('"', ''),
];

void main() {
  // Separate in-memory databases, not one DB opened twice.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('v2 → v3 moves each dose onto its reminders, losing nothing', () async {
    final db = _openV2();
    addTearDown(db.close);

    final reminders = {
      for (final r in await db.select(db.reminders).get()) r.id: r,
    };
    expect(reminders.keys, unorderedEquals([10, 11, 12, 13]));
    expect(reminders[10]!.doseAmount, 2.0);
    expect(reminders[11]!.doseAmount, 2.0);
    expect(reminders[12]!.doseAmount, 5.0);
    expect(reminders[13]!.doseAmount, isNull); // appointment: no dose

    final meds = await db.select(db.medicines).get();
    expect([for (final m in meds) m.name], ['Napa', 'Ambrox']);
    expect(meds.first.stockQuantity, 20);
    expect(meds.first.doseUnit, 'tablet');

    // Rows that point at medicines/reminders survived the table rebuilds.
    expect(await db.select(db.reminderLogs).get(), hasLength(1));
    expect((await db.select(db.expenses).getSingle()).medicineId, 1);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    // Cascades still work after the rebuild (FKs back on).
    await (db.delete(db.medicines)..where((m) => m.id.equals(2))).go();
    expect(await db.select(db.reminders).get(), hasLength(3));
  });

  test('v3 → v4 adds stock planning, keeping every row', () async {
    final db = _openV3();
    addTearDown(db.close);
    final med = await db.select(db.medicines).getSingle();
    expect(med.stockQuantity, 40);
    expect(med.refillThreshold, 12); // old alert still honoured
    expect(med.unitsPerStrip, isNull);
    expect(med.refillAlertDays, isNull);
    expect((await db.select(db.reminders).getSingle()).doseAmount, 2.0);
    expect(await db.select(db.reminderLogs).get(), hasLength(1));
    expect((await db.select(db.appSettings).getSingle()).value, 'bn');
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test(
    'a v3 database migrates to the same schema as a fresh install',
    () async {
      final migrated = _openV3();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(migrated.close);
      addTearDown(fresh.close);
      expect(await _schema(migrated), await _schema(fresh));
    },
  );

  test('a migrated database is identical to a fresh install', () async {
    final migrated = _openV2();
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(migrated.close);
    addTearDown(fresh.close);

    expect(await _schema(migrated), await _schema(fresh));
  });

  test('v4 → v5 adds the blood pressure log, keeping every row', () async {
    final db = _openV4();
    addTearDown(db.close);
    final med = await db.select(db.medicines).getSingle();
    expect(med.stockQuantity, 40);
    expect(med.refillAlertDays, 5);
    expect((await db.select(db.reminders).getSingle()).doseAmount, 2.0);
    expect(await db.select(db.reminderLogs).get(), hasLength(1));
    expect((await db.select(db.appSettings).getSingle()).value, 'Rafi');

    // The new table is there and usable.
    expect(await db.select(db.bloodPressureReadings).get(), isEmpty);
    await db
        .into(db.bloodPressureReadings)
        .insert(
          BloodPressureReadingsCompanion.insert(
            systolic: 128,
            diastolic: 84,
            measuredAt: DateTime(2026, 10, 4, 8),
          ),
        );
    expect(await db.select(db.bloodPressureReadings).get(), hasLength(1));
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test(
    'a v4 database migrates to the same schema as a fresh install',
    () async {
      final migrated = _openV4();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(migrated.close);
      addTearDown(fresh.close);
      expect(await _schema(migrated), await _schema(fresh));
    },
  );

  test('v5 → v6 adds the blood sugar log, keeping every row', () async {
    final db = _openV5();
    addTearDown(db.close);
    expect((await db.select(db.medicines).getSingle()).stockQuantity, 60);
    expect(
      (await db.select(db.bloodPressureReadings).getSingle()).systolic,
      128,
    );
    expect((await db.select(db.appSettings).getSingle()).value, 'Rafi');
    await db
        .into(db.bloodSugarReadings)
        .insert(
          BloodSugarReadingsCompanion.insert(
            mmol: 6.4,
            context: SugarContext.fasting,
            measuredAt: DateTime(2026, 10, 4, 7),
          ),
        );
    expect(await db.select(db.bloodSugarReadings).get(), hasLength(1));
  });

  test(
    'a v5 database migrates to the same schema as a fresh install',
    () async {
      final migrated = _openV5();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(migrated.close);
      addTearDown(fresh.close);
      expect(await _schema(migrated), await _schema(fresh));
    },
  );

  test('blood sugar values outside 1–35 mmol/L are refused', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    Future<int> add(double v) => db
        .into(db.bloodSugarReadings)
        .insert(
          BloodSugarReadingsCompanion.insert(
            mmol: v,
            context: SugarContext.random,
            measuredAt: DateTime(2026),
          ),
        );
    await expectLater(add(0.5), throwsA(anything));
    await expectLater(add(60), throwsA(anything));
    expect(await add(6.5), greaterThan(0));
  });

  test('blood pressure values outside human ranges are refused', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    Future<int> add(int sys, int dia) => db
        .into(db.bloodPressureReadings)
        .insert(
          BloodPressureReadingsCompanion.insert(
            systolic: sys,
            diastolic: dia,
            measuredAt: DateTime(2026),
          ),
        );
    await expectLater(add(400, 80), throwsA(anything));
    await expectLater(add(120, 5), throwsA(anything));
    expect(await add(120, 80), greaterThan(0));
  });

  test('settings table works after upgrade', () async {
    final db = _openV2();
    addTearDown(db.close);
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'locale', value: 'bn'));
    expect((await db.select(db.appSettings).getSingle()).value, 'bn');
  });

  test('v6 → v7 adds heads-ups to reminders, keeping every row', () async {
    final db = _openV6();
    addTearDown(db.close);
    final reminders = await db.select(db.reminders).get();
    expect(reminders.map((r) => r.title), ['Napa', 'Dr visit']);
    expect(reminders.map((r) => r.remindBeforeMinutes), [null, null]);
    expect(
      (await db.select(db.reminderLogs).getSingle()).status,
      ReminderLogStatus.missed,
    );
    expect(await db.select(db.bloodSugarReadings).get(), hasLength(1));
    // The new column is writable.
    await (db.update(db.reminders)..where((r) => r.id.equals(11))).write(
      const RemindersCompanion(remindBeforeMinutes: Value(1440)),
    );
    expect(
      (await (db.select(
        db.reminders,
      )..where((r) => r.id.equals(11))).getSingle()).remindBeforeMinutes,
      1440,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test(
    'a v6 database migrates to the same schema as a fresh install',
    () async {
      final migrated = _openV6();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(migrated.close);
      addTearDown(fresh.close);
      expect(await _schema(migrated), await _schema(fresh));
    },
  );

  test(
    'v7 → v8 gives everything to the first profile, keeping every row',
    () async {
      final db = _openV7(userName: 'Rafi');
      addTearDown(db.close);
      final profiles = await db.select(db.profiles).get();
      expect([for (final p in profiles) (p.id, p.name)], [(1, 'Rafi')]);
      expect((await db.select(db.medicines).getSingle()).profileId, 1);
      expect(
        (await db.select(db.reminders).get()).map(
          (r) => (r.title, r.profileId),
        ),
        [('Napa', 1), ('Dr visit', 1)],
      );
      expect(
        (await db.select(db.reminders).get()).last.remindBeforeMinutes,
        1440,
      );
      expect((await db.select(db.records).getSingle()).profileId, 1);
      expect((await db.select(db.expenses).getSingle()).profileId, 1);
      expect(
        (await db.select(db.bloodPressureReadings).getSingle()).profileId,
        1,
      );
      expect((await db.select(db.bloodSugarReadings).getSingle()).profileId, 1);
      expect(await db.select(db.reminderLogs).get(), hasLength(1));
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    },
  );

  test(
    'without a saved name the first profile is unnamed (shown as Me)',
    () async {
      final db = _openV7();
      addTearDown(db.close);
      expect((await db.select(db.profiles).getSingle()).name, '');
    },
  );

  test('a fresh install starts with profile 1', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect((await db.select(db.profiles).getSingle()).id, 1);
  });

  test('deleting a profile deletes its data, not anyone else\'s', () async {
    final db = _openV7();
    addTearDown(db.close);
    final ammu = await db
        .into(db.profiles)
        .insert(ProfilesCompanion.insert(name: 'Ammu'));
    await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Seclo',
            startDate: DateTime(2026),
            profileId: Value(ammu),
          ),
        );
    await (db.delete(db.profiles)..where((p) => p.id.equals(ammu))).go();
    expect((await db.select(db.medicines).get()).map((m) => m.name), ['Napa']);
  });

  test(
    'a v7 database migrates to the same schema as a fresh install',
    () async {
      final migrated = _openV7();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(migrated.close);
      addTearDown(fresh.close);
      expect(await _schema(migrated), await _schema(fresh));
    },
  );
}
