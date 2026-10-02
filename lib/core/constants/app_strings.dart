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
  static const String greeting = 'Hello';
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

  // ── Common (screens) ──────────────────────────────────────────────────────
  static const String seeAll = 'See all';
  static const String all = 'All';
  static const String active = 'Active';
  static const String notSet = 'Not set';
  static const String optional = 'Optional';
  static const String saveChanges = 'Save changes';
  static const String saved = 'Saved';
  static const String deleted = 'Deleted';
  static const String next = 'Next';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String ongoing = 'Ongoing';
  static const String call = 'Call';
  static const String email = 'Email';
  static const String details = 'Details';
  static const String choose = 'Choose';
  static const String clear = 'Clear';
  static const String addTime = 'Add time';
  static const String minutes = 'minutes';
  static const String daysUnit = 'days';
  static const String nothingYet = 'Nothing here yet';
  static String daysCount(int n) => n == 1 ? '1 day' : '$n days';
  static String pagesCount(int n) => n == 1 ? '1 page' : '$n pages';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String dashboardTitle = "Today's Medicine\nReminders";
  static const String allDoneToday = 'All done for today. Great job!';
  static const String dueNow = 'Due now';
  static const String missed = 'Missed';
  static const String skipped = 'Skipped';
  static const String snoozed = 'Snoozed';
  static String nextIn(String duration) => 'Next in $duration';
  static String inHoursMinutes(int h, int m) =>
      h == 0 ? '$m min' : (m == 0 ? '$h h' : '$h h $m min');
  static const String morning = 'Morning';
  static const String afternoon = 'Afternoon';
  static const String evening = 'Evening';
  static const String bedtime = 'Bedtime';
  static const String upcoming = 'Coming up';
  static const String medicineCost = 'Medicine cost';
  static const String perMonth = '/ month';
  static const String spentThisMonth = 'Spent this month';
  static const String runningLow = 'Running low';
  static String unitsLeft(String amount) => '$amount left';
  static const String quickDoctors = 'Your doctors';
  static const String quickRecords = 'Records';

  // ── Reminders (screens) ───────────────────────────────────────────────────
  static const String remindersTitle = 'Your\nReminders';
  static const String paused = 'Paused';
  static const String ended = 'Ended';
  static const String reminderType = 'Reminder type';
  static const String reminderTitleHint = 'e.g. Morning insulin';
  static const String reminderMedicine = 'Medicine';
  static const String reminderDoctor = 'Doctor';
  static const String reminderWhen = 'When';
  static const String reminderSnooze = 'Snooze length';
  static const String selectMedicineError = 'Choose a medicine';
  static const String selectWeekdaysError = 'Choose at least one day';
  static const String deleteReminderBody =
      'The reminder and its history will be removed.';
  static String everyNDays(int n) => n == 1 ? 'Every day' : 'Every $n days';
  static String timesPerDay(int n) => n == 1 ? 'Once a day' : '$n times a day';

  // ── Medicines (screens) ───────────────────────────────────────────────────
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
  static const String noReminderTimes = 'No reminder times yet';
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

  // ── Doctors (screens) ─────────────────────────────────────────────────────
  static const String doctorsTitle = 'Your\nDoctors';
  static const String prescribedMedicines = 'Prescribed medicines';
  static const String doctorRecords = 'Records';
  static const String doctorAppointments = 'Appointments';
  static const String unarchive = 'Restore';
  static const String deleteDoctorBody =
      'Medicines and records stay, but will no longer be linked to this doctor.';
  static String activeMedicines(int n) =>
      n == 1 ? '1 active medicine' : '$n active medicines';

  // ── Records (screens) ─────────────────────────────────────────────────────
  static const String recordsTitle = 'Your\nRecords';
  static const String addPages = 'Add pages';
  static const String deletePage = 'Delete page';
  static const String recordTitleHint = 'e.g. Blood test – Oct';
  static const String deleteRecordBody =
      'All pages will be deleted from this device.';

  // ── Expenses (screens) ────────────────────────────────────────────────────
  static const String expensesTitle = 'Your\nExpenses';
  static const String byCategory = 'By category';
  static const String medicineCosts = 'Projected medicine costs';
  static const String projectedHint =
      'Based on your active medicines, their price and reminder times.';
  static const String noProjection =
      'Add a price per unit to a medicine to see projected costs.';
  static const String expenseTitleHint = 'e.g. Napa 500mg strip';
  static const String expenseMedicine = 'Medicine';
  static const String expenseDoctor = 'Doctor';
  static const String deleteExpenseBody = 'This expense will be removed.';
  static String perDay(String amount) => '$amount / day';
  static String dosesPerDayLabel(double n) =>
      '${n == n.roundToDouble() ? n.toInt() : n.toStringAsFixed(1)} / day';

  // ── Add sheet ─────────────────────────────────────────────────────────────
  static const String addSheetTitle = 'What would you like to add?';

  // ── Permission onboarding ─────────────────────────────────────────────────
  static const String onboardingTitle = 'Never miss\na dose';
  static const String onboardingBody =
      'Dosey rings like an alarm clock — even on silent or Do Not Disturb. '
      'Allow these so your reminders arrive exactly on time.';
  static const String onboardingContinue = "Let's get started";
  static const String onboardingEssentialHint =
      'Notifications and exact alarms are required.';
  static const String recommended = 'Recommended';
  static const String required = 'Required';
  static const String allow = 'Allow';
  static const String allowed = 'Allowed';

  static const String permNotificationsTitle = 'Notifications';
  static const String permNotificationsBody =
      'Show medicine, appointment and test reminders.';
  static const String permExactAlarmsTitle = 'Exact alarms';
  static const String permExactAlarmsBody =
      'Ring at the exact minute — not "sometime around" it.';
  static const String permFullScreenTitle = 'Full-screen alarm';
  static const String permFullScreenBody =
      'Wake the screen and show the alarm over the lock screen.';
  static const String permDndTitle = 'Ring in Do Not Disturb';
  static const String permDndBody =
      'Let critical reminders break through silent and DND modes.';

  // ── Alarm (ringing) screen ────────────────────────────────────────────────
  static const String alarmMarkTaken = 'Medicine Taken';
  static const String alarmDone = 'Done';
  static const String alarmSnooze = 'Snooze';
  static const String alarmSkip = 'Skip this time';
  static const String alarmScheduledFor = 'Scheduled for';
  static const String minutesShort = 'min';

  // ── Notification content ──────────────────────────────────────────────────
  static const String notifTaken = 'Taken ✓';
  static const String notifSnooze = 'Snooze';
  static const String notifSkip = 'Skip';
  static const String notifDoseSeparator = ' · ';
  static const String notifAtLocation = 'At ';
  static const String notifWithDoctor = 'With ';

  // ── Debug helpers (debug builds only) ─────────────────────────────────────
  static const String debugTestAlarm = 'Test alarm (rings in 1–2 min)';
  static const String debugTestAlarmScheduled =
      'Test alarm scheduled. Lock the phone and wait.';
  static const String debugTestAlarmTitle = 'Test medicine';
  static const String debugTestAlarmBody = 'Take 1 tablet after breakfast';

  // ── Notification channels ─────────────────────────────────────────────────
  static const String channelGroupName = 'Dosey reminders';
  static const String channelMedicineName = 'Medicine alarms';
  static const String channelMedicineDesc =
      'Rings for doses, even in Do Not Disturb';
  static const String channelAppointmentName = 'Appointment alarms';
  static const String channelAppointmentDesc = "Doctor's appointment alarms";
  static const String channelVaccineName = 'Vaccine alarms';
  static const String channelVaccineDesc = 'Vaccination alarms';
  static const String channelTestName = 'Medical test alarms';
  static const String channelTestDesc = 'Lab and medical test alarms';
  static const String channelGentleName = 'Gentle reminders';
  static const String channelGentleDesc =
      'Non-critical reminders that respect Do Not Disturb';
}
