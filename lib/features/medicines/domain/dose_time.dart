import 'package:flutter/material.dart' show TimeOfDay;

/// One intake: a time of day and how many units to take then
/// (2 tablets at 08:00, 1 at 14:00…). Becomes one daily reminder.
class DoseTime {
  const DoseTime(this.time, [this.amount = 1]);

  final TimeOfDay time;
  final double amount;

  int get minutes => time.hour * 60 + time.minute;

  DoseTime copyWith({TimeOfDay? time, double? amount}) =>
      DoseTime(time ?? this.time, amount ?? this.amount);

  static List<DoseTime> sorted(Iterable<DoseTime> doses) =>
      doses.toList()..sort((a, b) => a.minutes - b.minutes);
}
