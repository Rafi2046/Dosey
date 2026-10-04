import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/medicines/data/medicine_schedule_service.dart';
import 'package:dosey/features/medicines/data/medicines_repository.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MedicinesRepository meds;
  late RemindersRepository reminders;
  late MedicineScheduleService schedule;
  final now = DateTime(2026, 10, 5, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    meds = MedicinesRepository(db);
    reminders = RemindersRepository(db);
    schedule = MedicineScheduleService(db, meds, reminders);
  });
  tearDown(() => db.close());

  /// Napa from 1 Oct, daily at 08:00 and 20:00.
  Future<(int, List<Reminder>)> napa() async {
    final id = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            startDate: DateTime(2026, 10, 1),
          ),
        );
    return (
      id,
      [
        for (final h in [8, 20])
          await reminders.create(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: 'Napa',
              startAt: DateTime(2026, 10, 1, h),
              medicineId: Value(id),
              repeatRule: const Value(RepeatRule.daily),
            ),
            now: now,
          ),
      ],
    );
  }

  test('resuming a stopped medicine brings its alarms back', () async {
    final (id, rs) = await napa();
    await meds.setActive(id, active: false, now: now);
    expect((await reminders.getById(rs.first.id))!.isEnabled, isFalse);

    await meds.setActive(id, active: true, now: now);
    final morning = (await reminders.getById(rs.first.id))!;
    final evening = (await reminders.getById(rs.last.id))!;
    expect(morning.isEnabled && evening.isEnabled, isTrue);
    expect(morning.nextTriggerAt, DateTime(2026, 10, 6, 8));
    expect(evening.nextTriggerAt, DateTime(2026, 10, 5, 20));
    // Doses due while stopped aren't counted as missed.
    expect(morning.updatedAt, now);
  });

  test(
    'renaming a medicine renames its reminders, schedule unchanged',
    () async {
      final (id, rs) = await napa();
      await schedule.syncSchedule(id, name: 'Napa Extra');
      for (final r in rs) {
        final after = (await reminders.getById(r.id))!;
        expect(after.title, 'Napa Extra');
        expect(after.startAt, r.startAt);
      }
    },
  );

  test('moving the start date moves each reminder, keeping its time', () async {
    final (id, rs) = await napa();
    await schedule.syncSchedule(id, startDate: DateTime(2026, 10, 12));
    expect(
      [for (final r in rs) (await reminders.getById(r.id))!.startAt],
      [DateTime(2026, 10, 12, 8), DateTime(2026, 10, 12, 20)],
    );
    // Not before the new start: the next alarm is on the 12th.
    final next = (await reminders.refreshNextTrigger(
      rs.first.id,
      now: now,
    )).nextTriggerAt;
    expect(next, DateTime(2026, 10, 12, 8));
  });

  test('a new end date applies to every reminder (inclusive)', () async {
    final (id, rs) = await napa();
    await schedule.syncSchedule(
      id,
      endDateChanged: true,
      endDate: DateTime(2026, 10, 7),
    );
    for (final r in rs) {
      expect(
        (await reminders.getById(r.id))!.endAt,
        DateTime(2026, 10, 7, 23, 59),
      );
    }
  });
}
