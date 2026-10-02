/// All user-facing text. Grouped by feature; widgets must not inline strings.
abstract final class AppStrings {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'Dosey';
  static const String tagline = 'Your medical companion';

  // ── Navigation ────────────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navReminders = 'Reminders';
  static const String navMedicines = 'Medicines';
  static const String navRecords = 'Records';
  static const String navMore = 'More';
  static const String navDoctors = 'Doctors';
  static const String navExpenses = 'Expenses';

  // ── Common actions ────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String done = 'Done';
  static const String retry = 'Retry';
  static const String confirm = 'Confirm';
  static const String archive = 'Archive';
  static const String none = 'None';
  static const String deleteConfirmTitle = 'Delete this item?';
  static const String deleteConfirmBody = 'This cannot be undone.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String loading = 'Loading…';

  // ── Validation ────────────────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidNumber = 'Enter a valid number';
  static const String invalidAmount = 'Enter a valid amount';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String greeting = 'Stay on track';
  static const String nextDose = 'Next reminder';
  static const String todaySchedule = "Today's schedule";
  static const String nothingScheduled = 'Nothing scheduled. Enjoy your day!';

  // ── Reminders ─────────────────────────────────────────────────────────────
  static const String reminders = 'Reminders';
  static const String addReminder = 'Add reminder';
  static const String editReminder = 'Edit reminder';
  static const String reminderTitle = 'Title';
  static const String reminderNotes = 'Notes';
  static const String reminderLocation = 'Location';
  static const String reminderDateTime = 'Date & time';
  static const String reminderRepeat = 'Repeat';
  static const String reminderEndDate = 'End date';
  static const String reminderEveryNDays = 'Every how many days';
  static const String reminderWeekdays = 'Days of week';
  static const String reminderCritical = 'Ring in Do Not Disturb';
  static const String reminderCriticalHint =
      'Uses a full-screen alarm that bypasses silent and DND modes';
  static const String noReminders = 'No reminders yet';
  static const String markTaken = 'Taken';
  static const String markSkipped = 'Skip';
  static const String snooze = 'Snooze';

  static const String typeMedicine = 'Medicine';
  static const String typeAppointment = 'Appointment';
  static const String typeVaccine = 'Vaccine';
  static const String typeMedicalTest = 'Medical test';

  static const String repeatOnce = 'Once';
  static const String repeatDaily = 'Daily';
  static const String repeatWeekly = 'Weekly';
  static const String repeatEveryNDays = 'Every N days';

  static const List<String> weekdaysShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', //
  ];

  // ── Medicines ─────────────────────────────────────────────────────────────
  static const String medicines = 'Medicines';
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
  static const String inactive = 'Inactive';

  static const String formTablet = 'Tablet';
  static const String formCapsule = 'Capsule';
  static const String formSyrup = 'Syrup';
  static const String formInjection = 'Injection';
  static const String formDrops = 'Drops';
  static const String formInhaler = 'Inhaler';
  static const String formCream = 'Cream';
  static const String formOther = 'Other';

  static const String mealBefore = 'Before meal';
  static const String mealWith = 'With meal';
  static const String mealAfter = 'After meal';
  static const String mealAnytime = 'Anytime';

  // ── Doctors ───────────────────────────────────────────────────────────────
  static const String doctors = 'Doctors';
  static const String addDoctor = 'Add doctor';
  static const String editDoctor = 'Edit doctor';
  static const String doctorName = 'Name';
  static const String doctorSpecialty = 'Specialty';
  static const String doctorPhone = 'Phone';
  static const String doctorEmail = 'Email';
  static const String doctorClinic = 'Clinic / hospital';
  static const String doctorAddress = 'Address';
  static const String doctorFee = 'Consultation fee';
  static const String doctorNotes = 'Notes';
  static const String noDoctors = 'No doctors added';
  static const String activeMedicinesCount = 'active medicines';

  // ── Records ───────────────────────────────────────────────────────────────
  static const String records = 'Records';
  static const String addRecord = 'Add record';
  static const String recordTitle = 'Title';
  static const String recordType = 'Type';
  static const String recordDate = 'Document date';
  static const String recordDoctor = 'Doctor';
  static const String recordNotes = 'Notes';
  static const String recordPages = 'Pages';
  static const String takePhoto = 'Take photo';
  static const String chooseFromGallery = 'Choose from gallery';
  static const String noRecords = 'No records saved';
  static const String addAtLeastOnePage = 'Add at least one page';

  static const String recordPrescription = 'Prescription';
  static const String recordTestReport = 'Test report';
  static const String recordVaccineCertificate = 'Vaccine card';
  static const String recordInvoice = 'Invoice';
  static const String recordOther = 'Other';

  // ── Expenses ──────────────────────────────────────────────────────────────
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add expense';
  static const String expenseTitle = 'Description';
  static const String expenseAmount = 'Amount';
  static const String expenseQuantity = 'Quantity';
  static const String expenseCategory = 'Category';
  static const String expenseDate = 'Date';
  static const String expenseNotes = 'Notes';
  static const String noExpenses = 'No expenses recorded';
  static const String totalSpent = 'Total spent';
  static const String thisMonth = 'This month';
  static const String projectedMonthly = 'Projected monthly medicine cost';
  static const String projectedDaily = 'per day';

  static const String categoryMedicine = 'Medicine';
  static const String categoryConsultation = 'Consultation';
  static const String categoryTest = 'Test';
  static const String categoryVaccine = 'Vaccine';
  static const String categoryOther = 'Other';

  // ── Permissions ───────────────────────────────────────────────────────────
  static const String permissionsTitle = 'Allow reliable alarms';
  static const String permissionsBody =
      'Dosey needs these permissions so your reminders ring on time, '
      'even in silent or Do Not Disturb mode.';
  static const String permissionNotifications = 'Notifications';
  static const String permissionExactAlarms = 'Exact alarms';
  static const String permissionDnd = 'Bypass Do Not Disturb';
  static const String permissionFullScreen = 'Full-screen alarms';
  static const String grant = 'Grant';
  static const String granted = 'Granted';

  // ── Notification channels ─────────────────────────────────────────────────
  static const String criticalChannelName = 'Critical alarms';
  static const String criticalChannelDescription =
      'Medicine and appointment alarms that ring even in Do Not Disturb';
  static const String standardChannelName = 'Reminders';
  static const String standardChannelDescription = 'General reminders';
  static const String channelGroupName = 'Dosey reminders';
}
