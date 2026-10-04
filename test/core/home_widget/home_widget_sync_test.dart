import 'dart:convert';

import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/home_widget/home_widget_sync.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(AppLocale.english);
  late AppDatabase db;
  late RemindersRepository repo;
  final now = DateTime(2026, 10, 4, 20, 30);

  setUpAll(AppLocale.ensureInitialized);
  setUp(() {
    AppLocale.apply(AppLocale.english);
    db = AppDatabase(NativeDatabase.memory());
    repo = RemindersRepository(db);
  });
  tearDown(() => db.close());

  Future<int> daily(String name, int hour, double amount) async {
    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: name,
            startDate: DateTime(2026),
            mealRelation: const Value(MealRelation.afterMeal),
          ),
        );
    final r = await repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: name,
        startAt: DateTime(2026, 10, 1, hour),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        doseAmount: Value(amount),
      ),
      now: now,
    );
    return r.id;
  }

  Future<List<WidgetSlot>> plan() async => HomeWidgetSync.plan(
    en,
    await repo.getEnabledDetails(),
    await repo.logsBetween(DateTime(2026), DateTime(2027)),
    now,
  );

  test('next slot: medicines due together are one entry', () async {
    await daily('Metformin', 21, 2);
    await daily('Calbo D', 21, 1);
    await daily('Napa', 8, 1);

    final slots = await plan();
    expect(slots.first.at, DateTime(2026, 10, 4, 21));
    expect(slots.first.title, en.alarmGroupCount(2));
    expect(slots.first.lines, ['Metformin · 2 tablets', 'Calbo D · 1 tablet']);
    // Then tomorrow 08:00 on its own, with dose and meal.
    expect(slots[1].at, DateTime(2026, 10, 5, 8));
    expect(slots[1].title, 'Napa');
    expect(slots[1].lines, ['1 tablet · After meal']);
  });

  test('a taken or skipped dose drops off; a snoozed one stays', () async {
    final a = await daily('Metformin', 21, 2);
    final b = await daily('Calbo D', 21, 1);
    final at = DateTime(2026, 10, 4, 21);
    await repo.logAction(
      reminderId: a,
      scheduledFor: at,
      status: ReminderLogStatus.taken,
    );
    await repo.logAction(
      reminderId: b,
      scheduledFor: at,
      status: ReminderLogStatus.snoozed,
    );
    final slots = await plan();
    expect(slots.first.at, at);
    expect(slots.first.title, 'Calbo D');

    await repo.logAction(
      reminderId: b,
      scheduledFor: at,
      status: ReminderLogStatus.skipped,
    );
    expect((await plan()).first.at, DateTime(2026, 10, 5, 21));
  });

  test('a dose from earlier, not yet taken, is still shown first', () async {
    await daily('Metformin', 20, 1); // 20:00, now 20:30
    final slots = await plan();
    expect(slots.first.at, DateTime(2026, 10, 4, 20));
  });

  test(
    'stops at the horizon and the slot limit; JSON for the widgets',
    () async {
      for (var h = 0; h < 6; h++) {
        await daily('M$h', h, 1);
      }
      final slots = await plan();
      expect(slots, hasLength(HomeWidgetSync.maxSlots));
      expect(
        slots.every((s) => !s.at.isAfter(now.add(HomeWidgetSync.horizon))),
        isTrue,
      );

      final json =
          jsonDecode(HomeWidgetSync.encode(en, slots)) as Map<String, dynamic>;
      expect((json['labels'] as Map)['next'], en.widgetNext);
      final first = (json['slots'] as List).first as Map<String, dynamic>;
      expect(first['at'], slots.first.at.millisecondsSinceEpoch);
      expect(first['time'], '12:00 am');
      expect(first['title'], 'M0');
    },
  );

  test('no medicines: an empty list (the widget says so)', () async {
    expect(await plan(), isEmpty);
  });
}
