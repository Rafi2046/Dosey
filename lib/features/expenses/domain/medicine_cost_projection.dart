import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../reminders/domain/reminder_schedule.dart';

class MedicineCostLine {
  const MedicineCostLine({required this.medicine, required this.dosesPerDay});

  final Medicine medicine;
  final double dosesPerDay;

  double get _dailyExact =>
      medicine.unitPriceMinor * medicine.doseAmount * dosesPerDay;

  int get dailyMinor => _dailyExact.round();
  int get monthlyMinor => (_dailyExact * AppConstants.daysPerMonth).round();
}

/// Projected spend on the medicines the user is currently taking:
/// unit price × dose amount × doses per day (from enabled reminders).
class MedicineCostProjection {
  const MedicineCostProjection(this.lines);

  factory MedicineCostProjection.from({
    required List<Medicine> activeMedicines,
    required List<Reminder> reminders,
  }) {
    final dosesByMedicine = <int, double>{};
    for (final r in reminders) {
      final medicineId = r.medicineId;
      if (!r.isEnabled || medicineId == null) continue;
      dosesByMedicine[medicineId] =
          (dosesByMedicine[medicineId] ?? 0) +
          ReminderSchedule.dosesPerDay(
            r.repeatRule,
            repeatInterval: r.repeatInterval,
            weekdaysMask: r.weekdaysMask,
          );
    }
    return MedicineCostProjection(
      [
        for (final m in activeMedicines)
          MedicineCostLine(
            medicine: m,
            dosesPerDay: dosesByMedicine[m.id] ?? 0,
          ),
      ]..sort((a, b) => b.monthlyMinor.compareTo(a.monthlyMinor)),
    );
  }

  final List<MedicineCostLine> lines;

  int get dailyMinor => lines.fold(0, (sum, l) => sum + l.dailyMinor);
  int get monthlyMinor => lines.fold(0, (sum, l) => sum + l.monthlyMinor);
}
