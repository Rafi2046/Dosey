import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../data/medicine_schedule_service.dart';
import '../../domain/dose_time.dart';
import '../../domain/scanned_medicine.dart';
import '../../../../core/localization/l10n.dart';

/// One editable medicine on the bulk-add review screen. Owns its text
/// controllers; call [dispose] when it's removed or the screen closes.
class MedicineDraft {
  /// [l10n] supplies default units ("tablet" / "ট্যাবলেট").
  MedicineDraft(
    this._l10n, {
    String name = '',
    String? strength,
    this.form = MedicineForm.tablet,
    this.doses = const [],
    this.meal = MealRelation.afterMeal,
    this.endDate,
    this.dosePattern,
  }) : name = TextEditingController(text: name),
       strength = TextEditingController(text: strength),
       unit = TextEditingController(text: form.defaultUnit(_l10n));

  /// An N-day course starting [start] ends on its Nth day.
  factory MedicineDraft.fromScan(
    AppLocalizations l10n,
    ScannedMedicine s,
    DateTime start,
  ) => MedicineDraft(
    l10n,
    name: s.name,
    strength: s.strength,
    form: s.form ?? MedicineForm.tablet,
    doses: s.doses,
    meal: s.meal ?? MealRelation.afterMeal,
    endDate: switch (s.durationDays) {
      final d? => DateUtils.dateOnly(start).add(Duration(days: d - 1)),
      null => null,
    },
    dosePattern: s.dosePattern,
  );

  /// Stable identity for list keys while drafts are added/removed.
  final Key key = UniqueKey();

  final AppLocalizations _l10n;

  final TextEditingController name;
  final TextEditingController strength;
  final TextEditingController unit;
  MedicineForm form;
  List<DoseTime> doses;
  MealRelation meal;
  DateTime? endDate;

  /// The schedule as written on the prescription ("1+0+1", "TDS"), shown so
  /// the user can compare it with the times read from it.
  final String? dosePattern;

  /// Has what the database requires (a name and a unit).
  bool get isValid =>
      name.text.trim().isNotEmpty && unit.text.trim().isNotEmpty;

  /// Keeps the unit in sync with the form unless the user typed their own.
  void changeForm(MedicineForm next) {
    if (unit.text == form.defaultUnit(_l10n)) {
      unit.text = next.defaultUnit(_l10n);
    }
    form = next;
  }

  NewMedicine toNewMedicine({required DateTime startDate, int? doctorId}) {
    final strengthText = strength.text.trim();
    return NewMedicine(
      medicine: MedicinesCompanion(
        name: Value(name.text.trim()),
        strength: Value(strengthText.isEmpty ? null : strengthText),
        form: Value(form),
        doseUnit: Value(unit.text.trim()),
        mealRelation: Value(meal),
        doctorId: Value(doctorId),
        startDate: Value(startDate),
        endDate: Value(endDate),
      ),
      doses: doses,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void dispose() {
    name.dispose();
    strength.dispose();
    unit.dispose();
  }
}
