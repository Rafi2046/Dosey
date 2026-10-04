import 'package:dosey/core/constants/app_constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/notifications/reminder_alarm_engine.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show listEquals;
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
    await engine.syncAll();
    expect(scheduler.alarms[r.id]!.at, DateTime(2026, 10, 3, 8));
    expect(scheduler.alarms[r.id]!.critical, isTrue);

    await repo.setEnabled(r.id, enabled: false, now: now);
    await engine.syncAll();
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
      reminderIds: [r.id],
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
      reminderIds: [r.id],
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
    await engine.syncAll();
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
      reminderIds: [r.id],
      scheduledFor: DateTime(2026, 10, day, 8),
      action: AlarmAction.taken,
    );

    await take(3); // 8 → 6 tablets = 3 days: crosses into the window.
    expect(notifier.lowStock, [('Zulfidin', 3)]);
    await take(4); // 6 → 4: already low, no second notification.
    expect(notifier.lowStock, hasLength(1));
  });

  group('medicines due at the same minute', () {
    Future<(Reminder, Reminder)> addPair() async =>
        (await addDaily(hour: 23), await addDaily(hour: 23));
    final at = DateTime(2026, 10, 3, 23);

    test('share ONE OS alarm, filed under the lowest id', () async {
      final (a, b) = await addPair();
      await engine.syncAll();

      expect(scheduler.alarms.keys, [a.id]);
      final alarm = scheduler.alarms[a.id]!;
      expect(alarm.at, at);
      expect(ReminderAlarmEngine.idsFromParams(alarm.params), [a.id, b.id]);
    });

    test(
      'a different time or a non-medicine reminder rings on its own',
      () async {
        final (a, b) = await addPair();
        final other = await addDaily(hour: 8);
        final visit = await repo.create(
          RemindersCompanion.insert(
            type: ReminderType.appointment,
            title: 'Dr. Kamal',
            startAt: DateTime(2026, 10, 3, 23),
          ),
          now: now,
        );
        await engine.syncAll();
        expect(
          scheduler.alarms.keys,
          unorderedEquals([a.id, other.id, visit.id]),
        );
        expect(scheduler.alarms.containsKey(b.id), isFalse);

        // Moving one medicine off the shared time splits the group.
        await repo.update(
          b.id,
          RemindersCompanion(startAt: Value(DateTime(2026, 10, 1, 22))),
          now: now,
        );
        await engine.syncAll();
        expect(scheduler.alarms[b.id]!.at, DateTime(2026, 10, 3, 22));
        expect(
          ReminderAlarmEngine.idsFromParams(scheduler.alarms[a.id]!.params),
          [a.id],
        );
      },
    );

    test(
      'firing rings them all in one notification and arms tomorrow',
      () async {
        final (a, b) = await addPair();
        await engine.syncAll();
        now = at.add(const Duration(seconds: 2));

        await engine.onAlarmFired(a.id, scheduler.alarms[a.id]!.params);

        expect(notifier.posted, [
          [a.id, b.id],
        ]);
        for (final id in [a.id, b.id]) {
          final r = (await repo.getById(id))!;
          expect(r.ringingFor, at);
          expect(r.nextTriggerAt, at.add(const Duration(days: 1)));
        }
        // Still one alarm for the group, now for tomorrow.
        expect(scheduler.alarms.keys, [a.id]);
        expect(scheduler.alarms[a.id]!.at, at.add(const Duration(days: 1)));
      },
    );

    test('"Taken" logs every medicine and deducts each one\'s stock', () async {
      final (a, b) = await addPair();
      await engine.syncAll();
      now = at;
      await engine.onAlarmFired(a.id, scheduler.alarms[a.id]!.params);

      await engine.handleAction(
        reminderIds: [a.id, b.id],
        scheduledFor: at,
        action: AlarmAction.taken,
      );

      final logs = await db.select(db.reminderLogs).get();
      expect(
        {for (final l in logs) l.reminderId: l.status},
        {a.id: ReminderLogStatus.taken, b.id: ReminderLogStatus.taken},
      );
      expect(logs.map((l) => l.scheduledFor).toSet(), {at});
      for (final m in await db.select(db.medicines).get()) {
        expect(m.stockQuantity, 9, reason: m.name);
      }
      expect(notifier.showing, isEmpty);
      expect((await repo.getById(a.id))!.ringingFor, isNull);
      expect((await repo.getById(b.id))!.ringingFor, isNull);
    });

    test('snooze re-rings the group, minus anything taken meanwhile', () async {
      final (a, b) = await addPair();
      await engine.syncAll();
      now = at;
      await engine.onAlarmFired(a.id, scheduler.alarms[a.id]!.params);
      await engine.handleAction(
        reminderIds: [a.id, b.id],
        scheduledFor: at,
        action: AlarmAction.snooze,
      );
      final snoozeId = ReminderAlarmEngine.snoozeAlarmId(a.id);
      expect(scheduler.alarms.keys, containsAll([a.id, snoozeId]));
      expect(
        scheduler.alarms.containsKey(ReminderAlarmEngine.snoozeAlarmId(b.id)),
        isFalse,
      );

      // B taken from its Home card before the snooze ends.
      await engine.handleAction(
        reminderIds: [b.id],
        scheduledFor: at,
        action: AlarmAction.taken,
      );
      notifier.posted.clear();
      now = scheduler.alarms[snoozeId]!.at;
      await engine.onAlarmFired(snoozeId, scheduler.alarms[snoozeId]!.params);

      expect(notifier.posted, [
        [a.id],
      ]);
    });
  });

  group('iOS (book ahead, nothing runs at fire time)', () {
    late FakeBookAheadScheduler ios;
    setUp(() {
      ios = FakeBookAheadScheduler();
      engine = ReminderAlarmEngine(
        reminders: repo,
        scheduler: ios,
        notifier: notifier,
        clock: () => now,
      );
    });

    test('books every slot of the coming week, medicines grouped', () async {
      final a = await addDaily(hour: 23);
      final b = await addDaily(hour: 23);
      final morning = await addDaily(hour: 8);
      final visit = await repo.create(
        RemindersCompanion.insert(
          type: ReminderType.appointment,
          title: 'Dr. Kamal',
          startAt: DateTime(2026, 10, 4, 23),
        ),
        now: now,
      );
      await engine.syncAll();

      // No per-reminder OS alarms on iOS: only notifications booked ahead.
      expect(ios.alarms, isEmpty);
      final night = ios.bookings.where(
        (x) => x.at.hour == 23 && x.reminderIds.length == 2,
      );
      expect(night, hasLength(7)); // 3 Oct … 9 Oct, 7 days ahead of 07:00
      expect(night.first.reminderIds, [a.id, b.id]);
      expect(
        night.first.id,
        ReminderAlarmEngine.slotNotificationId(DateTime(2026, 10, 3, 23)),
      );
      expect(
        ios.bookings.where((x) => listEquals(x.reminderIds, [morning.id])),
        hasLength(7),
      );
      // The appointment: its own notification, under its reminder id.
      expect(
        ios.bookings.where((x) => x.id == visit.id).single.at,
        DateTime(2026, 10, 4, 23),
      );
      // Soonest first, and every id distinct.
      expect(ios.bookings.first.at, DateTime(2026, 10, 3, 8));
      expect(
        ios.bookings.map((x) => x.id).toSet(),
        hasLength(ios.bookings.length),
      );
    });

    test('never books more than iOS can hold', () async {
      for (var h = 0; h < 12; h++) {
        await addDaily(hour: h);
      }
      await engine.syncAll();
      expect(ios.bookings, hasLength(AppConstants.bookAheadLimit));
    });

    test(
      'tapping the notification opens the alarm for doses still due',
      () async {
        final a = await addDaily(hour: 23);
        final b = await addDaily(hour: 23);
        final at = DateTime(2026, 10, 3, 23);
        now = at.add(const Duration(minutes: 3));
        // B was already taken from its Home card.
        await engine.handleAction(
          reminderIds: [b.id],
          scheduledFor: at,
          action: AlarmAction.taken,
        );

        await engine.ringFromNotification([a.id, b.id], at);
        expect((await repo.getById(a.id))!.ringingFor, at);
        expect((await repo.getById(b.id))!.ringingFor, isNull);

        // A day-old notification doesn't start ringing.
        await repo.setRinging(a.id, null);
        now = at.add(const Duration(days: 1));
        await engine.ringFromNotification([a.id], at);
        expect((await repo.getById(a.id))!.ringingFor, isNull);
      },
    );

    test('acting on a slot notification removes that notification', () async {
      final a = await addDaily(hour: 23);
      final at = DateTime(2026, 10, 3, 23);
      final slotId = ReminderAlarmEngine.slotNotificationId(at);
      notifier.showing[slotId] = at;
      await engine.handleAction(
        reminderIds: [a.id],
        scheduledFor: at,
        action: AlarmAction.taken,
        notificationId: slotId,
      );
      expect(notifier.showing.containsKey(slotId), isFalse);
    });
  });

  group('missed doses', () {
    /// Daily 08:00 dose, last edited at [editedAt] (inferred misses start
    /// there).
    Future<Reminder> addEdited(DateTime editedAt) async {
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: 'Napa',
              startDate: DateTime(2026),
              stockQuantity: const Value(10),
            ),
          );
      return repo.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: 'Napa',
          startAt: DateTime(2026, 10, 1, 8),
          medicineId: Value(med),
          repeatRule: const Value(RepeatRule.daily),
          updatedAt: Value(editedAt),
        ),
        now: now,
      );
    }

    Future<Map<DateTime, ReminderLogStatus>> logged() async => {
      for (final l in await db.select(db.reminderLogs).get())
        l.scheduledFor: l.status,
    };

    test('the sweep logs doses left unanswered past the threshold', () async {
      final r = await addEdited(DateTime(2026, 10, 1));
      await repo.logAction(
        reminderId: r.id,
        scheduledFor: DateTime(2026, 10, 2, 8),
        status: ReminderLogStatus.taken,
      );
      // Today's 08:00 dose is 1.5 h old: still open, not missed yet.
      now = DateTime(2026, 10, 3, 9, 30);
      await engine.sweepMissed();
      expect(await logged(), {
        DateTime(2026, 10, 1, 8): ReminderLogStatus.missed,
        DateTime(2026, 10, 2, 8): ReminderLogStatus.taken,
      });

      now = DateTime(2026, 10, 3, 10, 1);
      await engine.sweepMissed();
      expect(
        (await logged())[DateTime(2026, 10, 3, 8)],
        ReminderLogStatus.missed,
      );
    });

    test('the sweep stops a dose that rang unanswered for too long', () async {
      final r = await addEdited(DateTime(2026, 10, 3));
      final at = DateTime(2026, 10, 3, 8);
      now = at;
      await engine.onAlarmFired(r.id, paramsFor(at));
      expect(notifier.showing[r.id], at);

      now = DateTime(2026, 10, 3, 11);
      await engine.resyncAll();

      expect((await logged())[at], ReminderLogStatus.missed);
      expect((await repo.getById(r.id))!.ringingFor, isNull);
      expect(notifier.showing, isEmpty);
    });

    test(
      'doses before a reminder was added or edited are not missed',
      () async {
        await addEdited(DateTime(2026, 10, 3, 9));
        now = DateTime(2026, 10, 3, 23);
        await engine.sweepMissed();
        expect(await logged(), isEmpty);
      },
    );

    test(
      'a snoozed dose still unanswered past the threshold is missed',
      () async {
        final r = await addEdited(DateTime(2026, 10, 3));
        final at = DateTime(2026, 10, 3, 8);
        // Snoozed at 08:00; rang again (and was ignored) at 08:10.
        await repo.logAction(
          reminderId: r.id,
          scheduledFor: at,
          status: ReminderLogStatus.snoozed,
          actedAt: DateTime(2026, 10, 3, 8, 10),
        );
        now = DateTime(2026, 10, 3, 12);
        await engine.sweepMissed();
        expect((await logged())[at], ReminderLogStatus.missed);
      },
    );

    test('dismissing an unanswered notification logs the dose as missed, '
        'but never overrides an answer', () async {
      final r = await addEdited(DateTime(2026, 10, 3));
      final at = DateTime(2026, 10, 3, 8);
      now = at;
      await engine.onAlarmFired(r.id, paramsFor(at));

      await engine.onDismissed([r.id], at);
      expect((await logged())[at], ReminderLogStatus.missed);
      expect((await repo.getById(r.id))!.ringingFor, isNull);

      final tomorrow = DateTime(2026, 10, 4, 8);
      await repo.logAction(
        reminderId: r.id,
        scheduledFor: tomorrow,
        status: ReminderLogStatus.taken,
      );
      await engine.onDismissed([r.id], tomorrow);
      expect((await logged())[tomorrow], ReminderLogStatus.taken);
    });

    test('taken late replaces the miss and deducts stock once', () async {
      final r = await addEdited(DateTime(2026, 10, 3));
      final at = DateTime(2026, 10, 3, 8);
      now = DateTime(2026, 10, 3, 12);
      await engine.sweepMissed();

      for (var i = 0; i < 2; i++) {
        await engine.handleAction(
          reminderIds: [r.id],
          scheduledFor: at,
          action: AlarmAction.takenLate,
        );
      }
      expect((await logged())[at], ReminderLogStatus.takenLate);
      expect((await db.select(db.medicines).getSingle()).stockQuantity, 9);

      // A later sweep leaves the answered dose alone.
      await engine.sweepMissed();
      expect((await logged())[at], ReminderLogStatus.takenLate);
    });

    test('"remind me in 2 h" rings then, and is only missed 2 h after '
        'that', () async {
      final r = await addEdited(DateTime(2026, 10, 3));
      final at = DateTime(2026, 10, 3, 8);
      now = DateTime(2026, 10, 3, 8, 5);
      await engine.onAlarmFired(r.id, paramsFor(at));
      await engine.handleAction(
        reminderIds: [r.id],
        scheduledFor: at,
        action: AlarmAction.snooze,
        snoozeFor: const Duration(hours: 2),
      );
      final snoozeId = ReminderAlarmEngine.snoozeAlarmId(r.id);
      expect(scheduler.alarms[snoozeId]!.at, DateTime(2026, 10, 3, 10, 5));

      // 10:01: past 2 h since 08:00, but the reminder hasn't rung yet.
      now = DateTime(2026, 10, 3, 10, 1);
      await engine.sweepMissed();
      expect((await logged())[at], ReminderLogStatus.snoozed);

      // 10:05: the snooze rings (not swallowed as a late alarm).
      now = DateTime(2026, 10, 3, 10, 5);
      await engine.onAlarmFired(snoozeId, scheduler.alarms[snoozeId]!.params);
      expect((await repo.getById(r.id))!.ringingFor, at);
      expect(notifier.showing[r.id], at);

      // Unanswered 2 h after it rang: missed, and it stops ringing.
      now = DateTime(2026, 10, 3, 12, 6);
      await engine.sweepMissed();
      expect((await logged())[at], ReminderLogStatus.missed);
      expect((await repo.getById(r.id))!.ringingFor, isNull);
    });

    test('skipped, then taken after all: taken late, stock deducted', () async {
      final r = await addEdited(DateTime(2026, 10, 3));
      final at = DateTime(2026, 10, 3, 8);
      now = at;
      await engine.handleAction(
        reminderIds: [r.id],
        scheduledFor: at,
        action: AlarmAction.skip,
      );
      expect((await db.select(db.medicines).getSingle()).stockQuantity, 10);

      now = DateTime(2026, 10, 3, 13);
      await engine.handleAction(
        reminderIds: [r.id],
        scheduledFor: at,
        action: AlarmAction.takenLate,
      );
      expect((await logged())[at], ReminderLogStatus.takenLate);
      expect((await db.select(db.medicines).getSingle()).stockQuantity, 9);
    });
  });
}
