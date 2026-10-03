import '../../doctors/domain/specialty.dart';
import 'scanned_medicine.dart';

/// The doctor printed at the top of a prescription. Every field is a best
/// guess for the user to check.
class ScannedDoctor {
  const ScannedDoctor({
    required this.name,
    this.degrees,
    this.specialty,
    this.phone,
    this.clinic,
  });

  /// As printed, e.g. "Dr. Farhana Rahman".
  final String name;

  /// "MBBS, FCPS (Medicine)".
  final String? degrees;
  final Specialty? specialty;

  /// Digits only, e.g. "01711000000".
  final String? phone;

  /// Chamber / hospital line, e.g. "Square Hospital, Dhaka".
  final String? clinic;

  /// For matching against saved doctors: no title, punctuation or case.
  static String nameKey(String name) => name
      .toLowerCase()
      .replaceAll(
        RegExp(r'^(dr|prof|professor|assoc|asst|ডা|ডাঃ)\.?\s*', unicode: true),
        '',
      )
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();
}

/// Everything read off one prescription photo.
class ScannedPrescription {
  const ScannedPrescription({this.doctor, this.medicines = const []});

  final ScannedDoctor? doctor;
  final List<ScannedMedicine> medicines;
}
