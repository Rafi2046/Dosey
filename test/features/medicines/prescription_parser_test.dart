import 'package:dosey/core/database/enums.dart';
import 'package:dosey/features/medicines/domain/prescription_parser.dart';
import 'package:dosey/features/medicines/domain/scanned_medicine.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> hours(ScannedMedicine m) => [for (final d in m.doses) d.time.hour];
List<double> amounts(ScannedMedicine m) => [for (final d in m.doses) d.amount];

void main() {
  test('reads a typical printed prescription', () {
    final meds = PrescriptionParser.parse([
      'Dr. Rahman MBBS, FCPS',
      'Patient: Karim   Age: 45   Date: 03/10/2026',
      'BP 120/80 mmHg',
      'Rx',
      '1. Tab. Napa Extra 500mg',
      '1+0+1 after meal x 7 days',
      '2. Cap. Seclo 20mg   1-0-0 before meal   1 month',
      '3) Syp. Ambrox 15mg/5ml  2 tsf TDS',
      '4. Tab. Montair 10',
      'at night',
      'Advice: drink plenty of water',
    ]);

    expect(
      [for (final m in meds) m.name],
      ['Napa Extra', 'Seclo', 'Ambrox', 'Montair'],
    );

    final napa = meds[0];
    expect(napa.form, MedicineForm.tablet);
    expect(napa.strength, '500mg');
    expect(hours(napa), [8, 21]);
    expect(amounts(napa), [1, 1]);
    expect(napa.meal, MealRelation.afterMeal);
    expect(napa.durationDays, 7);
    expect(napa.dosePattern, '1+0+1');

    final seclo = meds[1];
    expect(seclo.form, MedicineForm.capsule);
    expect(hours(seclo), [8]);
    expect(seclo.meal, MealRelation.beforeMeal);
    expect(seclo.durationDays, 30);

    final ambrox = meds[2];
    expect(ambrox.form, MedicineForm.syrup);
    expect(ambrox.strength, '15mg/5ml');
    expect(hours(ambrox), [8, 14, 21]);
    expect(amounts(ambrox), [10, 10, 10]); // "2 tsf" = 10 ml each time
    expect(ambrox.dosePattern, 'TDS');

    final montair = meds[3];
    expect(montair.strength, '10');
    expect(hours(montair), [21]);
  });

  test('four-slot, half-dose and dash patterns', () {
    final m = PrescriptionParser.parse(['Tab. Losectil ½+½+½+½']).single;
    expect(hours(m), [8, 14, 18, 21]);
    expect(amounts(m), [0.5, 0.5, 0.5, 0.5]);

    final d = PrescriptionParser.parse(['Tab Amdocal 5mg 0 - 0 - 1']).single;
    expect(hours(d), [21]);
  });

  test('different amounts at different times', () {
    final m = PrescriptionParser.parse(['Tab. Napa 500mg 2+1+2']).single;
    expect(hours(m), [8, 14, 21]);
    expect(amounts(m), [2, 1, 2]);

    final half = PrescriptionParser.parse(['Tab. Rivo 0.5mg ½+0+1']).single;
    expect(hours(half), [8, 21]);
    expect(amounts(half), [0.5, 1]);
  });

  test('Latin abbreviations and time words', () {
    List<int> h(String line) => hours(PrescriptionParser.parse([line]).single);

    expect(h('Tab. Fexo 120mg BD'), [8, 21]);
    expect(h('Tab. Fexo 120mg once daily at night'), [21]);
    expect(h('Tab. Fexo 120mg QID'), [8, 14, 18, 21]);
    expect(h('Tab. Fexo 120mg morning and night'), [8, 21]);
    expect(h('Tab. Fexo 120mg every 8 hours'), [0, 8, 16]);
    expect(h('Tab. Fexo 120mg 12 hourly'), [8, 20]);
  });

  test('accepts unprefixed "Name 500mg" lines, rejects lab values', () {
    final meds = PrescriptionParser.parse([
      'NAPA 500 mg 1+1+1 for 2 weeks',
      'Creatinine 1.2 mg/dl',
      'Weight 70 kg',
    ]);
    final napa = meds.single;
    expect(napa.name, 'Napa');
    expect(napa.form, isNull);
    expect(napa.strength, '500mg');
    expect(napa.durationDays, 14);
  });

  test('dates and phone numbers are not dose patterns', () {
    final m = PrescriptionParser.parse([
      'Tab. Rivotril 0.5mg',
      'Next visit 12-10-2026',
    ]).single;
    expect(m.doses, isEmpty);
  });

  test('duplicates collapse and nothing is invented', () {
    expect(PrescriptionParser.parse(['Hello world', 'Thank you']), isEmpty);
    expect(
      PrescriptionParser.parse(['Tab. Napa 500mg', 'Tab. NAPA 500mg']),
      hasLength(1),
    );
  });
}
