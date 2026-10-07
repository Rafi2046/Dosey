import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import 'reminder_with_details.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/utils/dose_unit.dart';

/// Human-readable lines for a reminder, shared by notifications and UI.
abstract final class ReminderText {
  /// e.g. "2 tablet · After meal" (this reminder's amount) for medicines,
  /// "At Square Hospital" for appointments; falls back to the description.
  static String body(AppLocalizations l, ReminderWithDetails d) {
    final parts = <String>[];
    final medicine = d.medicine;
    if (medicine != null) {
      parts
        ..add(dose(l, d.reminder.doseAmount ?? 1, medicine.doseUnit))
        ..add(medicine.mealRelation.label(l));
    }
    final location = d.reminder.location;
    if (location != null && location.isNotEmpty) {
      parts.add('${l.notifAtLocation}$location');
    }
    final doctor = d.doctor;
    if (doctor != null && medicine == null) {
      parts.add('${l.notifWithDoctor}${doctor.name}');
    }
    final description = d.reminder.description;
    if (parts.isEmpty) return description ?? d.reminder.type.label(l);
    final summary = parts.join(l.notifDoseSeparator);
    return description == null || description.isEmpty
        ? summary
        : '$summary\n$description';
  }

  /// "2 tablets", "0.5 tablet", "5 ml" ([unit] as saved or as shown).
  static String dose(AppLocalizations l, double amount, String unit) =>
      DoseUnit.withAmount(amount, unit, l);

  /// Per-time amounts in time order: "2 + 1 + 2 tablets", or "1 tablet"
  /// when there's a single time.
  static String doseSummary(
    AppLocalizations l,
    List<Reminder> reminders,
    String unit,
  ) {
    final sorted = [...reminders]
      ..sort((a, b) {
        int minutes(Reminder r) => r.startAt.hour * 60 + r.startAt.minute;
        return minutes(a) - minutes(b);
      });
    if (sorted.isEmpty) return DoseUnit.display(unit, l);
    final amounts = [for (final r in sorted) r.doseAmount ?? 1];
    final total = amounts.fold<double>(0, (a, b) => a + b);
    return '${amounts.map(AppNumber.format).join(' + ')} '
        '${DoseUnit.display(unit, l, amount: total)}';
  }

  /// 1.0 → "1", 2.5 → "2.5", always Latin digits: for text-field values.
  /// Use [AppNumber.format] for display.
  static String formatAmount(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  /// "Daily · 08:00 am", "Mon, Wed · 08:00 am", "Every 3 days · …",
  /// "Mon, 5 Oct · 08:00 am" for one-off reminders.
  static String schedule(AppLocalizations l, Reminder r) {
    final time = AppDateFormat.time(r.startAt);
    final sep = l.notifDoseSeparator;
    return switch (r.repeatRule) {
      RepeatRule.once => AppDateFormat.dateTime(r.startAt),
      RepeatRule.daily => '${l.repeatDaily}$sep$time',
      RepeatRule.everyNDays =>
        '${l.everyNDays(r.repeatInterval ?? 1)}$sep$time',
      RepeatRule.weekly => '${weekdays(l, r.weekdaysMask ?? 0)}$sep$time',
    };
  }

  /// How often it rings, without the time: "Every day", "Mon, Wed",
  /// "Every 3 days", or the date for one-off reminders.
  static String frequency(AppLocalizations l, Reminder r) =>
      switch (r.repeatRule) {
        RepeatRule.once => AppDateFormat.shortDate(r.startAt),
        RepeatRule.daily => l.everyDay,
        RepeatRule.everyNDays => l.everyNDays(r.repeatInterval ?? 1),
        RepeatRule.weekly => weekdays(l, r.weekdaysMask ?? 0),
      };

  /// "Mon, Wed, Fri" — or "Every day" when all seven are set.
  static String weekdays(AppLocalizations l, int mask) {
    const all = 127;
    if (mask == all) return l.everyDay;
    return [
      for (var i = 0; i < l.weekdaysShort.length; i++)
        if (mask & (1 << i) != 0) l.weekdaysShort[i],
    ].join(', ');
  }

  /// Card overline such as "Evening Medicine" (from the design).
  static String slotLabel(AppLocalizations l, Reminder r, DateTime at) {
    final hour = at.hour;
    final slot = switch (hour) {
      >= 5 && < 12 => l.morning,
      >= 12 && < 17 => l.afternoon,
      >= 17 && < AppConstants.doseBedtimeHour => l.evening,
      _ => l.bedtime,
    };
    return '$slot ${r.type.label(l)}';
  }

  /// "45 min", "2 h 10 min" until [target] (clamped at zero).
  static String until(AppLocalizations l, DateTime target, DateTime now) {
    final minutes = target.difference(now).inMinutes.clamp(0, 1 << 30);
    return l.inHoursMinutes(minutes ~/ 60, minutes % 60);
  }
}
