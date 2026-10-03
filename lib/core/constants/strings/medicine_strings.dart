/// Medicines list, detail, form and dosage text.
abstract final class MedicineStrings {
  static const String addMedicine = 'Add medicine';
  static const String editMedicine = 'Edit medicine';
  static const String medicineName = 'Medicine name';
  static const String medicineStrength = 'Strength (e.g. 500 mg)';
  static const String medicineForm = 'Form';
  static const String medicineDose = 'Dose per intake';
  static const String medicineDoseUnit = 'Unit';
  static const String medicineMeal = 'When to take';
  static const String medicineUnitPrice = 'Price per unit';
  static const String medicineStock = 'Stock on hand';
  static const String medicineRefillAt = 'Refill alert at';
  static const String medicineDoctor = 'Prescribed by';
  static const String medicineStartDate = 'Start date';
  static const String medicineEndDate = 'End date';
  static const String noMedicines = 'No medicines added';
  static const String lowStock = 'Low stock';
  static const String formTablet = 'Tablet';
  static const String formCapsule = 'Capsule';
  static const String formSyrup = 'Syrup';
  static const String formInjection = 'Injection';
  static const String formDrops = 'Drops';
  static const String formInhaler = 'Inhaler';
  static const String formCream = 'Cream';
  static const String formOther = 'Other';
  static const String unitTablet = 'tablet';
  static const String unitCapsule = 'capsule';
  static const String unitMl = 'ml';
  static const String unitInjection = 'unit';
  static const String unitDrop = 'drop';
  static const String unitPuff = 'puff';
  static const String unitApplication = 'application';
  static const String unitDose = 'dose';
  static const String mealBefore = 'Before meal';
  static const String mealWith = 'With meal';
  static const String mealAfter = 'After meal';
  static const String mealAnytime = 'Anytime';
  static const String medicinesTitle = 'Your\nMedicines';
  static const String stopped = 'Stopped';
  static const String chooseMedicineType = 'Choose Medicine\nType';
  static const String medicineDetails = 'Medicine details';
  static const String medicineDescription = 'Description';
  static const String medicineDescriptionHint = 'How and why to take it';
  static const String timeDuration = 'Time Duration';
  static const String medicineTime = 'Medicine Time';
  static const String daysInWeek = 'Days in a week';
  static const String doses = 'Doses';
  static const String costPerMonth = 'Cost per month';
  static const String inStock = 'In stock';
  static const String prescription = 'Prescription';
  static const String reminderTimesHint =
      'Add the times you take this medicine — each one rings like an alarm.';
  static const String changeSetting = 'Change Setting';
  static const String refill = 'Refill';
  static const String refillTitle = 'Record a refill';
  static const String refillQuantity = 'Quantity bought';
  static const String refillTotal = 'Total paid';
  static const String refillSaved = 'Refill saved and added to expenses';
  static const String stopMedicine = 'Stop taking';
  static const String resumeMedicine = 'Resume';
  static const String deleteMedicineBody =
      'Its reminders and dose history will be deleted too.';
  static const String everyDay = 'Every day';
  static const String doseTimeTitle = 'Intake time';
  static const String doseHowMany = 'How many at this time';
  static const String removeTime = 'Remove this time';

  // ── Prescription scan ─────────────────────────────────────────────────────
  static const String scanTitle = 'Scan prescription';
  static const String scanSubtitle =
      'Auto-fill name, dose and times from a photo';
  static const String scanReading = 'Reading prescription…';
  static const String scanNothingFound =
      'No medicines found. Try a clearer, well-lit photo or fill in manually.';
  static const String scanFailed =
      "Couldn't read that image. Please try again.";
  static const String bulkTitle = 'Review medicines';
  static const String bulkHint =
      'Found on your prescription. Check each medicine, fix anything that '
      'looks wrong, remove extras, then save them all at once.';
  static const String bulkAddAnother = 'Add another medicine';
  static const String bulkRemove = 'Remove medicine';
  static const String bulkEmpty = 'No medicines left. Add one or go back.';
  static String bulkSaveAll(int n) =>
      n == 1 ? 'Save 1 medicine' : 'Save $n medicines';
  static String bulkSaved(int n) =>
      n == 1 ? 'Added 1 medicine' : 'Added $n medicines';
  static String bulkAsWritten(String pattern) => 'Prescription says: $pattern';
  static String bulkFixMedicine(int n) =>
      'Medicine $n needs a name and unit before saving.';
  static const String bulkNoTimes =
      'No times set: this medicine will not ring.';
  static const String scanFilled =
      'Filled from prescription. Please check every field before saving.';
}
