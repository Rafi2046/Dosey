import '../../../core/database/enums.dart';
import 'dose_time.dart';

/// One medicine read off a prescription photo. Every field is a best guess
/// the user reviews on the form; null means "not found, keep the default".
class ScannedMedicine {
  const ScannedMedicine({
    required this.name,
    this.strength,
    this.form,
    this.doses = const [],
    this.meal,
    this.durationDays,
    this.dosePattern,
  });

  final String name;
  final String? strength;
  final MedicineForm? form;

  /// Intake times with their amounts, from the schedule: "2+1+2" →
  /// 2 at 08:00, 1 at 14:00, 2 at 21:00; "2 tsf TDS" → 2 at each of 3 times.
  final List<DoseTime> doses;
  final MealRelation? meal;
  final int? durationDays;

  /// The schedule as written (e.g. "1+0+1", "BD"), shown when choosing
  /// between several scanned medicines.
  final String? dosePattern;
}
