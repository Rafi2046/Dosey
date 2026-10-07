// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dosey';

  @override
  String get navHome => 'Home';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navMedicines => 'Medicines';

  @override
  String get navRecords => 'Records';

  @override
  String get navDoctors => 'Doctors';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get archive => 'Archive';

  @override
  String get none => 'None';

  @override
  String get deleteConfirmTitle => 'Delete this item?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get seeAll => 'See all';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get optional => 'Optional';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saved => 'Saved';

  @override
  String get next => 'Next';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get call => 'Call';

  @override
  String get email => 'Email';

  @override
  String get details => 'Details';

  @override
  String get choose => 'Choose';

  @override
  String get clear => 'Clear';

  @override
  String get addTime => 'Add time';

  @override
  String get done => 'Done';

  @override
  String get daysUnit => 'days';

  @override
  String get addSheetTitle => 'What would you like to add?';

  @override
  String get alarmMarkTaken => 'Medicine taken';

  @override
  String get alarmDone => 'Done';

  @override
  String get alarmSnooze => 'Snooze';

  @override
  String get alarmSkip => 'Skip this time';

  @override
  String get minutesShort => 'min';

  @override
  String get nothingScheduled => 'Nothing scheduled. Enjoy your day!';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get dashboardTitle => 'Today\'s Medicine\nReminders';

  @override
  String get missed => 'Missed';

  @override
  String get skipped => 'Skipped';

  @override
  String get snoozed => 'Snoozed';

  @override
  String get skipDose => 'Skip';

  @override
  String get scheduledTime => 'Scheduled time';

  @override
  String get changeTime => 'Change';

  @override
  String get viewMedicineDetails => 'View full medicine details';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get upcoming => 'Coming up';

  @override
  String get medicineCost => 'Medicine cost';

  @override
  String get perMonth => '/ month';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get runningLow => 'Running low';

  @override
  String get debugTestAlarm => 'Test alarm (rings in 1–2 min)';

  @override
  String get debugTestAlarmScheduled =>
      'Test alarm scheduled. Lock the phone and wait.';

  @override
  String get debugTestAlarmTitle => 'Test medicine';

  @override
  String get debugLoadDemo => 'Load demo data';

  @override
  String get debugDemoLoaded => 'Demo data loaded';

  @override
  String get debugTestAlarmBody => 'Take 1 tablet after breakfast';

  @override
  String get addDoctor => 'Add doctor';

  @override
  String get editDoctor => 'Edit doctor';

  @override
  String get doctorName => 'Name';

  @override
  String get doctorSpecialty => 'Specialty';

  @override
  String get doctorPhone => 'Phone';

  @override
  String get doctorEmail => 'Email';

  @override
  String get doctorClinic => 'Clinic / hospital';

  @override
  String get doctorAddress => 'Address';

  @override
  String get doctorFee => 'Consultation fee';

  @override
  String get doctorNotes => 'Notes';

  @override
  String get noDoctors => 'No doctors added';

  @override
  String get doctorsTitle => 'Your\nDoctors';

  @override
  String get prescribedMedicines => 'Prescribed medicines';

  @override
  String get doctorRecords => 'Records';

  @override
  String get doctorAppointments => 'Appointments';

  @override
  String get unarchive => 'Restore';

  @override
  String get addAppointment => 'Add appointment';

  @override
  String get deleteDoctorBody =>
      'Medicines and records stay, but will no longer be linked to this doctor.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add expense';

  @override
  String get expenseTitle => 'Description';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseQuantity => 'Quantity';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'No expenses recorded';

  @override
  String get projectedMonthly => 'Projected monthly medicine cost';

  @override
  String get categoryMedicine => 'Medicine';

  @override
  String get categoryConsultation => 'Consultation';

  @override
  String get categoryTest => 'Test';

  @override
  String get categoryVaccine => 'Vaccine';

  @override
  String get categoryOther => 'Other';

  @override
  String get expensesTitle => 'Your\nExpenses';

  @override
  String get byCategory => 'By category';

  @override
  String get medicineCosts => 'Projected medicine costs';

  @override
  String get projectedHint =>
      'Based on your active medicines, their price and reminder times.';

  @override
  String get noProjection =>
      'Add a price per unit to a medicine to see projected costs.';

  @override
  String get expenseTitleHint => 'e.g. Napa 500mg strip';

  @override
  String get expenseMedicine => 'Medicine';

  @override
  String get expenseDoctor => 'Doctor';

  @override
  String get deleteExpenseBody => 'This expense will be removed.';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get editMedicine => 'Edit medicine';

  @override
  String get medicineName => 'Medicine name';

  @override
  String get medicineStrength => 'Strength (e.g. 500 mg)';

  @override
  String get medicineForm => 'Form';

  @override
  String get medicineDoseUnit => 'Unit';

  @override
  String get medicineMeal => 'When to take';

  @override
  String get medicineUnitPrice => 'Price per unit';

  @override
  String get medicineStock => 'Stock on hand';

  @override
  String get medicineDoctor => 'Prescribed by';

  @override
  String get medicineStartDate => 'Start date';

  @override
  String get medicineEndDate => 'End date';

  @override
  String get noMedicines => 'No medicines added';

  @override
  String get lowStock => 'Low stock';

  @override
  String get formTablet => 'Tablet';

  @override
  String get formCapsule => 'Capsule';

  @override
  String get formSyrup => 'Syrup';

  @override
  String get formInjection => 'Injection';

  @override
  String get formDrops => 'Drops';

  @override
  String get formInhaler => 'Inhaler';

  @override
  String get formCream => 'Cream';

  @override
  String get formOther => 'Other';

  @override
  String get unitTablet => 'tablet';

  @override
  String get unitCapsule => 'capsule';

  @override
  String get unitMl => 'ml';

  @override
  String get unitInjection => 'unit';

  @override
  String get unitDrop => 'drop';

  @override
  String get unitPuff => 'puff';

  @override
  String get unitApplication => 'application';

  @override
  String get unitDose => 'dose';

  @override
  String get mealBefore => 'Before meal';

  @override
  String get mealWith => 'With meal';

  @override
  String get mealAfter => 'After meal';

  @override
  String get mealAnytime => 'Anytime';

  @override
  String get medicinesTitle => 'Your\nMedicines';

  @override
  String get stopped => 'Stopped';

  @override
  String get chooseMedicineType => 'Choose Medicine\nType';

  @override
  String get medicineDetails => 'Medicine details';

  @override
  String get medicineDescription => 'Description';

  @override
  String get medicineDescriptionHint => 'How and why to take it';

  @override
  String get timeDuration => 'Duration';

  @override
  String get medicineTime => 'Medicine times';

  @override
  String get daysInWeek => 'Days in a week';

  @override
  String get doses => 'Doses';

  @override
  String get costPerMonth => 'Cost per month';

  @override
  String get inStock => 'In stock';

  @override
  String get prescription => 'Prescription';

  @override
  String get reminderTimesHint =>
      'Add the times you take this medicine — each one rings like an alarm.';

  @override
  String get changeSetting => 'Edit details';

  @override
  String get refill => 'Refill';

  @override
  String get refillTitle => 'Record a refill';

  @override
  String get refillQuantity => 'Quantity bought';

  @override
  String get refillTotal => 'Total paid';

  @override
  String get refillSaved => 'Refill saved and added to expenses';

  @override
  String get stopMedicine => 'Stop taking';

  @override
  String get resumeMedicine => 'Resume';

  @override
  String get deleteMedicineBody =>
      'Its reminders and dose history will be deleted too.';

  @override
  String get everyDay => 'Every day';

  @override
  String get doseTimeTitle => 'Intake time';

  @override
  String get doseHowMany => 'How many at this time';

  @override
  String get removeTime => 'Remove this time';

  @override
  String get scanTitle => 'Scan prescription';

  @override
  String get scanSubtitle => 'Auto-fill name, dose and times from a photo';

  @override
  String get scanReading => 'Reading prescription…';

  @override
  String get scanNothingFound =>
      'No medicines found. Try a clearer, well-lit photo or fill in manually.';

  @override
  String get scanFailed => 'Couldn\'t read that image. Please try again.';

  @override
  String get bulkTitle => 'Review medicines';

  @override
  String get bulkHint =>
      'Found on your prescription. Check each medicine, fix anything that looks wrong, remove extras, then save them all at once.';

  @override
  String get bulkAddAnother => 'Add another medicine';

  @override
  String get bulkRemove => 'Remove medicine';

  @override
  String get bulkEmpty => 'No medicines left. Add one or go back.';

  @override
  String get bulkNoTimes => 'No times set: this medicine will not ring.';

  @override
  String get scanFilled =>
      'Filled from prescription. Please check every field before saving.';

  @override
  String get notifTaken => 'Taken ✓';

  @override
  String get notifSnooze => 'Snooze';

  @override
  String get notifSkip => 'Skip';

  @override
  String get notifDoseSeparator => ' · ';

  @override
  String get notifAtLocation => 'At ';

  @override
  String get notifWithDoctor => 'With ';

  @override
  String get channelGroupName => 'Dosey reminders';

  @override
  String get channelMedicineName => 'Medicine alarms';

  @override
  String get channelMedicineDesc => 'Rings for doses, even in Do Not Disturb';

  @override
  String get channelAppointmentName => 'Appointment alarms';

  @override
  String get channelAppointmentDesc => 'Doctor\'s appointment alarms';

  @override
  String get channelVaccineName => 'Vaccine alarms';

  @override
  String get channelVaccineDesc => 'Vaccination alarms';

  @override
  String get channelTestName => 'Medical test alarms';

  @override
  String get channelTestDesc => 'Lab and medical test alarms';

  @override
  String get channelGentleName => 'Gentle reminders';

  @override
  String get channelGentleDesc =>
      'Non-critical reminders that respect Do Not Disturb';

  @override
  String get onboardingTitle => 'Never miss\na dose';

  @override
  String get onboardingBody =>
      'Dosey rings like an alarm clock — even on silent or Do Not Disturb. Allow these so your reminders arrive exactly on time.';

  @override
  String get onboardingContinue => 'Let\'s get started';

  @override
  String get onboardingEssentialHint =>
      'Notifications and exact alarms are required.';

  @override
  String get recommended => 'Recommended';

  @override
  String get required => 'Required';

  @override
  String get allow => 'Allow';

  @override
  String get allowed => 'Allowed';

  @override
  String get permNotificationsTitle => 'Notifications';

  @override
  String get permNotificationsBody =>
      'Show medicine, appointment and test reminders.';

  @override
  String get permExactAlarmsTitle => 'Exact alarms';

  @override
  String get permExactAlarmsBody =>
      'Ring at the exact minute — not \"sometime around\" it.';

  @override
  String get permFullScreenTitle => 'Full-screen alarm';

  @override
  String get permFullScreenBody =>
      'Wake the screen and show the alarm over the lock screen.';

  @override
  String get permDndTitle => 'Ring in Do Not Disturb';

  @override
  String get permDndBody =>
      'Let critical reminders break through silent and DND modes.';

  @override
  String get records => 'Records';

  @override
  String get addRecord => 'Add record';

  @override
  String get recordTitle => 'Title';

  @override
  String get recordType => 'Type';

  @override
  String get recordDate => 'Document date';

  @override
  String get recordDoctor => 'Doctor';

  @override
  String get recordNotes => 'Notes';

  @override
  String get recordPages => 'Pages';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get noRecords => 'No records saved';

  @override
  String get addAtLeastOnePage => 'Add at least one page';

  @override
  String get recordPrescription => 'Prescription';

  @override
  String get recordTestReport => 'Test report';

  @override
  String get recordVaccineCertificate => 'Vaccine card';

  @override
  String get recordInvoice => 'Invoice';

  @override
  String get recordOther => 'Other';

  @override
  String get recordsTitle => 'Your\nRecords';

  @override
  String get addPages => 'Add pages';

  @override
  String get deletePage => 'Delete page';

  @override
  String get recordTitleHint => 'e.g. Blood test – Oct';

  @override
  String get deleteRecordBody => 'All pages will be deleted from this device.';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get reminderTitle => 'Title';

  @override
  String get reminderNotes => 'Notes';

  @override
  String get reminderLocation => 'Location';

  @override
  String get reminderRepeat => 'Repeat';

  @override
  String get reminderEndDate => 'End date';

  @override
  String get reminderEveryNDays => 'Every how many days';

  @override
  String get reminderCritical => 'Ring in Do Not Disturb';

  @override
  String get reminderCriticalHint =>
      'Uses a full-screen alarm that bypasses silent and DND modes';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get markTaken => 'Taken';

  @override
  String get typeMedicine => 'Medicine';

  @override
  String get typeAppointment => 'Appointment';

  @override
  String get typeVaccine => 'Vaccine';

  @override
  String get typeMedicalTest => 'Medical test';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatEveryNDays => 'Every N days';

  @override
  String get remindersTitle => 'Your\nReminders';

  @override
  String get paused => 'Paused';

  @override
  String get ended => 'Ended';

  @override
  String get reminderType => 'Reminder type';

  @override
  String get reminderTitleHint => 'e.g. Morning insulin';

  @override
  String get reminderMedicine => 'Medicine';

  @override
  String get reminderDoctor => 'Doctor';

  @override
  String get reminderWhen => 'When';

  @override
  String get reminderSnooze => 'Snooze length';

  @override
  String get selectMedicineError => 'Choose a medicine';

  @override
  String get selectWeekdaysError => 'Choose at least one day';

  @override
  String get deleteReminderBody =>
      'The reminder and its history will be removed.';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeader => 'App\nSettings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Phone default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String daysCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String pagesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String nextTypeIn(String type, String duration) {
    return 'Next $type in $duration';
  }

  @override
  String durationMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString min';
  }

  @override
  String durationHours(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '$hoursString h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String unitsLeft(String amount) {
    return '$amount left';
  }

  @override
  String activeMedicines(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString active medicines',
      one: '1 active medicine',
    );
    return '$_temp0';
  }

  @override
  String perDay(String amount) {
    return '$amount / day';
  }

  @override
  String unitsPerDayLabel(String amount, String unit) {
    return '$amount $unit / day';
  }

  @override
  String bulkSaveAll(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $countString medicines',
      one: 'Save 1 medicine',
    );
    return '$_temp0';
  }

  @override
  String bulkSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $countString medicines',
      one: 'Added 1 medicine',
    );
    return '$_temp0';
  }

  @override
  String bulkAsWritten(String pattern) {
    return 'Prescription says: $pattern';
  }

  @override
  String bulkFixMedicine(int number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Medicine $numberString needs a name and unit before saving.';
  }

  @override
  String everyNDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $countString days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String get onboardingWelcomeBody =>
      'Your medicine reminder that rings like a real alarm clock, so you never miss a dose.';

  @override
  String get onboardingChooseLanguage => 'Choose your language';

  @override
  String get onboardingFeaturesTitle => 'Everything to stay\non track';

  @override
  String get featureAlarmTitle => 'Alarms that really ring';

  @override
  String get featureAlarmBody =>
      'Every dose rings like an alarm clock, even on silent.';

  @override
  String get featureScanTitle => 'Scan your prescription';

  @override
  String get featureScanBody =>
      'Snap a photo and Dosey fills in the medicines, doses and times.';

  @override
  String get featureStockTitle => 'Stock and cost tracking';

  @override
  String get featureStockBody =>
      'Get refill alerts and see what your medicines cost each month.';

  @override
  String get featurePrivateTitle => 'Private by design';

  @override
  String get featurePrivateBody =>
      'Everything stays on your phone. No account, no cloud.';

  @override
  String get onboardingPermissionsTitle => 'Let Dosey ring\non time';

  @override
  String get allowAll => 'Allow all';

  @override
  String get allowAllHint =>
      'Dosey asks for each one in turn. If Settings opens, switch it on and come back.';

  @override
  String get allSet => 'All set';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String onboardingStep(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Step $currentString of $totalString';
  }

  @override
  String get navMore => 'More';

  @override
  String get moreDoctorsHint => 'Your doctors and appointments';

  @override
  String get moreRecordsHint => 'Prescriptions, reports and invoices';

  @override
  String get moreExpensesHint => 'Spending and medicine costs';

  @override
  String get moreSettingsHint => 'Language and preferences';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get sameAsLastMonth => 'Same as last month';

  @override
  String get expensesEmptyBody =>
      'Track pharmacy bills, doctor fees and tests in one place.';

  @override
  String spentIn(String month) {
    return 'Spent in $month';
  }

  @override
  String lastMonthsTrend(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Spending over the last $countString months';
  }

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsReminders => 'Reminders & alarms';

  @override
  String get settingsPermissions => 'Alarm permissions';

  @override
  String get permissionsAllAllowed => 'All allowed';

  @override
  String get settingsSupport => 'Help & support';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get contactSupportHint =>
      'Questions, bugs or ideas: we read every email';

  @override
  String get rateApp => 'Rate Dosey';

  @override
  String get rateAppHint => 'It helps other people find the app';

  @override
  String get settingsAbout => 'About & legal';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicyHint => 'Your data stays on your phone';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get medicalDisclaimer => 'Medical disclaimer';

  @override
  String get medicalDisclaimerHint =>
      'Dosey is not a substitute for your doctor';

  @override
  String get licenses => 'Open-source licences';

  @override
  String get couldNotOpen => 'Couldn\'t open that. Please try again.';

  @override
  String get supportEmailSubject => 'Dosey support';

  @override
  String get privacyShortTitle => 'In short';

  @override
  String get privacyShortBody =>
      'Dosey has no account, no ads and no analytics. Everything you enter stays on your phone.';

  @override
  String get privacyStoredTitle => 'What Dosey stores';

  @override
  String get privacyStoredBody =>
      'Medicines, reminders, dose history, doctors, expenses and the photos you add to records. They are saved in the app\'s private storage on this device only.';

  @override
  String get privacyScanTitle => 'Prescription scanning';

  @override
  String get privacyScanBody =>
      'Text recognition runs on your phone — Google ML Kit on Android, Apple\'s built-in text recognition on iPhone — and the photo is not uploaded. On Android, ML Kit may send limited diagnostic information to Google, as described in Google\'s ML Kit terms.';

  @override
  String get privacyPermissionsTitle => 'Permissions';

  @override
  String get privacyPermissionsBody =>
      'Notifications and alarm permissions are used only to ring your reminders. The camera and photo library are used only when you add a picture.';

  @override
  String get privacySharingTitle => 'Sharing';

  @override
  String get privacySharingBody =>
      'Dosey does not sell or share your data. Nothing leaves your phone unless you choose to send it, for example by emailing support.';

  @override
  String get privacyDeleteTitle => 'Deleting your data';

  @override
  String get privacyDeleteBody =>
      'Delete any item inside the app, delete everything at once in Settings › Delete all data, or uninstall Dosey.';

  @override
  String get privacyChildrenTitle => 'Children';

  @override
  String get privacyChildrenBody =>
      'Dosey is meant for adults and caregivers, and is not directed at children under 13.';

  @override
  String get termsUseTitle => 'Using Dosey';

  @override
  String get termsUseBody =>
      'Dosey helps you remember medicines and keep health records. You are responsible for the information you enter and for checking that reminders match your prescription.';

  @override
  String get termsRemindersTitle => 'Reminders';

  @override
  String get termsRemindersBody =>
      'Dosey works hard to ring on time, but phone settings, battery savers or system updates can delay or block alarms. Don\'t rely on Dosey alone for critical medicines.';

  @override
  String get termsWarrantyTitle => 'No warranty';

  @override
  String get termsWarrantyBody =>
      'Dosey is provided as is, without warranties. To the extent the law allows, we are not liable for missed doses or other losses from using the app.';

  @override
  String get termsChangesTitle => 'Changes';

  @override
  String get termsChangesBody =>
      'These terms may be updated; the date above shows the latest version.';

  @override
  String get disclaimerAdviceTitle => 'Not medical advice';

  @override
  String get disclaimerAdviceBody =>
      'Dosey is a reminder and record-keeping tool, not a medical device. It does not diagnose, treat or give medical advice.';

  @override
  String get disclaimerDoctorTitle => 'Follow your doctor';

  @override
  String get disclaimerDoctorBody =>
      'Always follow your doctor\'s or pharmacist\'s instructions. Check every scanned prescription carefully, because text recognition can misread names and doses.';

  @override
  String get disclaimerEmergencyTitle => 'Emergencies';

  @override
  String get disclaimerEmergencyBody =>
      'In an emergency, contact your doctor or local emergency services immediately.';

  @override
  String permissionsMissing(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString need attention',
      one: '1 needs attention',
    );
    return '$_temp0';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String privacyContactBody(String email) {
    return 'Questions about privacy? Email $email.';
  }

  @override
  String get settingsYourData => 'Your data';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataHint =>
      'Medicines, reminders, records, photos, expenses and health logs';

  @override
  String get deleteAllTitle => 'Delete all your data?';

  @override
  String get deleteAllBody =>
      'Every medicine, reminder, dose history, doctor, record, photo, expense and blood pressure and blood sugar reading on this phone will be deleted, and all alarms will stop. Your language and theme are kept.';

  @override
  String get deleteAllConfirmTitle => 'Are you sure?';

  @override
  String get deleteAllConfirmBody =>
      'This can\'t be undone. Dosey keeps no backup or cloud copy of your data.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get allDataDeleted => 'All your data was deleted';

  @override
  String get continueLabel => 'Continue';

  @override
  String get slotMorning => 'Morning';

  @override
  String get slotLunch => 'Lunch';

  @override
  String get slotDinner => 'Dinner';

  @override
  String get slotBedtime => 'Bedtime';

  @override
  String get quickTimesHint =>
      'Tap to add or remove. Tap a time below to change it or its amount.';

  @override
  String get ringAsAlarm => 'Ring as an alarm';

  @override
  String get ringAsAlarmHint =>
      'Full-screen alarm that rings even on silent. Turn off for a quiet notification.';

  @override
  String get medicinePickerEmpty => 'You haven\'t added any medicines yet';

  @override
  String get medicinePickerEmptyHint =>
      'Add the medicine first. Its intake times become reminders automatically, so you may not need a separate one.';

  @override
  String get addNewMedicine => 'Add new medicine';

  @override
  String get stripsPerBox => 'Strips per box';

  @override
  String get addOneBox => '+1 box';

  @override
  String get addOneStrip => '+1 strip';

  @override
  String get refillAlert => 'Refill alert';

  @override
  String get refillAlertNeedsStock =>
      'Enter your stock above to get a refill alert.';

  @override
  String unitsPerStrip(String unit) {
    return 'Per strip ($unit)';
  }

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$countString days left',
      one: '~1 day left',
      zero: 'Runs out today',
    );
    return '$_temp0';
  }

  @override
  String refillAlertDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days before it runs out',
      one: '1 day before it runs out',
    );
    return '$_temp0';
  }

  @override
  String refillAlertUnits(String amount, String unit) {
    return 'At your current dose that\'s about $amount $unit.';
  }

  @override
  String lowStockTitle(String name) {
    return '$name is running low';
  }

  @override
  String lowStockBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'About $countString days left. Time to buy more.',
      one: 'About 1 day left. Time to buy more.',
      zero: 'It runs out today. Time to buy more.',
    );
    return '$_temp0';
  }

  @override
  String get editThisTime => 'Edit this time';

  @override
  String get deleteThisTime => 'Delete this time';

  @override
  String deleteThisTimeBody(String time, String name) {
    return 'The $time reminder for $name will be deleted. Its other times stay.';
  }

  @override
  String get specMedicine => 'Medicine';

  @override
  String get specGeneralPhysician => 'General physician';

  @override
  String get specCardiology => 'Cardiology (heart)';

  @override
  String get specEndocrinology => 'Diabetes & hormones';

  @override
  String get specPaediatrics => 'Child specialist';

  @override
  String get specGynaecology => 'Gynaecology & obstetrics';

  @override
  String get specSurgery => 'General surgery';

  @override
  String get specOrthopaedics => 'Bone & joint (orthopaedics)';

  @override
  String get specNeurology => 'Neurology (brain & nerves)';

  @override
  String get specNephrology => 'Kidney (nephrology)';

  @override
  String get specGastroenterology => 'Stomach & liver';

  @override
  String get specPulmonology => 'Chest & asthma';

  @override
  String get specEnt => 'Ear, nose & throat';

  @override
  String get specEye => 'Eye';

  @override
  String get specDermatology => 'Skin & VD';

  @override
  String get specPsychiatry => 'Psychiatry (mental health)';

  @override
  String get specUrology => 'Urology';

  @override
  String get specOncology => 'Cancer (oncology)';

  @override
  String get specRheumatology => 'Rheumatology (arthritis)';

  @override
  String get specDentistry => 'Dentist';

  @override
  String get specPhysicalMedicine => 'Physical medicine & rehab';

  @override
  String get specNutrition => 'Nutritionist';

  @override
  String get doctorSpecialtyHint => 'Type or pick from the list';

  @override
  String get doctorClinicHint => 'Search hospitals & clinics';

  @override
  String get scanDoctorTitle => 'Doctor on this prescription';

  @override
  String get scanDoctorSave => 'Save this doctor';

  @override
  String get scanDoctorSaveHint =>
      'Adds them to Doctors and links these medicines to them.';

  @override
  String get scanDoctorLinked =>
      'Matches a doctor you\'ve saved, so these medicines are linked to them.';

  @override
  String headerMedicinesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString medicines',
      one: '1 medicine',
      zero: 'No medicines yet',
    );
    return '$_temp0';
  }

  @override
  String headerRemindersCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reminders',
      one: '1 reminder',
      zero: 'No reminders yet',
    );
    return '$_temp0';
  }

  @override
  String headerDoctorsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString doctors',
      one: '1 doctor',
      zero: 'No doctors yet',
    );
    return '$_temp0';
  }

  @override
  String headerRecordsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString records',
      one: '1 record',
      zero: 'No records yet',
    );
    return '$_temp0';
  }

  @override
  String get addSheetHeader => 'Quick\nAdd';

  @override
  String get moreSheetHeader => 'Menu\nMore';

  @override
  String get moreSheetSubtitle => 'Doctors, records, health logs and more';

  @override
  String get unitTabletPlural => 'tablets';

  @override
  String get unitCapsulePlural => 'capsules';

  @override
  String get unitMlPlural => 'ml';

  @override
  String get unitInjectionPlural => 'units';

  @override
  String get unitDropPlural => 'drops';

  @override
  String get unitPuffPlural => 'puffs';

  @override
  String get unitApplicationPlural => 'applications';

  @override
  String get unitDosePlural => 'doses';

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameBody =>
      'Optional — you can skip this. Your name stays on this phone.';

  @override
  String get yourName => 'Your name';

  @override
  String get skip => 'Skip';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsAddName => 'Add your name';

  @override
  String get settingsNameHint => 'Only on this phone';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get exitTitle => 'Exit Dosey?';

  @override
  String get exitBody =>
      'Your reminders will still ring on time, even with the app closed.';

  @override
  String get exitStay => 'Stay';

  @override
  String get exitConfirm => 'Exit';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'What you typed here will be lost.';

  @override
  String get discardKeep => 'Keep editing';

  @override
  String get discardConfirm => 'Discard';

  @override
  String alarmGroupNotifTitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Time for $countString medicines',
      one: 'Time for 1 medicine',
    );
    return '$_temp0';
  }

  @override
  String alarmGroupCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString medicines',
      one: '1 medicine',
    );
    return '$_temp0';
  }

  @override
  String get notifAllTaken => 'All taken';

  @override
  String get alarmMarkAllTaken => 'All taken';

  @override
  String get bpTitle => 'Your\nBlood pressure';

  @override
  String get bpShortTitle => 'Blood pressure';

  @override
  String get moreBpHint => 'Log readings and see your trend';

  @override
  String get bpAdd => 'Add reading';

  @override
  String get bpEditTitle => 'Edit reading';

  @override
  String get bpEmpty => 'No readings yet';

  @override
  String get bpEmptyHint =>
      'Write down each blood pressure check to see how it changes over time.';

  @override
  String get bpLatest => 'Latest reading';

  @override
  String get bpSystolic => 'Systolic (upper)';

  @override
  String get bpDiastolic => 'Diastolic (lower)';

  @override
  String get bpPulse => 'Pulse (optional)';

  @override
  String get bpMeasuredAt => 'Measured at';

  @override
  String get bpNote => 'Note';

  @override
  String get bpNoteHint => 'e.g. after a walk, left arm';

  @override
  String get bpAverage7 => '7-day average';

  @override
  String get bpTrend => 'Trend';

  @override
  String get bpHistory => 'History';

  @override
  String get bpSaved => 'Reading saved';

  @override
  String get bpDeleteBody => 'This reading will be deleted.';

  @override
  String get bpDiastolicHigher => 'Must be lower than the upper number';

  @override
  String get bpLow => 'Low';

  @override
  String get bpNormal => 'Normal';

  @override
  String get bpElevated => 'Elevated';

  @override
  String get bpStage1 => 'High · stage 1';

  @override
  String get bpStage2 => 'High · stage 2';

  @override
  String get bpCrisis => 'Very high';

  @override
  String get bpCrisisHint =>
      'Very high. If you also have chest pain, shortness of breath, weakness or trouble seeing or speaking, get emergency care now.';

  @override
  String get bpDisclaimer =>
      'Categories follow the American Heart Association guide for adults. This isn\'t a diagnosis — talk to your doctor about your readings.';

  @override
  String get bpSystolicLegend => 'Upper';

  @override
  String get bpDiastolicLegend => 'Lower';

  @override
  String bpCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString readings',
      one: '1 reading',
      zero: 'No readings yet',
    );
    return '$_temp0';
  }

  @override
  String bpValue(String systolic, String diastolic) {
    return '$systolic/$diastolic';
  }

  @override
  String bpPulseValue(String pulse) {
    return 'Pulse $pulse';
  }

  @override
  String numberRange(String min, String max) {
    return 'Enter a number from $min to $max';
  }

  @override
  String get iosSoundTitle => 'iPhone sound';

  @override
  String get iosSoundOn => 'Alarm sound is on';

  @override
  String get iosSoundOff =>
      'Sounds are off for Dosey notifications. Turn on Sounds in Settings to hear your reminders.';

  @override
  String get iosCriticalOn => 'Rings even in silent mode and Focus';

  @override
  String get iosCriticalOff =>
      'In silent mode or Focus, your iPhone mutes reminders. Keep the ringer on so you hear them.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get sugarTitle => 'Your\nBlood sugar';

  @override
  String get sugarShortTitle => 'Blood sugar';

  @override
  String get moreSugarHint => 'Log glucose checks and see your trend';

  @override
  String get sugarAdd => 'Add reading';

  @override
  String get sugarEditTitle => 'Edit reading';

  @override
  String get sugarEmpty => 'No readings yet';

  @override
  String get sugarEmptyHint =>
      'Write down each glucometer check to see how your sugar changes over time.';

  @override
  String get sugarValueLabel => 'Blood sugar (mmol/L)';

  @override
  String get sugarWhen => 'When was it taken?';

  @override
  String get sugarFasting => 'Fasting';

  @override
  String get sugarBeforeMeal => 'Before meal';

  @override
  String get sugarAfterMeal => '2 h after meal';

  @override
  String get sugarRandom => 'Random';

  @override
  String get sugarBedtime => 'Bedtime';

  @override
  String get sugarVeryLow => 'Very low';

  @override
  String get sugarLow => 'Low';

  @override
  String get sugarInRange => 'In range';

  @override
  String get sugarHigh => 'High';

  @override
  String get sugarVeryHigh => 'Very high';

  @override
  String get sugarVeryLowHint =>
      'Very low. Take 15 g of fast sugar (glucose, juice or sweets) now and check again in 15 minutes. Get help if it stays low or you feel unwell.';

  @override
  String get sugarDisclaimer =>
      'Ranges follow the American Diabetes Association guide for adults. Your doctor may set different targets for you.';

  @override
  String get sugarLatest => 'Latest reading';

  @override
  String get sugarAverage7 => '7-day average';

  @override
  String get sugarSaved => 'Reading saved';

  @override
  String get sugarDeleteBody => 'This reading will be deleted.';

  @override
  String get sugarNoteHint => 'e.g. after a walk, felt dizzy';

  @override
  String sugarCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString readings',
      one: '1 reading',
      zero: 'No readings yet',
    );
    return '$_temp0';
  }

  @override
  String sugarMgDl(String value) {
    return '≈ $value mg/dL';
  }

  @override
  String decimalRange(String min, String max) {
    return 'Enter a value from $min to $max';
  }

  @override
  String get onboardingEssentialHintIos => 'Notifications are required.';

  @override
  String get widgetNext => 'Next medicine';

  @override
  String get widgetDue => 'Due now';

  @override
  String get widgetEmpty => 'No medicines coming up';

  @override
  String get widgetToday => 'Today';

  @override
  String get widgetTomorrow => 'Tomorrow';

  @override
  String get widgetName => 'Next medicine';

  @override
  String get widgetDescription => 'Your next dose: medicine, time and amount.';

  @override
  String get takenLate => 'Taken late';

  @override
  String get markAllTakenLate => 'Mark all as taken late';

  @override
  String get missedDosesTitle => 'Missed doses';

  @override
  String missedDosesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString missed doses',
      one: '1 missed dose',
    );
    return '$_temp0';
  }

  @override
  String get missedDosesHint => 'Took it after all? Tap to mark it taken late.';

  @override
  String get missedDosesBody =>
      'Took a dose later than planned? Mark it here so your history and stock stay accurate.';

  @override
  String todayAt(String time) {
    return 'Today · $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday · $time';
  }

  @override
  String get courseDuration => 'Course duration';

  @override
  String get courseMonth => '1 month';

  @override
  String get courseCustom => 'Custom';

  @override
  String courseDayOf(int day, int total) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Day $dayString of $totalString';
  }

  @override
  String courseDaysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days left',
      one: '1 day left',
      zero: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String get courseComplete => 'Course complete';

  @override
  String courseStarts(String date) {
    return 'Starts $date';
  }

  @override
  String get alarmPreviousMissed => 'Previous dose missed';

  @override
  String get historyTitle => 'Dose\nHistory';

  @override
  String get historyLink => 'Dose history';

  @override
  String get moreHistoryHint => 'Every dose: taken, skipped or missed';

  @override
  String historyLastDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $countString days',
    );
    return '$_temp0';
  }

  @override
  String get historyAdherence => 'Doses taken';

  @override
  String historyAdherenceHint(int taken, int total) {
    final intl.NumberFormat takenNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String takenString = takenNumberFormat.format(taken);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$takenString of $totalString doses taken, on time or late';
  }

  @override
  String get historyEmpty => 'No doses yet';

  @override
  String get historyEmptyHint =>
      'Doses show up here once their time has passed.';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyMarkLateBody =>
      'Took this dose later? It will count as taken late and come out of your stock.';

  @override
  String get remindLater => 'Remind me later';

  @override
  String get remindLaterTitle => 'When should I remind you?';

  @override
  String get remindLaterHint =>
      'Can\'t take it right now? It will ring again then. Nothing counts as missed until after that.';

  @override
  String remindLaterIn(String duration) {
    return 'In $duration';
  }

  @override
  String get recordNoPages => 'No pages yet';

  @override
  String get recordNoPagesHint => 'Tap to add a photo of the document.';

  @override
  String headsUpTitle(String title) {
    return 'Coming up: $title';
  }

  @override
  String get headsUpLabel => 'Also remind me before';

  @override
  String get headsUpNone => 'No';

  @override
  String headsUpBefore(String duration) {
    return '$duration before';
  }

  @override
  String get backupTitle => 'Back up my data';

  @override
  String backupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupNever => 'Not backed up yet: save everything to one file';

  @override
  String get backupShareSubject => 'Dosey backup';

  @override
  String get backupFailed => 'Couldn\'t make the backup. Please try again.';

  @override
  String get restoreTitle => 'Restore from a backup';

  @override
  String get restoreHint => 'Replace everything here with a backup file';

  @override
  String get restoreConfirmTitle => 'Replace all data?';

  @override
  String get restoreConfirmBody =>
      'Everything in Dosey now will be replaced by this backup: medicines, reminders, history, records and photos. This can\'t be undone.';

  @override
  String get restoreConfirm => 'Restore';

  @override
  String get restoreDone => 'Backup restored';

  @override
  String get restoreNotABackup => 'That file isn\'t a Dosey backup.';

  @override
  String get restoreTooNew =>
      'This backup is from a newer version of Dosey. Update the app first.';

  @override
  String get reportTitle => 'Health report';

  @override
  String get reportShowDoctor => 'Show your doctor';

  @override
  String get reportHeader => 'For your\nDoctor';

  @override
  String get reportMoreHint => 'A one-page summary to share before a visit';

  @override
  String reportPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String reportMadeOn(String date) {
    return 'Made with Dosey on $date. Recorded by the patient.';
  }

  @override
  String get reportMedicines => 'Current medicines';

  @override
  String get reportNoMedicines => 'No current medicines';

  @override
  String reportAdherence(int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return 'Doses taken, last $daysString days';
  }

  @override
  String reportAdherenceDetail(int taken, int total, int missed, int skipped) {
    final intl.NumberFormat takenNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String takenString = takenNumberFormat.format(taken);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);
    final intl.NumberFormat missedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String missedString = missedNumberFormat.format(missed);
    final intl.NumberFormat skippedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String skippedString = skippedNumberFormat.format(skipped);

    return '$takenString of $totalString taken · $missedString missed · $skippedString skipped';
  }

  @override
  String reportLatest(String value) {
    return 'Latest: $value';
  }

  @override
  String reportAverage(int days, String value) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return '$daysString-day average: $value';
  }

  @override
  String get reportNoReadings => 'No readings in this period';

  @override
  String get reportShare => 'Share report';

  @override
  String get reportShareFailed =>
      'Couldn\'t share the report. Please try again.';

  @override
  String get appLockTitle => 'App lock';

  @override
  String get appLockHint =>
      'Ask for fingerprint, face or phone PIN to open Dosey';

  @override
  String get appLockReason => 'Unlock Dosey to see your health records';

  @override
  String get appLockLocked => 'Dosey is locked';

  @override
  String get appLockLockedHint => 'Your health records are protected.';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockUnavailable =>
      'Set a screen lock (PIN, pattern or fingerprint) on your phone first.';

  @override
  String get profileMe => 'Me';

  @override
  String get profilesTitle => 'Family profiles';

  @override
  String get profilesHint => 'Keep medicines for the people you look after';

  @override
  String get profileSwitchTitle => 'Whose medicines?';

  @override
  String get profileAdd => 'Add a family member';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameHint => 'e.g. Ammu';

  @override
  String get profileRename => 'Rename';

  @override
  String get profileDelete => 'Delete profile';

  @override
  String profileDeleteBody(String name) {
    return 'All of $name\'s medicines, reminders, history, records, expenses and readings will be deleted. This can\'t be undone.';
  }

  @override
  String get profileManage => 'Manage profiles';

  @override
  String get profileYou => 'You';

  @override
  String notifForProfile(String name, String title) {
    return '$name: $title';
  }

  @override
  String get offlineTitle => 'No internet connection';

  @override
  String get offlineBody =>
      'Family Sharing needs the internet to sync with your family. Connect to Wi-Fi or mobile data and try again.\n\nYour medicines, reminders and everything else keep working offline.';

  @override
  String get offlineRetry => 'Try again';

  @override
  String get offlineDismiss => 'OK';

  @override
  String fsResetEmailSent(String email) {
    return 'Password reset email sent to $email!';
  }

  @override
  String get fsAccountCreated =>
      'Account created! Check your email to verify it.';

  @override
  String get fsSignedIn => 'Signed in successfully!';

  @override
  String get fsSignedInGoogle => 'Signed in with Google!';

  @override
  String get fsSignedInApple => 'Signed in with Apple!';

  @override
  String get fsSignedOut => 'Signed out successfully.';

  @override
  String get fsDeleteAccountTitle => 'Delete Account?';

  @override
  String get fsDeleteAccountBody =>
      'This will permanently delete your cloud account and unlink all family members. Your local medicine data on this device will remain intact.';

  @override
  String get fsDeleteAccount => 'Delete Account';

  @override
  String get fsAccountDeleted => 'Account deleted.';

  @override
  String get fsYourDisplayName => 'Your Display Name';

  @override
  String get fsDisplayNameHint => 'e.g. Rahat, Dad, Mom';

  @override
  String fsNameUpdated(String name) {
    return 'Name updated to \"$name\"';
  }

  @override
  String fsNameUpdateFailed(String error) {
    return 'Failed to update name: $error';
  }

  @override
  String get fsEnterSixCharCode => 'Please enter a 6-character share code.';

  @override
  String get fsRequestSent =>
      'Connection request sent! Waiting for your family member to accept.';

  @override
  String fsLinkAccepted(String name) {
    return 'Link accepted! $name is now linked.';
  }

  @override
  String get fsCaregiver => 'Caregiver';

  @override
  String get fsRequestDeclined => 'Link request declined.';

  @override
  String get fsNothingToSync =>
      'No medicines found in today\'s schedule to sync.';

  @override
  String fsSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced $count medicines to the cloud! ✅',
      one: 'Synced 1 medicine to the cloud! ✅',
    );
    return '$_temp0';
  }

  @override
  String get fsOverline => 'FAMILY SHARING';

  @override
  String get fsTitle => 'Caregiver & Family Mode';

  @override
  String get fsFamilyAccount => 'Family Account';

  @override
  String get fsCloudActive => 'Cloud Active';

  @override
  String get fsMyCode => 'My Code';

  @override
  String get fsEnterCode => 'Enter Code';

  @override
  String get fsSignOut => 'Sign Out';

  @override
  String get fsShareTitle => 'Share Your Doses & Reminders';

  @override
  String get fsShareSubtitle =>
      'Let family members monitor your medication adherence';

  @override
  String get fsStepGenerateTitle => 'Generate your 6-character code below';

  @override
  String get fsStepGenerateBody =>
      'Your unique code connects caregiver devices.';

  @override
  String get fsStepSendTitle => 'Send it to your caregiver or family member';

  @override
  String get fsStepSendBody => 'They enter this code in their Dosey app.';

  @override
  String get fsStepApproveTitle => 'Approve incoming link requests';

  @override
  String get fsStepApproveBody =>
      'Review and accept requests from your family members.';

  @override
  String get fsGenerateCode => 'Generate Share Code';

  @override
  String fsIncomingRequests(int count) {
    return 'Incoming Link Requests ($count)';
  }

  @override
  String get fsFamilyCaregiver => 'Family Caregiver';

  @override
  String fsWantsToConnect(String code) {
    return 'Wants to connect using code $code';
  }

  @override
  String get fsDecline => 'Decline';

  @override
  String get fsAccept => 'Accept';

  @override
  String fsLinkedCaregivers(int count) {
    return 'Linked Caregivers ($count)';
  }

  @override
  String fsActiveSyncCode(String code) {
    return 'Active sync • Code: $code';
  }

  @override
  String get fsUnlink => 'Unlink';

  @override
  String get fsUnlinkCaregiverTitle => 'Unlink Caregiver';

  @override
  String fsUnlinkCaregiverBody(String name) {
    return 'Are you sure you want to unlink $name? They will no longer be able to see your adherence schedule.';
  }

  @override
  String get fsThisCaregiver => 'this caregiver';

  @override
  String get fsSyncNow => 'Sync Medicines to Caregivers Now';

  @override
  String get fsYourCodeLabel => 'YOUR 6-CHARACTER SHARE CODE';

  @override
  String get fsCopyCode => 'Copy Code';

  @override
  String fsCodeCopied(String code) {
    return 'Code \"$code\" copied to clipboard!';
  }

  @override
  String get fsShareCode => 'Share Code';

  @override
  String fsShareMessage(String code) {
    return 'Here is my Dosey family share code: $code\n\nEnter it in your Dosey app under Settings > Caregiver & Family Mode to link our accounts.';
  }

  @override
  String get fsCodeValidity =>
      'Share this code with your family member. Valid for 7 days.';

  @override
  String get fsPasteCode => 'Paste Code';

  @override
  String get fsLinkTitle => 'Link to a Family Member';

  @override
  String get fsLinkSubtitle => 'Enter their 6-character code to link profiles';

  @override
  String get fsStepAskTitle => 'Ask family member for their code';

  @override
  String get fsStepAskBody => 'Found under \"My Code\" on their phone.';

  @override
  String get fsStepEnterTitle => 'Enter or paste the code below';

  @override
  String get fsStepEnterBody => 'Tap the boxes or use the Paste button.';

  @override
  String get fsStepWaitTitle => 'Wait for their approval';

  @override
  String get fsStepWaitBody => 'They must accept your link request to sync.';

  @override
  String get fsSendRequest => 'Send Link Request';

  @override
  String fsPendingApproval(int count) {
    return 'Pending Approval ($count)';
  }

  @override
  String get fsFamilyMember => 'Family Member';

  @override
  String fsAwaitingApproval(String code) {
    return 'Awaiting approval • Code: $code';
  }

  @override
  String fsConnectedMembers(int count) {
    return 'Connected Family Members ($count)';
  }

  @override
  String get fsActiveSyncTap => 'Active sync • Tap to view schedule';

  @override
  String get fsRemoveMemberTitle => 'Remove Family Member';

  @override
  String fsStopMonitoring(String name) {
    return 'Are you sure you want to stop monitoring $name?';
  }

  @override
  String fsStopMonitoringLong(String name) {
    return 'Are you sure you want to stop monitoring $name? You will no longer receive their adherence updates.';
  }

  @override
  String get fsThisMember => 'this family member';

  @override
  String get fsRemove => 'Remove';

  @override
  String get fsIntro =>
      'Keep family members and caregivers in the loop. Link securely to monitor adherence and share dose reminders.';

  @override
  String get fsContinueGoogle => 'Continue with Google';

  @override
  String get fsContinueApple => 'Continue with Apple';

  @override
  String get fsOrEmail => 'or with email';

  @override
  String get fsSignIn => 'Sign In';

  @override
  String get fsCreateAccount => 'Create Account';

  @override
  String get fsNameOptional => 'Your Name (Optional)';

  @override
  String get fsFullNameHint => 'e.g. Rahat Ahmed';

  @override
  String get fsEmailRequired => 'Email is required';

  @override
  String get fsEmailInvalid => 'Enter a valid email address';

  @override
  String get fsPassword => 'Password';

  @override
  String get fsPasswordNewHint => 'At least 6 characters';

  @override
  String get fsPasswordHint => 'Enter your password';

  @override
  String get fsPasswordRequired => 'Password is required';

  @override
  String get fsPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get fsForgotPassword => 'Forgot Password?';

  @override
  String get fsOfflineFirst =>
      'Dosey remains 100% offline-first. Your local medicines and reminders stay safe on your device.';

  @override
  String get fsVerifyTitle => 'Verify your email';

  @override
  String fsVerifyBody(String email) {
    return 'We sent a link to $email. Open it to confirm the address, then come back and tap \"I\'ve verified\".';
  }

  @override
  String get fsYourEmail => 'your email';

  @override
  String get fsIveVerified => 'I\'ve verified';

  @override
  String get fsNotVerifiedYet =>
      'Not verified yet. Open the link in the email first (check spam too).';

  @override
  String fsVerificationSent(String email) {
    return 'Verification email sent to $email.';
  }

  @override
  String get fsResendEmail => 'Resend email';

  @override
  String get fsUseAnotherAccount => 'Use another account';

  @override
  String get fsResetTitle => 'Reset Password';

  @override
  String get fsResetBody =>
      'Enter your registered email address and we will send you a password reset link.';

  @override
  String get fsSendResetLink => 'Send Reset Link';

  @override
  String get fsBackToSignIn => 'Back to Sign In';

  @override
  String get fsEditMemberName => 'Edit Family Member Name';

  @override
  String get fsMemberNameHint => 'e.g. Dad, Mom, Rahat';

  @override
  String fsMemberRemoved(String name) {
    return 'Removed $name from monitored family members.';
  }

  @override
  String fsRemoveFailed(String error) {
    return 'Failed to remove member: $error';
  }

  @override
  String fsDoseNudgeSent(String medicine, String time) {
    return '🔔 Sent reminder for $medicine ($time)!';
  }

  @override
  String fsNudgeSent(String name) {
    return '🔔 Gentle reminder sent to $name\'s phone!';
  }

  @override
  String get fsEditMemberNameTooltip => 'Edit member name';

  @override
  String get fsRemoveMemberTooltip => 'Remove family member';

  @override
  String fsShareCodeLabel(String code) {
    return 'Share Code: $code';
  }

  @override
  String get fsLive => 'Live';

  @override
  String fsManageMedicinesFor(String name) {
    return 'Manage & Edit Medicines for $name';
  }

  @override
  String get fsTodaysSchedule => 'TODAY\'S SCHEDULE';

  @override
  String get fsSendGentleReminder => 'Send Gentle Reminder';

  @override
  String get fsScheduleLoadFailed => 'Could not load shared schedule';

  @override
  String get fsPullToRetry => 'Pull down to refresh and retry.';

  @override
  String fsRemoveFromMonitoring(String name) {
    return 'Remove $name from Monitoring';
  }

  @override
  String get fsTodaysAdherence => 'Today\'s Adherence';

  @override
  String fsDosesCompleted(int taken, int total) {
    return '$taken of $total doses completed';
  }

  @override
  String get fsPending => 'Pending';

  @override
  String get fsOneDose => '1 dose';

  @override
  String get fsNudge => 'Nudge';

  @override
  String get fsNudged => 'Nudged';

  @override
  String get fsNoDosesToday => 'No Shared Doses Found Today';

  @override
  String fsNoDosesBody(String name) {
    return 'When $name opens Dosey or logs doses, their schedule will appear here automatically.';
  }

  @override
  String get fsAddDoseTime => 'Please add at least one dose time.';

  @override
  String fsSavedSynced(String name) {
    return '⚡ Saved and synced to $name\'s phone!';
  }

  @override
  String fsError(String error) {
    return 'Error: $error';
  }

  @override
  String fsEditMedicineFor(String name) {
    return 'Edit Medicine for $name';
  }

  @override
  String fsAddMedicineFor(String name) {
    return 'Add Medicine for $name';
  }

  @override
  String fsSyncingTo(String name) {
    return 'Syncing to $name\'s phone...';
  }

  @override
  String get fsUpdateSync => 'Update & Sync';

  @override
  String fsSaveSyncTo(String name) {
    return 'Save & Sync to $name';
  }

  @override
  String get fsMedicineName => 'MEDICINE NAME';

  @override
  String get fsMedicineNameHint => 'e.g. Napa Extra, Metformin, Insulin';

  @override
  String get fsNameRequired => 'Name is required';

  @override
  String get fsMedicineForm => 'MEDICINE FORM';

  @override
  String get fsWhenToTake => 'WHEN TO TAKE';

  @override
  String fsDosingTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'DOSE TIMES ($count TIMES A DAY)',
      one: 'DOSE TIME (ONCE A DAY)',
    );
    return '$_temp0';
  }

  @override
  String fsDoseNumber(int number) {
    return 'Dose $number';
  }

  @override
  String get fsAddIntakeTime => 'Add Another Intake Time';

  @override
  String get fsDoseAmount => 'DOSE AMOUNT';

  @override
  String get fsInitialStock => 'INITIAL STOCK';

  @override
  String get fsStartDate => 'START DATE';

  @override
  String get fsDoctorNotes => 'DOCTOR NOTES / INSTRUCTIONS';

  @override
  String get fsDoctorNotesHint => 'e.g. Take with a glass of water';

  @override
  String fsRemoveMedicineConfirm(String medicine, String name) {
    return 'Are you sure you want to remove \"$medicine\" from $name\'s phone schedule?';
  }

  @override
  String fsMedicineRemoved(String medicine) {
    return '$medicine removed and synced.';
  }

  @override
  String fsManageMedicinesTitle(String name) {
    return 'Manage $name\'s Medicines';
  }

  @override
  String get fsLiveCaregiverSync => 'Live Caregiver Sync';

  @override
  String fsScheduledMedicines(int count) {
    return 'SCHEDULED MEDICINES ($count)';
  }

  @override
  String get fsPrescriptionsLoadFailed => 'Could not load prescriptions';

  @override
  String get fsNoMedicinesYet => 'No medicines configured yet';

  @override
  String fsNoMedicinesBody(String name) {
    return 'Add prescriptions for $name. Doses and timings will instantly sync to their phone alarms.';
  }

  @override
  String get fsFeatureAlarmTitle => 'Auto-Alarm Sync';

  @override
  String get fsFeatureAlarmBody =>
      'Configures phone alarms on their device automatically';

  @override
  String get fsFeatureAdherenceTitle => 'Live Adherence';

  @override
  String get fsFeatureAdherenceBody =>
      'Monitor when doses are taken, skipped or missed';

  @override
  String get fsFeatureNudgeTitle => '1-Tap Dose Nudges';

  @override
  String get fsFeatureNudgeBody =>
      'Send gentle reminders directly to their lock screen';

  @override
  String get fsDailyTimings => 'Daily Timings: ';

  @override
  String fsStockRemaining(String count) {
    return 'Stock remaining: $count units';
  }

  @override
  String get fsCaregiverMonitoring => 'CAREGIVER MONITORING';

  @override
  String get fsTapToViewSchedule => 'Tap to view today\'s schedule';

  @override
  String get fsConnected => 'Family Sharing Connected';

  @override
  String get fsSettingsHint => 'Link with family & caregivers';

  @override
  String get fsActive => 'Active';

  @override
  String get authErrUserNotFound => 'No account found with this email address.';

  @override
  String get authErrWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authErrEmailInUse => 'An account with this email already exists.';

  @override
  String get authErrInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get authErrUserDisabled => 'This account has been disabled.';

  @override
  String get authErrTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrNotAllowed => 'This sign-in method is not enabled.';

  @override
  String get authErrNetwork => 'Network error. Please check your connection.';

  @override
  String get authErrInvalidCredential =>
      'Invalid email or password. Please check and retry.';

  @override
  String get authErrRecentLogin =>
      'Please sign out and sign in again before deleting your account.';

  @override
  String get authErrGeneric => 'Authentication error occurred.';

  @override
  String get authErrEraseFailed =>
      'Could not reach the server to erase your data. Please check your connection and try again.';

  @override
  String authErrGoogle(String code, String message) {
    return 'Google Sign-In failed ($code: $message). You can also create an account with Email & Password below.';
  }

  @override
  String get authErrConfig => 'Configuration error';

  @override
  String get appTagline => 'Offline-first • Privacy conscious';
}
