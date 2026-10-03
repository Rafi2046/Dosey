import 'package:dosey/features/doctors/domain/specialty.dart';
import 'package:dosey/features/medicines/domain/prescription_header_parser.dart';
import 'package:dosey/features/medicines/domain/scanned_doctor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a typical printed header', () {
    final d = PrescriptionHeaderParser.parse([
      'Dr. Farhana Rahman',
      'MBBS, FCPS (Medicine)',
      'Square Hospital, Dhaka | Phone: 01711-000000',
      'Patient: Karim Uddin Age: 45 Date: 03/10/2026',
      'Rx',
      '1. Tab. Napa Extra 500mg',
    ])!;
    expect(d.name, 'Dr. Farhana Rahman');
    expect(d.degrees, 'MBBS, FCPS (Medicine)');
    expect(d.specialty, Specialty.medicine);
    expect(d.phone, '01711000000');
    expect(d.clinic, 'Square Hospital, Dhaka');
  });

  test('name with degrees on one line, specialist title, +880 mobile', () {
    final d = PrescriptionHeaderParser.parse([
      'Prof. Dr. A.B.M. Abdullah MBBS, FRCP',
      'Child Specialist',
      'Chamber: Popular Diagnostic Centre, Dhanmondi',
      'Mobile: +880 1712-345678',
      'Rx',
    ])!;
    expect(d.name, 'Prof. Dr. A.B.M. Abdullah');
    expect(d.specialty, Specialty.paediatrics);
    expect(d.phone, '01712345678');
    expect(d.clinic, 'Popular Diagnostic Centre, Dhanmondi');
  });

  test('cardiology in brackets; medical college is not a specialty', () {
    final d = PrescriptionHeaderParser.parse([
      'Dr. Kamal Hossain',
      'MBBS, MD (Cardiology)',
      'Dhaka Medical College Hospital',
    ])!;
    expect(d.specialty, Specialty.cardiology);
    expect(d.clinic, 'Dhaka Medical College Hospital');
  });

  test('no doctor line → nothing', () {
    expect(
      PrescriptionHeaderParser.parse(['Rx', 'Tab. Napa 500mg 1+0+1']),
      isNull,
    );
  });

  test('saved-doctor matching ignores titles and punctuation', () {
    expect(
      ScannedDoctor.nameKey('Dr. Farhana Rahman'),
      ScannedDoctor.nameKey('farhana  rahman'),
    );
  });

  test('specialties: stored in English, matched in either language', () {
    expect(Specialty.toStored('শিশু রোগ'), Specialty.paediatrics.stored);
    expect(Specialty.toStored('Sports medicine doc'), 'Sports medicine doc');
    expect(
      Specialty.match('Diabetes & Hormone Specialist'),
      Specialty.endocrinology,
    );
    expect(Specialty.match('ENT Surgeon'), Specialty.ent);
    expect(Specialty.match('Gentle'), isNull); // "ent" must be a whole word
  });
}
