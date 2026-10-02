import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../database/enums.dart';

extension ReminderTypeX on ReminderType {
  String get label => switch (this) {
    ReminderType.medicine => AppStrings.typeMedicine,
    ReminderType.appointment => AppStrings.typeAppointment,
    ReminderType.vaccine => AppStrings.typeVaccine,
    ReminderType.medicalTest => AppStrings.typeMedicalTest,
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
    MealRelation.beforeMeal => AppStrings.mealBefore,
    MealRelation.withMeal => AppStrings.mealWith,
    MealRelation.afterMeal => AppStrings.mealAfter,
    MealRelation.anytime => AppStrings.mealAnytime,
  };
}

extension MedicineFormX on MedicineForm {
  String get label => switch (this) {
    MedicineForm.tablet => AppStrings.formTablet,
    MedicineForm.capsule => AppStrings.formCapsule,
    MedicineForm.syrup => AppStrings.formSyrup,
    MedicineForm.injection => AppStrings.formInjection,
    MedicineForm.drops => AppStrings.formDrops,
    MedicineForm.inhaler => AppStrings.formInhaler,
    MedicineForm.cream => AppStrings.formCream,
    MedicineForm.other => AppStrings.formOther,
  };

  /// Sensible default dose unit for the form.
  String get defaultUnit => switch (this) {
    MedicineForm.tablet => AppStrings.unitTablet,
    MedicineForm.capsule => AppStrings.unitCapsule,
    MedicineForm.syrup => AppStrings.unitMl,
    MedicineForm.injection => AppStrings.unitInjection,
    MedicineForm.drops => AppStrings.unitDrop,
    MedicineForm.inhaler => AppStrings.unitPuff,
    MedicineForm.cream => AppStrings.unitApplication,
    MedicineForm.other => AppStrings.unitDose,
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
    RepeatRule.once => AppStrings.repeatOnce,
    RepeatRule.daily => AppStrings.repeatDaily,
    RepeatRule.weekly => AppStrings.repeatWeekly,
    RepeatRule.everyNDays => AppStrings.repeatEveryNDays,
  };
}

extension RecordTypeX on RecordType {
  String get label => switch (this) {
    RecordType.prescription => AppStrings.recordPrescription,
    RecordType.testReport => AppStrings.recordTestReport,
    RecordType.vaccineCertificate => AppStrings.recordVaccineCertificate,
    RecordType.invoice => AppStrings.recordInvoice,
    RecordType.other => AppStrings.recordOther,
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
    ExpenseCategory.medicine => AppStrings.categoryMedicine,
    ExpenseCategory.consultation => AppStrings.categoryConsultation,
    ExpenseCategory.test => AppStrings.categoryTest,
    ExpenseCategory.vaccine => AppStrings.categoryVaccine,
    ExpenseCategory.other => AppStrings.categoryOther,
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
    ExpenseCategory.consultation => AppColors.olive,
    ExpenseCategory.test => AppColors.accent,
    ExpenseCategory.vaccine => AppColors.stone,
    ExpenseCategory.other => AppColors.sand,
  };
}

extension ReminderLogStatusX on ReminderLogStatus {
  String get label => switch (this) {
    ReminderLogStatus.taken => AppStrings.markTaken,
    ReminderLogStatus.skipped => AppStrings.skipped,
    ReminderLogStatus.snoozed => AppStrings.snoozed,
    ReminderLogStatus.missed => AppStrings.missed,
  };
}
