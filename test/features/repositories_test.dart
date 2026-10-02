import 'dart:io';

import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/database/database_provider.dart';
import 'package:dosey/core/storage/storage_providers.dart';
import 'package:dosey/features/doctors/providers/doctors_providers.dart';
import 'package:dosey/features/expenses/providers/expenses_providers.dart';
import 'package:dosey/features/medicines/providers/medicines_providers.dart';
import 'package:dosey/features/records/providers/records_providers.dart';
import 'package:dosey/features/reminders/providers/reminders_providers.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dosey_test');
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
        documentsDirectoryProvider.overrideWithValue(tempDir),
      ],
    );
  });

  tearDown(() async {
    await container.read(appDatabaseProvider).close();
    container.dispose();
    tempDir.deleteSync(recursive: true);
  });

  Future<int> addMedicine({
    int? doctorId,
    double? stock,
    int unitPrice = 500,
    double dose = 1,
  }) => container
      .read(medicinesRepositoryProvider)
      .create(
        MedicinesCompanion.insert(
          name: 'Metformin',
          startDate: DateTime(2026, 1, 1),
          doctorId: Value(doctorId),
          stockQuantity: Value(stock),
          unitPriceMinor: Value(unitPrice),
          doseAmount: Value(dose),
        ),
      );

  Future<Reminder> addDailyReminder(int medicineId, {int hour = 8}) => container
      .read(remindersRepositoryProvider)
      .create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: 'Metformin',
          startAt: DateTime(2026, 1, 1, hour),
          medicineId: Value(medicineId),
          repeatRule: const Value(RepeatRule.daily),
        ),
        now: DateTime(2026, 10, 3, 12),
      );

  test('doctor stats count only active medicines', () async {
    final docs = container.read(doctorsRepositoryProvider);
    final a = await docs.create(DoctorsCompanion.insert(name: 'Dr A'));
    await docs.create(DoctorsCompanion.insert(name: 'Dr B'));
    await addMedicine(doctorId: a);
    final inactive = await addMedicine(doctorId: a);
    await container
        .read(medicinesRepositoryProvider)
        .setActive(inactive, active: false);

    final stats = await docs.watchWithStats().first;
    expect(
      {for (final s in stats) s.doctor.name: s.activeMedicineCount},
      {'Dr A': 1, 'Dr B': 0},
    );
  });

  test(
    'create computes nextTriggerAt; deactivating medicine disables it',
    () async {
      final med = await addMedicine();
      final r = await addDailyReminder(med);
      expect(r.nextTriggerAt, DateTime(2026, 10, 4, 8));

      await container
          .read(medicinesRepositoryProvider)
          .setActive(med, active: false);
      final after = await container
          .read(remindersRepositoryProvider)
          .getById(r.id);
      expect(after!.isEnabled, isFalse);
      expect(after.nextTriggerAt, isNull);
    },
  );

  test('logging taken deducts stock once; undo restores it', () async {
    final med = await addMedicine(stock: 10, dose: 2);
    final r = await addDailyReminder(med);
    final repo = container.read(remindersRepositoryProvider);
    final at = DateTime(2026, 10, 4, 8);

    Future<double?> stock() async =>
        (await container
                .read(medicinesRepositoryProvider)
                .watchById(med)
                .first)!
            .medicine
            .stockQuantity;

    await repo.logAction(
      reminderId: r.id,
      scheduledFor: at,
      status: ReminderLogStatus.taken,
    );
    await repo.logAction(
      reminderId: r.id,
      scheduledFor: at,
      status: ReminderLogStatus.taken,
    );
    expect(await stock(), 8);

    await repo.logAction(
      reminderId: r.id,
      scheduledFor: at,
      status: ReminderLogStatus.skipped,
    );
    expect(await stock(), 10);
  });

  test("today's schedule merges occurrences with logged status", () async {
    final med = await addMedicine();
    final morning = await addDailyReminder(med, hour: 8);
    await addDailyReminder(med, hour: 20);
    final now = DateTime.now();
    final today8 = DateTime(now.year, now.month, now.day, 8);
    await container
        .read(remindersRepositoryProvider)
        .logAction(
          reminderId: morning.id,
          scheduledFor: today8,
          status: ReminderLogStatus.taken,
        );

    final schedule = await _listenAndRead(container, todayScheduleProvider);
    expect(schedule.map((o) => o.at.hour), [8, 20]);
    expect(schedule.map((o) => o.status), [ReminderLogStatus.taken, null]);
  });

  test('medicine cost projection', () async {
    // ৳5 per tablet, 2 tablets per dose, twice daily → ৳20/day, ৳600/month.
    final med = await addMedicine(unitPrice: 500, dose: 2);
    await addDailyReminder(med, hour: 8);
    await addDailyReminder(med, hour: 20);

    final p = await _listenAndRead(container, medicineCostProjectionProvider);
    expect(p.dailyMinor, 2000);
    expect(p.monthlyMinor, 60000);
  });

  test('expense totals by month and category', () async {
    final repo = container.read(expensesRepositoryProvider);
    Future<void> add(ExpenseCategory c, int amount, DateTime on) => repo.create(
      ExpensesCompanion.insert(
        category: c,
        title: 'x',
        amountMinor: amount,
        spentOn: on,
      ),
    );
    await add(ExpenseCategory.medicine, 1000, DateTime(2026, 10, 1));
    await add(ExpenseCategory.medicine, 500, DateTime(2026, 10, 31, 23));
    await add(ExpenseCategory.test, 2000, DateTime(2026, 10, 15));
    await add(ExpenseCategory.test, 9999, DateTime(2026, 11, 1));

    final start = DateTime(2026, 10), end = DateTime(2026, 11);
    expect(await repo.watchTotal(start, end).first, 3500);
    expect(await repo.watchTotalsByCategory(start, end).first, {
      ExpenseCategory.medicine: 1500,
      ExpenseCategory.test: 2000,
    });
  });

  test('records: files copied on create, removed on delete', () async {
    final src = File('${tempDir.path}/picked.jpg')..writeAsBytesSync([1, 2, 3]);
    final repo = container.read(recordsRepositoryProvider);
    final id = await repo.create(
      RecordsCompanion.insert(
        type: RecordType.prescription,
        title: 'Rx',
        recordDate: DateTime(2026, 10, 1),
      ),
      [src.path, src.path],
    );

    final summary = (await repo.watchSummaries().first).single;
    expect(summary.pageCount, 2);
    final cover = container
        .read(fileStorageProvider)
        .resolve(summary.coverPath!);
    expect(cover.existsSync(), isTrue);

    await repo.delete(id);
    expect(cover.existsSync(), isFalse);
    expect(await repo.watchSummaries().first, isEmpty);
  });
}

/// Riverpod 3 pauses providers that have no listeners, so a bare
/// `read(p.future)` never resolves. Subscribe like a widget would.
Future<T> _listenAndRead<T>(
  ProviderContainer container,
  FutureProvider<T> provider,
) {
  container.listen(provider, (_, _) {});
  return container.read(provider.future);
}
