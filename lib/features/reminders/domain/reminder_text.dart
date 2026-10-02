import '../../../core/constants/app_strings.dart';
import '../../../core/utils/enum_labels.dart';
import 'reminder_with_details.dart';

/// Human-readable lines for a reminder, shared by notifications and UI.
abstract final class ReminderText {
  /// e.g. "2 tablet · After meal" for medicines, "At Square Hospital" for
  /// appointments; falls back to the description.
  static String body(ReminderWithDetails d) {
    final parts = <String>[];
    final medicine = d.medicine;
    if (medicine != null) {
      parts
        ..add('${formatAmount(medicine.doseAmount)} ${medicine.doseUnit}')
        ..add(medicine.mealRelation.label);
    }
    final location = d.reminder.location;
    if (location != null && location.isNotEmpty) {
      parts.add('${AppStrings.notifAtLocation}$location');
    }
    final doctor = d.doctor;
    if (doctor != null && medicine == null) {
      parts.add('${AppStrings.notifWithDoctor}${doctor.name}');
    }
    final description = d.reminder.description;
    if (parts.isEmpty) return description ?? d.reminder.type.label;
    final summary = parts.join(AppStrings.notifDoseSeparator);
    return description == null || description.isEmpty
        ? summary
        : '$summary\n$description';
  }

  /// 1.0 → "1", 2.5 → "2.5"
  static String formatAmount(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
