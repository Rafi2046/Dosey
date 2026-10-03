import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../database/enums.dart';

extension ReminderTypeX on ReminderType {
  String get label => switch (this) {
    ReminderType.medicine => ReminderStrings.typeMedicine,
    ReminderType.appointment => ReminderStrings.typeAppointment,
    ReminderType.vaccine => ReminderStrings.typeVaccine,
    ReminderType.medicalTest => ReminderStrings.typeMedicalTest,
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
  String get label => switch (this) {
    MealRelation.beforeMeal => MedicineStrings.mealBefore,
    MealRelation.withMeal => MedicineStrings.mealWith,
    MealRelation.afterMeal => MedicineStrings.mealAfter,
    MealRelation.anytime => MedicineStrings.mealAnytime,
  };
}

extension MedicineFormX on MedicineForm {
  String get label => switch (this) {
    MedicineForm.tablet => MedicineStrings.formTablet,
    MedicineForm.capsule => MedicineStrings.formCapsule,
    MedicineForm.syrup => MedicineStrings.formSyrup,
    MedicineForm.injection => MedicineStrings.formInjection,
    MedicineForm.drops => MedicineStrings.formDrops,
    MedicineForm.inhaler => MedicineStrings.formInhaler,
    MedicineForm.cream => MedicineStrings.formCream,
    MedicineForm.other => MedicineStrings.formOther,
  };

  /// Sensible default dose unit for the form.
  String get defaultUnit => switch (this) {
    MedicineForm.tablet => MedicineStrings.unitTablet,
    MedicineForm.capsule => MedicineStrings.unitCapsule,
    MedicineForm.syrup => MedicineStrings.unitMl,
    MedicineForm.injection => MedicineStrings.unitInjection,
    MedicineForm.drops => MedicineStrings.unitDrop,
    MedicineForm.inhaler => MedicineStrings.unitPuff,
    MedicineForm.cream => MedicineStrings.unitApplication,
    MedicineForm.other => MedicineStrings.unitDose,
  };

  String get image => switch (this) {
    MedicineForm.tablet => AppImages.medTablet,
    MedicineForm.capsule => AppImages.medCapsule,
    MedicineForm.injection => AppImages.medInjection,
    _ => AppImages.medOther,
  };
}

extension RepeatRuleX on RepeatRule {
  String get label => switch (this) {
    RepeatRule.once => ReminderStrings.repeatOnce,
    RepeatRule.daily => ReminderStrings.repeatDaily,
    RepeatRule.weekly => ReminderStrings.repeatWeekly,
    RepeatRule.everyNDays => ReminderStrings.repeatEveryNDays,
  };
}

extension RecordTypeX on RecordType {
  String get label => switch (this) {
    RecordType.prescription => RecordStrings.recordPrescription,
    RecordType.testReport => RecordStrings.recordTestReport,
    RecordType.vaccineCertificate => RecordStrings.recordVaccineCertificate,
    RecordType.invoice => RecordStrings.recordInvoice,
    RecordType.other => RecordStrings.recordOther,
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
  String get label => switch (this) {
    ExpenseCategory.medicine => ExpenseStrings.categoryMedicine,
    ExpenseCategory.consultation => ExpenseStrings.categoryConsultation,
    ExpenseCategory.test => ExpenseStrings.categoryTest,
    ExpenseCategory.vaccine => ExpenseStrings.categoryVaccine,
    ExpenseCategory.other => ExpenseStrings.categoryOther,
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
  String get label => switch (this) {
    ReminderLogStatus.taken => ReminderStrings.markTaken,
    ReminderLogStatus.skipped => DashboardStrings.skipped,
    ReminderLogStatus.snoozed => DashboardStrings.snoozed,
    ReminderLogStatus.missed => DashboardStrings.missed,
  };
}
