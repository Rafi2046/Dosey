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

  String get image => switch (this) {
    MedicineForm.tablet => AppImages.medTablet,
    MedicineForm.capsule => AppImages.medCapsule,
    MedicineForm.injection => AppImages.medInjection,
    _ => AppImages.medOther,
  };
}
