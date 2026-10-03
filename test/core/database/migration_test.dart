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

  test('settings table works after upgrade', () async {
    final db = _openV2();
    addTearDown(db.close);
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'locale', value: 'bn'));
    expect((await db.select(db.appSettings).getSingle()).value, 'bn');
  });
}
