import 'package:dosey/core/constants/app_constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/reminder_alarm_engine.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository repo;
  late FakeAlarmScheduler scheduler;
  late FakeNotificationPresenter notifier;
  late DateTime now;
  late ReminderAlarmEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RemindersRepository(db);
    scheduler = FakeAlarmScheduler();
    notifier = FakeNotificationPresenter();
    now = DateTime(2026, 10, 3, 7, 0);
    engine = ReminderAlarmEngine(
      reminders: repo,
      scheduler: scheduler,
      notifier: notifier,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<Reminder> addDaily({int hour = 8, bool critical = true}) async {
    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Insulin',
            startDate: DateTime(2026),
            stockQuantity: const Value(10),
          ),
        );
    return repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Insulin',
        startAt: DateTime(2026, 10, 1, hour),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        isCritical: Value(critical),
      ),
      now: now,
    );
  }

  Map<String, dynamic> paramsFor(DateTime at) => {
    AppConstants.alarmParamScheduledFor: at.toIso8601String(),
  };

  test('sync arms enabled reminders and cancels disabled ones', () async {
    final r = await addDaily();
    await engine.sync(r);
    expect(scheduler.alarms[r.id]!.at, DateTime(2026, 10, 3, 8));
    expect(scheduler.alarms[r.id]!.critical, isTrue);

    await engine.sync(await repo.setEnabled(r.id, enabled: false, now: now));
    expect(scheduler.alarms, isEmpty);
  });

  test('firing rings, marks ringingFor and arms the next day', () async {
    final r = await addDaily();
    final at = DateTime(2026, 10, 3, 8);
    now = at.add(const Duration(seconds: 3));

    await engine.onAlarmFired(r.id, paramsFor(at));

    expect(notifier.showing[r.id], at);
    expect((await repo.getById(r.id))!.ringingFor, at);
    expect(scheduler.alarms[r.id]!.at, DateTime(2026, 10, 4, 8));
  });

  test('a very late alarm is logged as missed instead of ringing', () async {
    final r = await addDaily();
    final at = DateTime(2026, 10, 3, 8);
    now = at.add(AppConstants.missedThreshold + const Duration(minutes: 1));

    await engine.onAlarmFired(r.id, paramsFor(at));

    expect(notifier.showing, isEmpty);
    final logs = await db.select(db.reminderLogs).get();
    expect(logs.single.status, ReminderLogStatus.missed);
    expect(scheduler.alarms[r.id]!.at, DateTime(2026, 10, 4, 8));
  });

  test('taken logs, clears ringing, dismisses and deducts stock', () async {
    final r = await addDaily();
    final at = DateTime(2026, 10, 3, 8);
    now = at;
    await engine.onAlarmFired(r.id, paramsFor(at));

    await engine.handleAction(
      reminderId: r.id,
      scheduledFor: at,
      action: AlarmAction.taken,
    );

    expect(notifier.showing, isEmpty);
    expect((await repo.getById(r.id))!.ringingFor, isNull);
    final med = await db.select(db.medicines).getSingle();
    expect(med.stockQuantity, 9);
  });

  test('snooze arms a separate alarm that re-rings the same occurrence '
      'without advancing the series', () async {
    final r = await addDaily();
    final at = DateTime(2026, 10, 3, 8);
    now = at;
    await engine.onAlarmFired(r.id, paramsFor(at));
    await engine.handleAction(
      reminderId: r.id,
      scheduledFor: at,
      action: AlarmAction.snooze,
    );

    final snoozeId = ReminderAlarmEngine.snoozeAlarmId(r.id);
    final snooze = scheduler.alarms[snoozeId]!;
    expect(snooze.at, at.add(const Duration(minutes: 10)));

    now = snooze.at;
    await engine.onAlarmFired(snoozeId, snooze.params);
    expect(notifier.showing[r.id], at);
    expect((await repo.getById(r.id))!.nextTriggerAt, DateTime(2026, 10, 4, 8));
  });

  test('resync recomputes stale triggers (e.g. after reboot)', () async {
    final r = await addDaily();
    scheduler.alarms.clear(); // reboot wiped all OS alarms
    now = DateTime(2026, 10, 5, 9); // device was off for two days

    await engine.onAlarmFired(AppConstants.resyncAlarmId, const {});

    expect(scheduler.alarms[r.id]!.at, DateTime(2026, 10, 6, 8));
    expect(notifier.showing, isEmpty);
  });

  test('non-critical reminders schedule non-alarm-clock alarms', () async {
    final r = await addDaily(critical: false);
    await engine.sync(r);
    expect(scheduler.alarms[r.id]!.critical, isFalse);
  });

  test('warns once when a dose brings stock into the refill window', () async {
    // 2 tablets a day, alert 3 days before: 8 tablets = 4 days (fine).
    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Zulfidin',
            startDate: DateTime(2026),
            stockQuantity: const Value(8),
            refillAlertDays: const Value(3),
          ),
        );
    final r = await repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Zulfidin',
        startAt: DateTime(2026, 10, 1, 8),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        doseAmount: const Value(2),
      ),
      now: now,
    );
    Future<void> take(int day) => engine.handleAction(
      reminderId: r.id,
      scheduledFor: DateTime(2026, 10, day, 8),
      action: AlarmAction.taken,
    );

    await take(3); // 8 → 6 tablets = 3 days: crosses into the window.
    expect(notifier.lowStock, [('Zulfidin', 3)]);
    await take(4); // 6 → 4: already low, no second notification.
    expect(notifier.lowStock, hasLength(1));
  });
}
