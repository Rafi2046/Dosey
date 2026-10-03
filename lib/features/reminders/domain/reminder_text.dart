import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import 'reminder_with_details.dart';

/// Human-readable lines for a reminder, shared by notifications and UI.
abstract final class ReminderText {
  /// e.g. "2 tablet · After meal" (this reminder's amount) for medicines,
  /// "At Square Hospital" for appointments; falls back to the description.
  static String body(ReminderWithDetails d) {
    final parts = <String>[];
    final medicine = d.medicine;
    if (medicine != null) {
      parts
        ..add(dose(d.reminder.doseAmount ?? 1, medicine.doseUnit))
        ..add(medicine.mealRelation.label);
    }
    final location = d.reminder.location;
    if (location != null && location.isNotEmpty) {
      parts.add('${NotificationStrings.notifAtLocation}$location');
    }
    final doctor = d.doctor;
    if (doctor != null && medicine == null) {
      parts.add('${NotificationStrings.notifWithDoctor}${doctor.name}');
    }
    final description = d.reminder.description;
    if (parts.isEmpty) return description ?? d.reminder.type.label;
    final summary = parts.join(NotificationStrings.notifDoseSeparator);
    return description == null || description.isEmpty
        ? summary
        : '$summary\n$description';
  }

  /// "2 tablet", "0.5 tablet", "5 ml".
  static String dose(double amount, String unit) =>
      '${formatAmount(amount)} $unit';

  /// Per-time amounts in time order: "2 + 1 + 2 tablet", or "1 tablet" when
  /// there's a single time.
  static String doseSummary(List<Reminder> reminders, String unit) {
    final sorted = [...reminders]
      ..sort((a, b) {
        int minutes(Reminder r) => r.startAt.hour * 60 + r.startAt.minute;
        return minutes(a) - minutes(b);
      });
    if (sorted.isEmpty) return unit;
    final amounts = [for (final r in sorted) formatAmount(r.doseAmount ?? 1)];
    return '${amounts.join(' + ')} $unit';
  }

  /// 1.0 → "1", 2.5 → "2.5"
  static String formatAmount(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  /// "Daily · 08:00 am", "Mon, Wed · 08:00 am", "Every 3 days · …",
  /// "Mon, 5 Oct · 08:00 am" for one-off reminders.
  static String schedule(Reminder r) {
    final time = AppDateFormat.time(r.startAt);
    final sep = NotificationStrings.notifDoseSeparator;
    return switch (r.repeatRule) {
      RepeatRule.once => AppDateFormat.dateTime(r.startAt),
      RepeatRule.daily => '${ReminderStrings.repeatDaily}$sep$time',
      RepeatRule.everyNDays =>
        '${ReminderStrings.everyNDays(r.repeatInterval ?? 1)}$sep$time',
      RepeatRule.weekly => '${weekdays(r.weekdaysMask ?? 0)}$sep$time',
    };
  }

  /// How often it rings, without the time: "Every day", "Mon, Wed",
  /// "Every 3 days", or the date for one-off reminders.
  static String frequency(Reminder r) => switch (r.repeatRule) {
    RepeatRule.once => AppDateFormat.shortDate(r.startAt),
    RepeatRule.daily => MedicineStrings.everyDay,
    RepeatRule.everyNDays => ReminderStrings.everyNDays(r.repeatInterval ?? 1),
    RepeatRule.weekly => weekdays(r.weekdaysMask ?? 0),
  };

  /// "Mon, Wed, Fri" — or "Every day" when all seven are set.
  static String weekdays(int mask) {
    const all = 127;
    if (mask == all) return MedicineStrings.everyDay;
    return [
      for (var i = 0; i < ReminderStrings.weekdaysShort.length; i++)
        if (mask & (1 << i) != 0) ReminderStrings.weekdaysShort[i],
    ].join(', ');
  }

  /// Card overline such as "Evening Medicine" (from the design).
  static String slotLabel(Reminder r, DateTime at) {
    final hour = at.hour;
    final slot = switch (hour) {
      >= 5 && < 12 => DashboardStrings.morning,
      >= 12 && < 17 => DashboardStrings.afternoon,
      >= 17 && < 21 => DashboardStrings.evening,
      _ => DashboardStrings.bedtime,
    };
    return '$slot ${r.type.label}';
  }

  /// "45 min", "2 h 10 min" until [target] (clamped at zero).
  static String until(DateTime target, DateTime now) {
    final minutes = target.difference(now).inMinutes.clamp(0, 1 << 30);
    return DashboardStrings.inHoursMinutes(minutes ~/ 60, minutes % 60);
  }
}
