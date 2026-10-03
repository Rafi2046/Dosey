import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../medicines/domain/stock_status.dart';

class MedicineCostLine {
  const MedicineCostLine({required this.medicine, required this.unitsPerDay});

  final Medicine medicine;

  /// Tablets / ml / puffs taken per day across all of its reminders.
  final double unitsPerDay;

  double get _dailyExact => medicine.unitPriceMinor * unitsPerDay;

  int get dailyMinor => _dailyExact.round();
  int get monthlyMinor => (_dailyExact * AppConstants.daysPerMonth).round();
}

/// Projected spend on the medicines the user is currently taking:
/// unit price × units per day, summed over enabled reminders (each with its
/// own dose amount).
class MedicineCostProjection {
  const MedicineCostProjection(this.lines);

  factory MedicineCostProjection.from({
    required List<Medicine> activeMedicines,
    required List<Reminder> reminders,
  }) {
    final unitsByMedicine = unitsPerDayByMedicine(reminders);
    return MedicineCostProjection(
      [
        for (final m in activeMedicines)
          MedicineCostLine(
            medicine: m,
            unitsPerDay: unitsByMedicine[m.id] ?? 0,
          ),
      ]..sort((a, b) => b.monthlyMinor.compareTo(a.monthlyMinor)),
    );
  }

  final List<MedicineCostLine> lines;

  int get dailyMinor => lines.fold(0, (sum, l) => sum + l.dailyMinor);
  int get monthlyMinor => lines.fold(0, (sum, l) => sum + l.monthlyMinor);
}
