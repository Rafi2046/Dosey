import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../database/enums.dart';
import '../localization/l10n.dart';

extension ReminderTypeX on ReminderType {
  String label(AppLocalizations l) => switch (this) {
    ReminderType.medicine => l.typeMedicine,
    ReminderType.appointment => l.typeAppointment,
    ReminderType.vaccine => l.typeVaccine,
    ReminderType.medicalTest => l.typeMedicalTest,
  };

  IconData get icon => switch (this) {
    ReminderType.medicine => Icons.medication_rounded,
    ReminderType.appointment => Icons.medical_services_rounded,
    ReminderType.vaccine => Icons.vaccines_rounded,
    ReminderType.medicalTest => Icons.biotech_rounded,
  };

  Color get color => switch (this) {
    ReminderType.medicine => AppColors.medicine,
    ReminderType.appointment => AppColors.appointment,
    ReminderType.vaccine => AppColors.vaccine,
    ReminderType.medicalTest => AppColors.medicalTest,
  };
}

extension MealRelationX on MealRelation {
  String label(AppLocalizations l) => switch (this) {
    MealRelation.beforeMeal => l.mealBefore,
    MealRelation.withMeal => l.mealWith,
    MealRelation.afterMeal => l.mealAfter,
    MealRelation.anytime => l.mealAnytime,
  };
}

extension MedicineFormX on MedicineForm {
  String label(AppLocalizations l) => switch (this) {
    MedicineForm.tablet => l.formTablet,
    MedicineForm.capsule => l.formCapsule,
    MedicineForm.syrup => l.formSyrup,
    MedicineForm.injection => l.formInjection,
    MedicineForm.drops => l.formDrops,
    MedicineForm.inhaler => l.formInhaler,
    MedicineForm.cream => l.formCream,
    MedicineForm.other => l.formOther,
  };

  /// Sensible default dose unit for the form, in the current language.
  String defaultUnit(AppLocalizations l) => switch (this) {
    MedicineForm.tablet => l.unitTablet,
    MedicineForm.capsule => l.unitCapsule,
    MedicineForm.syrup => l.unitMl,
    MedicineForm.injection => l.unitInjection,
    MedicineForm.drops => l.unitDrop,
    MedicineForm.inhaler => l.unitPuff,
    MedicineForm.cream => l.unitApplication,
    MedicineForm.other => l.unitDose,
  };

  /// [defaultUnit] for more than one: "tablets" (same word in Bengali).
  String defaultUnitPlural(AppLocalizations l) => switch (this) {
    MedicineForm.tablet => l.unitTabletPlural,
    MedicineForm.capsule => l.unitCapsulePlural,
    MedicineForm.syrup => l.unitMlPlural,
    MedicineForm.injection => l.unitInjectionPlural,
    MedicineForm.drops => l.unitDropPlural,
    MedicineForm.inhaler => l.unitPuffPlural,
    MedicineForm.cream => l.unitApplicationPlural,
    MedicineForm.other => l.unitDosePlural,
  };

  String get image => switch (this) {
    MedicineForm.tablet => AppImages.medTablet,
    MedicineForm.capsule => AppImages.medCapsule,
    MedicineForm.injection => AppImages.medInjection,
    _ => AppImages.medOther,
  };
}

extension RepeatRuleX on RepeatRule {
  String label(AppLocalizations l) => switch (this) {
    RepeatRule.once => l.repeatOnce,
    RepeatRule.daily => l.repeatDaily,
    RepeatRule.weekly => l.repeatWeekly,
    RepeatRule.everyNDays => l.repeatEveryNDays,
  };
}

extension RecordTypeX on RecordType {
  String label(AppLocalizations l) => switch (this) {
    RecordType.prescription => l.recordPrescription,
    RecordType.testReport => l.recordTestReport,
    RecordType.vaccineCertificate => l.recordVaccineCertificate,
    RecordType.invoice => l.recordInvoice,
    RecordType.other => l.recordOther,
  };

  IconData get icon => switch (this) {
    RecordType.prescription => Icons.description_rounded,
    RecordType.testReport => Icons.science_rounded,
    RecordType.vaccineCertificate => Icons.vaccines_rounded,
    RecordType.invoice => Icons.receipt_long_rounded,
    RecordType.other => Icons.folder_rounded,
  };
}

extension ExpenseCategoryX on ExpenseCategory {
  String label(AppLocalizations l) => switch (this) {
    ExpenseCategory.medicine => l.categoryMedicine,
    ExpenseCategory.consultation => l.categoryConsultation,
    ExpenseCategory.test => l.categoryTest,
    ExpenseCategory.vaccine => l.categoryVaccine,
    ExpenseCategory.other => l.categoryOther,
  };

  IconData get icon => switch (this) {
    ExpenseCategory.medicine => Icons.medication_rounded,
    ExpenseCategory.consultation => Icons.medical_services_rounded,
    ExpenseCategory.test => Icons.biotech_rounded,
    ExpenseCategory.vaccine => Icons.vaccines_rounded,
    ExpenseCategory.other => Icons.payments_rounded,
  };

  Color get color => switch (this) {
    ExpenseCategory.medicine => AppColors.mint,
    ExpenseCategory.consultation => AppColors.sand,
    ExpenseCategory.test => AppColors.accent,
    ExpenseCategory.vaccine => AppColors.warning,
    ExpenseCategory.other => AppColors.textOnDarkMuted,
  };
}

extension ReminderLogStatusX on ReminderLogStatus {
  String label(AppLocalizations l) => switch (this) {
    ReminderLogStatus.taken => l.markTaken,
    ReminderLogStatus.skipped => l.skipped,
    ReminderLogStatus.snoozed => l.snoozed,
    ReminderLogStatus.missed => l.missed,
    ReminderLogStatus.takenLate => l.takenLate,
  };
}
