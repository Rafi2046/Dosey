import '../../../core/database/app_database.dart';
import '../../reminders/domain/reminder_schedule.dart';

/// Units (tablets, ml…) each medicine uses per day, across its enabled
/// reminders, each with its own amount: 2 at 08:00 + 1 at 14:00 = 3.
Map<int, double> unitsPerDayByMedicine(Iterable<Reminder> reminders) {
  final units = <int, double>{};
  for (final r in reminders) {
    final medicineId = r.medicineId;
    if (!r.isEnabled || medicineId == null) continue;
    units[medicineId] =
        (units[medicineId] ?? 0) +
        (r.doseAmount ?? 1) *
            ReminderSchedule.dosesPerDay(
              r.repeatRule,
              repeatInterval: r.repeatInterval,
              weekdaysMask: r.weekdaysMask,
            );
  }
  return units;
}

/// How long a medicine's stock lasts at its current dose, and whether it's
/// time to buy more.
class StockStatus {
  const StockStatus(this.medicine, this.unitsPerDay);

  final Medicine medicine;

  /// From [unitsPerDayByMedicine]; 0 when it has no active reminders.
  final double unitsPerDay;

  double? get stock => medicine.stockQuantity;

  /// Whole days of medicine left (null when stock isn't tracked or nothing
  /// is scheduled, so it can't run out).
  int? get daysLeft {
    final stock = this.stock;
    if (stock == null || unitsPerDay <= 0) return null;
    return (stock / unitsPerDay).floor();
  }

  /// Within the alert window: [Medicine.refillAlertDays] before running out,
  /// or (medicines saved before v4) at/below [Medicine.refillThreshold].
  bool get isLow {
    final stock = this.stock;
    if (stock == null) return false;
    final alertDays = medicine.refillAlertDays;
    if (alertDays != null) {
      final days = daysLeft;
      return days != null && days <= alertDays;
    }
    final threshold = medicine.refillThreshold;
    return threshold != null && stock <= threshold;
  }
}
