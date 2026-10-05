import 'dart:convert';
import 'dart:io';

import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/medicines/data/medicine_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rows =
      (jsonDecode(File('assets/data/bd_medicines.json').readAsStringSync())
              as Map<String, dynamic>)['medicines']
          as List<dynamic>;
  final index = MedicineNameIndex([
    for (final r in rows)
      MedicineName(
        name: r[0] as String,
        generic: r[1] as String,
        strength: r[2] as String,
        form: MedicineForm.values.asNameMap()[r[3] as String],
      ),
  ]);

  test('every built-in entry is complete, unique and has a known form', () {
    final names = <String>{};
    for (final r in rows) {
      expect(
        (r[0] as String).isNotEmpty && (r[1] as String).isNotEmpty,
        isTrue,
      );
      expect(MedicineForm.values.asNameMap()[r[3]], isNotNull, reason: '$r');
      expect(names.add((r[0] as String).toLowerCase()), isTrue, reason: '$r');
    }
  });

  test('finds by brand, best match first', () {
    final found = index.search('nap');
    expect(found.first.name, 'Napa');
    expect(found.first.subtitle, 'Paracetamol · 500 mg');
    expect(
      found.map((n) => n.name),
      containsAll(['Napa Extra', 'Napa Extend']),
    );
  });

  test('finds by generic name too', () {
    expect(
      index.search('esomeprazole').map((n) => n.name),
      containsAll(['Sergel', 'Maxpro', 'Nexum']),
    );
    expect(index.search(''), isEmpty);
  });

  test("the user's own medicines come first and aren't repeated", () {
    final mine = index.withSaved([
      Medicine(
        profileId: 1,
        id: 1,
        name: 'napa',
        form: MedicineForm.syrup,
        doseUnit: 'ml',
        mealRelation: MealRelation.afterMeal,
        unitPriceMinor: 0,
        startDate: DateTime(2026),
        isActive: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ]);
    final found = mine.search('nap');
    expect(found.first.name, 'napa');
    expect(found.first.form, MedicineForm.syrup);
    expect(found.where((n) => n.name.toLowerCase() == 'napa'), hasLength(1));
  });
}
