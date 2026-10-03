import 'package:flutter/material.dart';

import '../../../core/database/enums.dart';

/// One medicine read off a prescription photo. Every field is a best guess
/// the user reviews on the form; null means "not found, keep the default".
class ScannedMedicine {
  const ScannedMedicine({
    required this.name,
    this.strength,
    this.form,
    this.doseAmount,
    this.times = const [],
    this.meal,
    this.durationDays,
    this.dosePattern,
  });

  final String name;
  final String? strength;
  final MedicineForm? form;
  final double? doseAmount;

  /// Sorted reminder times derived from the schedule (1+0+1, BD, night…).
  final List<TimeOfDay> times;
  final MealRelation? meal;
  final int? durationDays;

  /// The schedule as written (e.g. "1+0+1", "BD"), shown when choosing
  /// between several scanned medicines.
  final String? dosePattern;
}
