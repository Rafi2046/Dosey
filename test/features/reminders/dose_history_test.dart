import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:dosey/features/reminders/domain/dose_history.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository repo;
  final now = DateTime(2026, 10, 3, 12);
  final from = DateTime(2026, 9, 27);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RemindersRepository(db);
  });
  tearDown(() => db.close());

  /// A daily dose at [hour] since 1 Oct, set up then (so 1 Oct onwards can
  /// count as missed).
  Future<Reminder> daily(String name, int hour) async {
    final med = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: name,
            startDate: DateTime(2026, 10, 1),
          ),
        );
    return repo.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: name,
        startAt: DateTime(2026, 10, 1, hour),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
        updatedAt: Value(DateTime(2026, 10, 1)),
      ),
      now: now,
    );
  }

  Future<void> log(Reminder r, DateTime at, ReminderLogStatus s) =>
      repo.logAction(reminderId: r.id, scheduledFor: at, status: s);

  Future<DoseHistory> history({int? medicineId}) async => DoseHistory.build(
    await repo.watchAll().first,
    await repo.logsBetween(from, now),
    from: from,
    now: now,
    medicineId: medicineId,
  );

  test('logged outcomes plus unanswered doses as missed, newest first, '
      'without doses still open', () async {
    final napa = await daily('Napa', 8);
    await log(napa, DateTime(2026, 10, 1, 8), ReminderLogStatus.taken);
    await log(napa, DateTime(2026, 10, 2, 8), ReminderLogStatus.skipped);
    // 3 Oct 08:00 never answered (4 h ago): missed.
    final seclo = await daily('Seclo', 11);
    // 3 Oct 11:00 is 1 h old and snoozed: still open, not history yet.
    await log(seclo, DateTime(2026, 10, 3, 11), ReminderLogStatus.snoozed);
    await log(seclo, DateTime(2026, 10, 2, 11), ReminderLogStatus.takenLate);
    // 1 Oct 11:00 never answered: missed.

    final h = await history();
    expect(
      [for (final e in h.entries) (e.details.reminder.title, e.at, e.status)],
      [
        ('Napa', DateTime(2026, 10, 3, 8), ReminderLogStatus.missed),
        ('Seclo', DateTime(2026, 10, 2, 11), ReminderLogStatus.takenLate),
        ('Napa', DateTime(2026, 10, 2, 8), ReminderLogStatus.skipped),
        ('Seclo', DateTime(2026, 10, 1, 11), ReminderLogStatus.missed),
        ('Napa', DateTime(2026, 10, 1, 8), ReminderLogStatus.taken),
      ],
    );
    // Taken + taken late out of everything with an outcome.
    expect(h.adherence, 2 / 5);
    expect(h.count(ReminderLogStatus.missed), 2);
  });

  test('filters to one medicine', () async {
    final napa = await daily('Napa', 8);
    await daily('Seclo', 9);
    final h = await history(medicineId: napa.medicineId);
    expect(h.entries.map((e) => e.details.reminder.title).toSet(), {'Napa'});
    expect(h.entries, hasLength(3));
  });

  test('no doses: empty, no adherence', () async {
    final h = await history();
    expect(h.entries, isEmpty);
    expect(h.adherence, isNull);
  });
}
