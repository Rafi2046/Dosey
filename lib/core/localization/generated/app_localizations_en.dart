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
  String get alarmMarkTaken => 'Medicine Taken';

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
  String get timeDuration => 'Time Duration';

  @override
  String get medicineTime => 'Medicine Time';

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
  String get changeSetting => 'Change Setting';

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
      'Text recognition runs on your phone using Google ML Kit, and the photo is not uploaded. ML Kit may send limited diagnostic information to Google, as described in Google\'s ML Kit terms.';

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
      'Medicines, reminders, records, photos and expenses';

  @override
  String get deleteAllTitle => 'Delete all your data?';

  @override
  String get deleteAllBody =>
      'Every medicine, reminder, dose history, doctor, record, photo and expense on this phone will be deleted, and all alarms will stop. Your language and theme are kept.';

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
  String get moreSheetSubtitle => 'Doctors, records, expenses and settings';

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
}
