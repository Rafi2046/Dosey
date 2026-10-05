import 'package:dosey/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addDoctor(String name) =>
      db.into(db.doctors).insert(DoctorsCompanion.insert(name: name));

  Future<int> addMedicine({int? doctorId}) => db
      .into(db.medicines)
      .insert(
        MedicinesCompanion.insert(
          name: 'Paracetamol',
          startDate: DateTime(2026, 10, 1),
          doctorId: Value(doctorId),
          unitPriceMinor: const Value(250),
        ),
      );

  test('supports many doctors with medicines linked to them', () async {
    final ids = [
      for (final n in ['A', 'B', 'C', 'D']) await addDoctor('Dr $n'),
    ];
    await addMedicine(doctorId: ids[1]);

    final query = db.select(db.medicines).join([
      innerJoin(db.doctors, db.doctors.id.equalsExp(db.medicines.doctorId)),
    ]);
    final row = (await query.get()).single;
    expect(row.readTable(db.doctors).name, 'Dr B');
  });

  test('deleting a doctor nulls medicine.doctorId', () async {
    final doc = await addDoctor('Dr A');
    final med = await addMedicine(doctorId: doc);
    await (db.delete(db.doctors)..where((d) => d.id.equals(doc))).go();

    final m = await (db.select(
      db.medicines,
    )..where((t) => t.id.equals(med))).getSingle();
    expect(m.doctorId, isNull);
  });

  test('deleting a medicine cascades to reminders and logs', () async {
    final med = await addMedicine();
    final rem = await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            type: ReminderType.medicine,
            title: 'Take Paracetamol',
            startAt: DateTime(2026, 10, 1, 8),
            medicineId: Value(med),
            repeatRule: const Value(RepeatRule.daily),
          ),
        );
    await db
        .into(db.reminderLogs)
        .insert(
          ReminderLogsCompanion.insert(
            reminderId: rem,
            scheduledFor: DateTime(2026, 10, 1, 8),
            status: ReminderLogStatus.taken,
          ),
        );

    await (db.delete(db.medicines)..where((t) => t.id.equals(med))).go();
    expect(await db.select(db.reminders).get(), isEmpty);
    expect(await db.select(db.reminderLogs).get(), isEmpty);
  });

  test('deleting a record cascades to its attachments', () async {
    final rec = await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            type: RecordType.prescription,
            title: 'Rx',
            recordDate: DateTime(2026, 10, 1),
          ),
        );
    await db
        .into(db.recordAttachments)
        .insert(
          RecordAttachmentsCompanion.insert(
            recordId: rec,
            relativePath: 'records/1/page1.jpg',
          ),
        );
    await (db.delete(db.records)..where((t) => t.id.equals(rec))).go();
    expect(await db.select(db.recordAttachments).get(), isEmpty);
  });

  test('CHECK constraints reject invalid rows', () async {
    // Medicine reminder without a medicine.
    await expectLater(
      db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.medicine,
              title: 'x',
              startAt: DateTime(2026),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    // Weekly reminder without weekdays.
    await expectLater(
      db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.vaccine,
              title: 'x',
              startAt: DateTime(2026),
              repeatRule: const Value(RepeatRule.weekly),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    // Every-N-days reminder without N.
    await expectLater(
      db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              type: ReminderType.medicalTest,
              title: 'x',
              startAt: DateTime(2026),
              repeatRule: const Value(RepeatRule.everyNDays),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    // Negative expense.
    await expectLater(
      db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              category: ExpenseCategory.medicine,
              title: 'x',
              amountMinor: -1,
              spentOn: DateTime(2026),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    // Dangling foreign key.
    await expectLater(
      addMedicine(doctorId: 999),
      throwsA(isA<SqliteException>()),
    );
  });

  test('cloud sync fields can be stored on medicines, reminders, and logs', () async {
    final medId = await db.into(db.medicines).insert(
      MedicinesCompanion.insert(
        name: 'Aspirin',
        startDate: DateTime(2026, 10, 1),
        cloudId: const Value('med-uuid-123'),
        firebaseUid: const Value('firebase-user-abc'),
        familyShareCode: const Value('FAM999'),
      ),
    );
    final med = await (db.select(db.medicines)..where((t) => t.id.equals(medId))).getSingle();
    expect(med.cloudId, 'med-uuid-123');
    expect(med.firebaseUid, 'firebase-user-abc');
    expect(med.familyShareCode, 'FAM999');
    expect(med.updatedAt, isNotNull);

    final remId = await db.into(db.reminders).insert(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Take Aspirin',
        startAt: DateTime(2026, 10, 1, 8),
        medicineId: Value(medId),
        cloudId: const Value('rem-uuid-456'),
        firebaseUid: const Value('firebase-user-abc'),
        familyShareCode: const Value('FAM999'),
      ),
    );
    final rem = await (db.select(db.reminders)..where((t) => t.id.equals(remId))).getSingle();
    expect(rem.cloudId, 'rem-uuid-456');
    expect(rem.firebaseUid, 'firebase-user-abc');
    expect(rem.familyShareCode, 'FAM999');
    expect(rem.updatedAt, isNotNull);

    final logNow = DateTime(2026, 10, 1, 8, 30);
    final logId = await db.into(db.reminderLogs).insert(
      ReminderLogsCompanion.insert(
        reminderId: remId,
        scheduledFor: DateTime(2026, 10, 1, 8),
        status: ReminderLogStatus.taken,
        cloudId: const Value('log-uuid-789'),
        firebaseUid: const Value('firebase-user-abc'),
        familyShareCode: const Value('FAM999'),
        updatedAt: Value(logNow),
      ),
    );
    final log = await (db.select(db.reminderLogs)..where((t) => t.id.equals(logId))).getSingle();
    expect(log.cloudId, 'log-uuid-789');
    expect(log.firebaseUid, 'firebase-user-abc');
    expect(log.familyShareCode, 'FAM999');
    expect(log.updatedAt, logNow);
  });
}

