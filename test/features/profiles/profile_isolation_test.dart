import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/blood_pressure/data/blood_pressure_repository.dart';
import 'package:dosey/features/expenses/data/expenses_repository.dart';
import 'package:dosey/features/medicines/data/medicines_repository.dart';
import 'package:dosey/features/profiles/data/profiles_repository.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late int ammu;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ammu = await ProfilesRepository(db).create('Ammu', colorIndex: 1);
  });
  tearDown(() => db.close());

  test(
    "each profile sees only its own medicines; new ones are theirs",
    () async {
      final mine = MedicinesRepository(db, profileId: 1);
      final hers = MedicinesRepository(db, profileId: ammu);
      await mine.create(
        MedicinesCompanion.insert(name: 'Napa', startDate: DateTime(2026)),
      );
      await hers.create(
        MedicinesCompanion.insert(name: 'Seclo', startDate: DateTime(2026)),
      );
      Future<List<String>> names(MedicinesRepository r) async => [
        for (final m in await r.watchAll().first) m.medicine.name,
      ];
      expect(await names(mine), ['Napa']);
      expect(await names(hers), ['Seclo']);
      expect(await names(MedicinesRepository(db)), ['Napa', 'Seclo']);
    },
  );

  test('alarms see every profile; screens only the open one', () async {
    final hers = RemindersRepository(db, profileId: ammu);
    final med = await MedicinesRepository(db, profileId: ammu).create(
      MedicinesCompanion.insert(name: 'Seclo', startDate: DateTime(2026)),
    );
    final r = await hers.create(
      RemindersCompanion.insert(
        type: ReminderType.medicine,
        title: 'Seclo',
        startAt: DateTime(2026, 10, 1, 8),
        medicineId: Value(med),
        repeatRule: const Value(RepeatRule.daily),
      ),
      now: DateTime(2026, 10, 3),
    );
    expect(r.profileId, ammu);
    expect(
      await RemindersRepository(db, profileId: 1).getEnabledDetails(),
      isEmpty,
    );
    final all = await RemindersRepository(db).getDetails(r.id);
    expect(all!.profile!.name, 'Ammu');
    expect(await RemindersRepository(db).getAll(), hasLength(1));
  });

  test('readings and expenses are per profile too', () async {
    await BloodPressureRepository(db, profileId: ammu).create(
      BloodPressureReadingsCompanion.insert(
        systolic: 140,
        diastolic: 90,
        measuredAt: DateTime(2026, 10, 3),
      ),
    );
    expect(
      await BloodPressureRepository(db, profileId: 1).watchAll().first,
      isEmpty,
    );
    expect(
      await BloodPressureRepository(db, profileId: ammu).watchAll().first,
      hasLength(1),
    );
    await ExpensesRepository(db, profileId: ammu).create(
      ExpensesCompanion.insert(
        category: ExpenseCategory.medicine,
        title: 'Seclo',
        amountMinor: 500,
        spentOn: DateTime(2026, 10, 3),
      ),
    );
    final range = (DateTime(2026, 10), DateTime(2026, 11));
    expect(
      await ExpensesRepository(
        db,
        profileId: 1,
      ).watchTotal(range.$1, range.$2).first,
      0,
    );
    expect(
      await ExpensesRepository(
        db,
        profileId: ammu,
      ).watchTotal(range.$1, range.$2).first,
      500,
    );
  });

  test("the user's own profile can't be deleted", () async {
    await ProfilesRepository(db).delete(ProfilesRepository.mainProfileId);
    expect(await db.select(db.profiles).get(), hasLength(2));
  });
}
