import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dosey'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get navMedicines;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get navDoctors;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @addSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get addSheetTitle;

  /// No description provided for @alarmMarkTaken.
  ///
  /// In en, this message translates to:
  /// **'Medicine Taken'**
  String get alarmMarkTaken;

  /// No description provided for @alarmDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get alarmDone;

  /// No description provided for @alarmSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get alarmSnooze;

  /// No description provided for @alarmSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip this time'**
  String get alarmSkip;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled. Enjoy your day!'**
  String get nothingScheduled;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medicine\nReminders'**
  String get dashboardTitle;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @snoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get snoozed;

  /// No description provided for @skipDose.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipDose;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get upcoming;

  /// No description provided for @medicineCost.
  ///
  /// In en, this message translates to:
  /// **'Medicine cost'**
  String get medicineCost;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @runningLow.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get runningLow;

  /// No description provided for @debugTestAlarm.
  ///
  /// In en, this message translates to:
  /// **'Test alarm (rings in 1–2 min)'**
  String get debugTestAlarm;

  /// No description provided for @debugTestAlarmScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled. Lock the phone and wait.'**
  String get debugTestAlarmScheduled;

  /// No description provided for @debugTestAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Test medicine'**
  String get debugTestAlarmTitle;

  /// No description provided for @debugLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get debugLoadDemo;

  /// No description provided for @debugDemoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded'**
  String get debugDemoLoaded;

  /// No description provided for @debugTestAlarmBody.
  ///
  /// In en, this message translates to:
  /// **'Take 1 tablet after breakfast'**
  String get debugTestAlarmBody;

  /// No description provided for @addDoctor.
  ///
  /// In en, this message translates to:
  /// **'Add doctor'**
  String get addDoctor;

  /// No description provided for @editDoctor.
  ///
  /// In en, this message translates to:
  /// **'Edit doctor'**
  String get editDoctor;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get doctorName;

  /// No description provided for @doctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get doctorSpecialty;

  /// No description provided for @doctorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get doctorPhone;

  /// No description provided for @doctorEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get doctorEmail;

  /// No description provided for @doctorClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic / hospital'**
  String get doctorClinic;

  /// No description provided for @doctorAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get doctorAddress;

  /// No description provided for @doctorFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get doctorFee;

  /// No description provided for @doctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get doctorNotes;

  /// No description provided for @noDoctors.
  ///
  /// In en, this message translates to:
  /// **'No doctors added'**
  String get noDoctors;

  /// No description provided for @doctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nDoctors'**
  String get doctorsTitle;

  /// No description provided for @prescribedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Prescribed medicines'**
  String get prescribedMedicines;

  /// No description provided for @doctorRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get doctorRecords;

  /// No description provided for @doctorAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get doctorAppointments;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get unarchive;

  /// No description provided for @addAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
  String get addAppointment;

  /// No description provided for @deleteDoctorBody.
  ///
  /// In en, this message translates to:
  /// **'Medicines and records stay, but will no longer be linked to this doctor.'**
  String get deleteDoctorBody;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseTitle;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get expenseQuantity;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDate;

  /// No description provided for @expenseNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get expenseNotes;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpenses;

  /// No description provided for @projectedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Projected monthly medicine cost'**
  String get projectedMonthly;

  /// No description provided for @categoryMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get categoryMedicine;

  /// No description provided for @categoryConsultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get categoryConsultation;

  /// No description provided for @categoryTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get categoryTest;

  /// No description provided for @categoryVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get categoryVaccine;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nExpenses'**
  String get expensesTitle;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @medicineCosts.
  ///
  /// In en, this message translates to:
  /// **'Projected medicine costs'**
  String get medicineCosts;

  /// No description provided for @projectedHint.
  ///
  /// In en, this message translates to:
  /// **'Based on your active medicines, their price and reminder times.'**
  String get projectedHint;

  /// No description provided for @noProjection.
  ///
  /// In en, this message translates to:
  /// **'Add a price per unit to a medicine to see projected costs.'**
  String get noProjection;

  /// No description provided for @expenseTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Napa 500mg strip'**
  String get expenseTitleHint;

  /// No description provided for @expenseMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get expenseMedicine;

  /// No description provided for @expenseDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get expenseDoctor;

  /// No description provided for @deleteExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'This expense will be removed.'**
  String get deleteExpenseBody;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineName;

  /// No description provided for @medicineStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength (e.g. 500 mg)'**
  String get medicineStrength;

  /// No description provided for @medicineForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get medicineForm;

  /// No description provided for @medicineDoseUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get medicineDoseUnit;

  /// No description provided for @medicineMeal.
  ///
  /// In en, this message translates to:
  /// **'When to take'**
  String get medicineMeal;

  /// No description provided for @medicineUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get medicineUnitPrice;

  /// No description provided for @medicineStock.
  ///
  /// In en, this message translates to:
  /// **'Stock on hand'**
  String get medicineStock;

  /// No description provided for @medicineDoctor.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by'**
  String get medicineDoctor;

  /// No description provided for @medicineStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get medicineStartDate;

  /// No description provided for @medicineEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get medicineEndDate;

  /// No description provided for @noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines added'**
  String get noMedicines;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @formTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get formTablet;

  /// No description provided for @formCapsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get formCapsule;

  /// No description provided for @formSyrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get formSyrup;

  /// No description provided for @formInjection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get formInjection;

  /// No description provided for @formDrops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get formDrops;

  /// No description provided for @formInhaler.
  ///
  /// In en, this message translates to:
  /// **'Inhaler'**
  String get formInhaler;

  /// No description provided for @formCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get formCream;

  /// No description provided for @formOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get formOther;

  /// No description provided for @unitTablet.
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get unitTablet;

  /// No description provided for @unitCapsule.
  ///
  /// In en, this message translates to:
  /// **'capsule'**
  String get unitCapsule;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitInjection.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unitInjection;

  /// No description provided for @unitDrop.
  ///
  /// In en, this message translates to:
  /// **'drop'**
  String get unitDrop;

  /// No description provided for @unitPuff.
  ///
  /// In en, this message translates to:
  /// **'puff'**
  String get unitPuff;

  /// No description provided for @unitApplication.
  ///
  /// In en, this message translates to:
  /// **'application'**
  String get unitApplication;

  /// No description provided for @unitDose.
  ///
  /// In en, this message translates to:
  /// **'dose'**
  String get unitDose;

  /// No description provided for @mealBefore.
  ///
  /// In en, this message translates to:
  /// **'Before meal'**
  String get mealBefore;

  /// No description provided for @mealWith.
  ///
  /// In en, this message translates to:
  /// **'With meal'**
  String get mealWith;

  /// No description provided for @mealAfter.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get mealAfter;

  /// No description provided for @mealAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get mealAnytime;

  /// No description provided for @medicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nMedicines'**
  String get medicinesTitle;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @chooseMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Choose Medicine\nType'**
  String get chooseMedicineType;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine details'**
  String get medicineDetails;

  /// No description provided for @medicineDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get medicineDescription;

  /// No description provided for @medicineDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'How and why to take it'**
  String get medicineDescriptionHint;

  /// No description provided for @timeDuration.
  ///
  /// In en, this message translates to:
  /// **'Time Duration'**
  String get timeDuration;

  /// No description provided for @medicineTime.
  ///
  /// In en, this message translates to:
  /// **'Medicine Time'**
  String get medicineTime;

  /// No description provided for @daysInWeek.
  ///
  /// In en, this message translates to:
  /// **'Days in a week'**
  String get daysInWeek;

  /// No description provided for @doses.
  ///
  /// In en, this message translates to:
  /// **'Doses'**
  String get doses;

  /// No description provided for @costPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Cost per month'**
  String get costPerMonth;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @reminderTimesHint.
  ///
  /// In en, this message translates to:
  /// **'Add the times you take this medicine — each one rings like an alarm.'**
  String get reminderTimesHint;

  /// No description provided for @changeSetting.
  ///
  /// In en, this message translates to:
  /// **'Change Setting'**
  String get changeSetting;

  /// No description provided for @refill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// No description provided for @refillTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a refill'**
  String get refillTitle;

  /// No description provided for @refillQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity bought'**
  String get refillQuantity;

  /// No description provided for @refillTotal.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get refillTotal;

  /// No description provided for @refillSaved.
  ///
  /// In en, this message translates to:
  /// **'Refill saved and added to expenses'**
  String get refillSaved;

  /// No description provided for @stopMedicine.
  ///
  /// In en, this message translates to:
  /// **'Stop taking'**
  String get stopMedicine;

  /// No description provided for @resumeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeMedicine;

  /// No description provided for @deleteMedicineBody.
  ///
  /// In en, this message translates to:
  /// **'Its reminders and dose history will be deleted too.'**
  String get deleteMedicineBody;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @doseTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Intake time'**
  String get doseTimeTitle;

  /// No description provided for @doseHowMany.
  ///
  /// In en, this message translates to:
  /// **'How many at this time'**
  String get doseHowMany;

  /// No description provided for @removeTime.
  ///
  /// In en, this message translates to:
  /// **'Remove this time'**
  String get removeTime;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan prescription'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill name, dose and times from a photo'**
  String get scanSubtitle;

  /// No description provided for @scanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading prescription…'**
  String get scanReading;

  /// No description provided for @scanNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No medicines found. Try a clearer, well-lit photo or fill in manually.'**
  String get scanNothingFound;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that image. Please try again.'**
  String get scanFailed;

  /// No description provided for @bulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Review medicines'**
  String get bulkTitle;

  /// No description provided for @bulkHint.
  ///
  /// In en, this message translates to:
  /// **'Found on your prescription. Check each medicine, fix anything that looks wrong, remove extras, then save them all at once.'**
  String get bulkHint;

  /// No description provided for @bulkAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another medicine'**
  String get bulkAddAnother;

  /// No description provided for @bulkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove medicine'**
  String get bulkRemove;

  /// No description provided for @bulkEmpty.
  ///
  /// In en, this message translates to:
  /// **'No medicines left. Add one or go back.'**
  String get bulkEmpty;

  /// No description provided for @bulkNoTimes.
  ///
  /// In en, this message translates to:
  /// **'No times set: this medicine will not ring.'**
  String get bulkNoTimes;

  /// No description provided for @scanFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled from prescription. Please check every field before saving.'**
  String get scanFilled;

  /// No description provided for @notifTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken ✓'**
  String get notifTaken;

  /// No description provided for @notifSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notifSnooze;

  /// No description provided for @notifSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get notifSkip;

  /// No description provided for @notifDoseSeparator.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get notifDoseSeparator;

  /// No description provided for @notifAtLocation.
  ///
  /// In en, this message translates to:
  /// **'At '**
  String get notifAtLocation;

  /// No description provided for @notifWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'With '**
  String get notifWithDoctor;

  /// No description provided for @channelGroupName.
  ///
  /// In en, this message translates to:
  /// **'Dosey reminders'**
  String get channelGroupName;

  /// No description provided for @channelMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine alarms'**
  String get channelMedicineName;

  /// No description provided for @channelMedicineDesc.
  ///
  /// In en, this message translates to:
  /// **'Rings for doses, even in Do Not Disturb'**
  String get channelMedicineDesc;

  /// No description provided for @channelAppointmentName.
  ///
  /// In en, this message translates to:
  /// **'Appointment alarms'**
  String get channelAppointmentName;

  /// No description provided for @channelAppointmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s appointment alarms'**
  String get channelAppointmentDesc;

  /// No description provided for @channelVaccineName.
  ///
  /// In en, this message translates to:
  /// **'Vaccine alarms'**
  String get channelVaccineName;

  /// No description provided for @channelVaccineDesc.
  ///
  /// In en, this message translates to:
  /// **'Vaccination alarms'**
  String get channelVaccineDesc;

  /// No description provided for @channelTestName.
  ///
  /// In en, this message translates to:
  /// **'Medical test alarms'**
  String get channelTestName;

  /// No description provided for @channelTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Lab and medical test alarms'**
  String get channelTestDesc;

  /// No description provided for @channelGentleName.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders'**
  String get channelGentleName;

  /// No description provided for @channelGentleDesc.
  ///
  /// In en, this message translates to:
  /// **'Non-critical reminders that respect Do Not Disturb'**
  String get channelGentleDesc;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss\na dose'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey rings like an alarm clock — even on silent or Do Not Disturb. Allow these so your reminders arrive exactly on time.'**
  String get onboardingBody;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get onboardingContinue;

  /// No description provided for @onboardingEssentialHint.
  ///
  /// In en, this message translates to:
  /// **'Notifications and exact alarms are required.'**
  String get onboardingEssentialHint;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @permNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotificationsTitle;

  /// No description provided for @permNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Show medicine, appointment and test reminders.'**
  String get permNotificationsBody;

  /// No description provided for @permExactAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms'**
  String get permExactAlarmsTitle;

  /// No description provided for @permExactAlarmsBody.
  ///
  /// In en, this message translates to:
  /// **'Ring at the exact minute — not \"sometime around\" it.'**
  String get permExactAlarmsBody;

  /// No description provided for @permFullScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarm'**
  String get permFullScreenTitle;

  /// No description provided for @permFullScreenBody.
  ///
  /// In en, this message translates to:
  /// **'Wake the screen and show the alarm over the lock screen.'**
  String get permFullScreenBody;

  /// No description provided for @permDndTitle.
  ///
  /// In en, this message translates to:
  /// **'Ring in Do Not Disturb'**
  String get permDndTitle;

  /// No description provided for @permDndBody.
  ///
  /// In en, this message translates to:
  /// **'Let critical reminders break through silent and DND modes.'**
  String get permDndBody;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get addRecord;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get recordTitle;

  /// No description provided for @recordType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get recordType;

  /// No description provided for @recordDate.
  ///
  /// In en, this message translates to:
  /// **'Document date'**
  String get recordDate;

  /// No description provided for @recordDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get recordDoctor;

  /// No description provided for @recordNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recordNotes;

  /// No description provided for @recordPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get recordPages;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records saved'**
  String get noRecords;

  /// No description provided for @addAtLeastOnePage.
  ///
  /// In en, this message translates to:
  /// **'Add at least one page'**
  String get addAtLeastOnePage;

  /// No description provided for @recordPrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get recordPrescription;

  /// No description provided for @recordTestReport.
  ///
  /// In en, this message translates to:
  /// **'Test report'**
  String get recordTestReport;

  /// No description provided for @recordVaccineCertificate.
  ///
  /// In en, this message translates to:
  /// **'Vaccine card'**
  String get recordVaccineCertificate;

  /// No description provided for @recordInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get recordInvoice;

  /// No description provided for @recordOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get recordOther;

  /// No description provided for @recordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nRecords'**
  String get recordsTitle;

  /// No description provided for @addPages.
  ///
  /// In en, this message translates to:
  /// **'Add pages'**
  String get addPages;

  /// No description provided for @deletePage.
  ///
  /// In en, this message translates to:
  /// **'Delete page'**
  String get deletePage;

  /// No description provided for @recordTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blood test – Oct'**
  String get recordTitleHint;

  /// No description provided for @deleteRecordBody.
  ///
  /// In en, this message translates to:
  /// **'All pages will be deleted from this device.'**
  String get deleteRecordBody;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderTitle;

  /// No description provided for @reminderNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get reminderNotes;

  /// No description provided for @reminderLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reminderLocation;

  /// No description provided for @reminderRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get reminderRepeat;

  /// No description provided for @reminderEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get reminderEndDate;

  /// No description provided for @reminderEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every how many days'**
  String get reminderEveryNDays;

  /// No description provided for @reminderCritical.
  ///
  /// In en, this message translates to:
  /// **'Ring in Do Not Disturb'**
  String get reminderCritical;

  /// No description provided for @reminderCriticalHint.
  ///
  /// In en, this message translates to:
  /// **'Uses a full-screen alarm that bypasses silent and DND modes'**
  String get reminderCriticalHint;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noReminders;

  /// No description provided for @markTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get markTaken;

  /// No description provided for @typeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get typeMedicine;

  /// No description provided for @typeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get typeAppointment;

  /// No description provided for @typeVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get typeVaccine;

  /// No description provided for @typeMedicalTest.
  ///
  /// In en, this message translates to:
  /// **'Medical test'**
  String get typeMedicalTest;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get repeatEveryNDays;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nReminders'**
  String get remindersTitle;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Reminder type'**
  String get reminderType;

  /// No description provided for @reminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning insulin'**
  String get reminderTitleHint;

  /// No description provided for @reminderMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get reminderMedicine;

  /// No description provided for @reminderDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get reminderDoctor;

  /// No description provided for @reminderWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get reminderWhen;

  /// No description provided for @reminderSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze length'**
  String get reminderSnooze;

  /// No description provided for @selectMedicineError.
  ///
  /// In en, this message translates to:
  /// **'Choose a medicine'**
  String get selectMedicineError;

  /// No description provided for @selectWeekdaysError.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day'**
  String get selectWeekdaysError;

  /// No description provided for @deleteReminderBody.
  ///
  /// In en, this message translates to:
  /// **'The reminder and its history will be removed.'**
  String get deleteReminderBody;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// A length of time in days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @pagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pagesCount(int count);

  /// e.g. Next Medicine in 45 min
  ///
  /// In en, this message translates to:
  /// **'Next {type} in {duration}'**
  String nextTypeIn(String type, String duration);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// Stock remaining, e.g. 12 tablet left
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String unitsLeft(String amount);

  /// No description provided for @activeMedicines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active medicine} other{{count} active medicines}}'**
  String activeMedicines(int count);

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} / day'**
  String perDay(String amount);

  /// e.g. 5 tablet / day
  ///
  /// In en, this message translates to:
  /// **'{amount} {unit} / day'**
  String unitsPerDayLabel(String amount, String unit);

  /// No description provided for @bulkSaveAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save 1 medicine} other{Save {count} medicines}}'**
  String bulkSaveAll(int count);

  /// No description provided for @bulkSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 medicine} other{Added {count} medicines}}'**
  String bulkSaved(int count);

  /// The dose pattern as written, e.g. 1+0+1
  ///
  /// In en, this message translates to:
  /// **'Prescription says: {pattern}'**
  String bulkAsWritten(String pattern);

  /// No description provided for @bulkFixMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine {number} needs a name and unit before saving.'**
  String bulkFixMedicine(int number);

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String everyNDays(int count);

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your medicine reminder that rings like a real alarm clock, so you never miss a dose.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything to stay\non track'**
  String get onboardingFeaturesTitle;

  /// No description provided for @featureAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms that really ring'**
  String get featureAlarmTitle;

  /// No description provided for @featureAlarmBody.
  ///
  /// In en, this message translates to:
  /// **'Every dose rings like an alarm clock, even on silent.'**
  String get featureAlarmBody;

  /// No description provided for @featureScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your prescription'**
  String get featureScanTitle;

  /// No description provided for @featureScanBody.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo and Dosey fills in the medicines, doses and times.'**
  String get featureScanBody;

  /// No description provided for @featureStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock and cost tracking'**
  String get featureStockTitle;

  /// No description provided for @featureStockBody.
  ///
  /// In en, this message translates to:
  /// **'Get refill alerts and see what your medicines cost each month.'**
  String get featureStockBody;

  /// No description provided for @featurePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get featurePrivateTitle;

  /// No description provided for @featurePrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your phone. No account, no cloud.'**
  String get featurePrivateBody;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Dosey ring\non time'**
  String get onboardingPermissionsTitle;

  /// No description provided for @allowAll.
  ///
  /// In en, this message translates to:
  /// **'Allow all'**
  String get allowAll;

  /// No description provided for @allowAllHint.
  ///
  /// In en, this message translates to:
  /// **'Dosey asks for each one in turn. If Settings opens, switch it on and come back.'**
  String get allowAllHint;

  /// No description provided for @allSet.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get allSet;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// Screen reader label for the page dots
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Your doctors and appointments'**
  String get moreDoctorsHint;

  /// No description provided for @moreRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions, reports and invoices'**
  String get moreRecordsHint;

  /// No description provided for @moreExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Spending and medicine costs'**
  String get moreExpensesHint;

  /// No description provided for @moreSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Language and preferences'**
  String get moreSettingsHint;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @sameAsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Same as last month'**
  String get sameAsLastMonth;

  /// No description provided for @expensesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Track pharmacy bills, doctor fees and tests in one place.'**
  String get expensesEmptyBody;

  /// Header of the expenses card, e.g. Spent in October
  ///
  /// In en, this message translates to:
  /// **'Spent in {month}'**
  String spentIn(String month);

  /// Screen reader label for the spending bar chart
  ///
  /// In en, this message translates to:
  /// **'Spending over the last {count} months'**
  String lastMonthsTrend(int count);

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders & alarms'**
  String get settingsReminders;

  /// No description provided for @settingsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Alarm permissions'**
  String get settingsPermissions;

  /// No description provided for @permissionsAllAllowed.
  ///
  /// In en, this message translates to:
  /// **'All allowed'**
  String get permissionsAllAllowed;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settingsSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @contactSupportHint.
  ///
  /// In en, this message translates to:
  /// **'Questions, bugs or ideas: we read every email'**
  String get contactSupportHint;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Dosey'**
  String get rateApp;

  /// No description provided for @rateAppHint.
  ///
  /// In en, this message translates to:
  /// **'It helps other people find the app'**
  String get rateAppHint;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About & legal'**
  String get settingsAbout;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyHint.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your phone'**
  String get privacyPolicyHint;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical disclaimer'**
  String get medicalDisclaimer;

  /// No description provided for @medicalDisclaimerHint.
  ///
  /// In en, this message translates to:
  /// **'Dosey is not a substitute for your doctor'**
  String get medicalDisclaimerHint;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get licenses;

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that. Please try again.'**
  String get couldNotOpen;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Dosey support'**
  String get supportEmailSubject;

  /// No description provided for @privacyShortTitle.
  ///
  /// In en, this message translates to:
  /// **'In short'**
  String get privacyShortTitle;

  /// No description provided for @privacyShortBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey has no account, no ads and no analytics. Everything you enter stays on your phone.'**
  String get privacyShortBody;

  /// No description provided for @privacyStoredTitle.
  ///
  /// In en, this message translates to:
  /// **'What Dosey stores'**
  String get privacyStoredTitle;

  /// No description provided for @privacyStoredBody.
  ///
  /// In en, this message translates to:
  /// **'Medicines, reminders, dose history, doctors, expenses and the photos you add to records. They are saved in the app\'s private storage on this device only.'**
  String get privacyStoredBody;

  /// No description provided for @privacyScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Prescription scanning'**
  String get privacyScanTitle;

  /// No description provided for @privacyScanBody.
  ///
  /// In en, this message translates to:
  /// **'Text recognition runs on your phone using Google ML Kit, and the photo is not uploaded. ML Kit may send limited diagnostic information to Google, as described in Google\'s ML Kit terms.'**
  String get privacyScanBody;

  /// No description provided for @privacyPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get privacyPermissionsTitle;

  /// No description provided for @privacyPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications and alarm permissions are used only to ring your reminders. The camera and photo library are used only when you add a picture.'**
  String get privacyPermissionsBody;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey does not sell or share your data. Nothing leaves your phone unless you choose to send it, for example by emailing support.'**
  String get privacySharingBody;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete any item inside the app, delete everything at once in Settings › Delete all data, or uninstall Dosey.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey is meant for adults and caregivers, and is not directed at children under 13.'**
  String get privacyChildrenBody;

  /// No description provided for @termsUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Dosey'**
  String get termsUseTitle;

  /// No description provided for @termsUseBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey helps you remember medicines and keep health records. You are responsible for the information you enter and for checking that reminders match your prescription.'**
  String get termsUseBody;

  /// No description provided for @termsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get termsRemindersTitle;

  /// No description provided for @termsRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey works hard to ring on time, but phone settings, battery savers or system updates can delay or block alarms. Don\'t rely on Dosey alone for critical medicines.'**
  String get termsRemindersBody;

  /// No description provided for @termsWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'No warranty'**
  String get termsWarrantyTitle;

  /// No description provided for @termsWarrantyBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey is provided as is, without warranties. To the extent the law allows, we are not liable for missed doses or other losses from using the app.'**
  String get termsWarrantyBody;

  /// No description provided for @termsChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get termsChangesTitle;

  /// No description provided for @termsChangesBody.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated; the date above shows the latest version.'**
  String get termsChangesBody;

  /// No description provided for @disclaimerAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Not medical advice'**
  String get disclaimerAdviceTitle;

  /// No description provided for @disclaimerAdviceBody.
  ///
  /// In en, this message translates to:
  /// **'Dosey is a reminder and record-keeping tool, not a medical device. It does not diagnose, treat or give medical advice.'**
  String get disclaimerAdviceBody;

  /// No description provided for @disclaimerDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your doctor'**
  String get disclaimerDoctorTitle;

  /// No description provided for @disclaimerDoctorBody.
  ///
  /// In en, this message translates to:
  /// **'Always follow your doctor\'s or pharmacist\'s instructions. Check every scanned prescription carefully, because text recognition can misread names and doses.'**
  String get disclaimerDoctorBody;

  /// No description provided for @disclaimerEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergencies'**
  String get disclaimerEmergencyTitle;

  /// No description provided for @disclaimerEmergencyBody.
  ///
  /// In en, this message translates to:
  /// **'In an emergency, contact your doctor or local emergency services immediately.'**
  String get disclaimerEmergencyBody;

  /// No description provided for @permissionsMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs attention} other{{count} need attention}}'**
  String permissionsMissing(int count);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String lastUpdated(String date);

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about privacy? Email {email}.'**
  String privacyContactBody(String email);

  /// No description provided for @settingsYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsYourData;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataHint.
  ///
  /// In en, this message translates to:
  /// **'Medicines, reminders, records, photos, expenses and blood pressure'**
  String get deleteAllDataHint;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all your data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every medicine, reminder, dose history, doctor, record, photo, expense and blood pressure reading on this phone will be deleted, and all alarms will stop. Your language and theme are kept.'**
  String get deleteAllBody;

  /// No description provided for @deleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteAllConfirmTitle;

  /// No description provided for @deleteAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. Dosey keeps no backup or cloud copy of your data.'**
  String get deleteAllConfirmBody;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All your data was deleted'**
  String get allDataDeleted;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @slotMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get slotMorning;

  /// No description provided for @slotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get slotLunch;

  /// No description provided for @slotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get slotDinner;

  /// No description provided for @slotBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get slotBedtime;

  /// No description provided for @quickTimesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add or remove. Tap a time below to change it or its amount.'**
  String get quickTimesHint;

  /// No description provided for @ringAsAlarm.
  ///
  /// In en, this message translates to:
  /// **'Ring as an alarm'**
  String get ringAsAlarm;

  /// No description provided for @ringAsAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarm that rings even on silent. Turn off for a quiet notification.'**
  String get ringAsAlarmHint;

  /// No description provided for @medicinePickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any medicines yet'**
  String get medicinePickerEmpty;

  /// No description provided for @medicinePickerEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add the medicine first. Its intake times become reminders automatically, so you may not need a separate one.'**
  String get medicinePickerEmptyHint;

  /// No description provided for @addNewMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add new medicine'**
  String get addNewMedicine;

  /// No description provided for @stripsPerBox.
  ///
  /// In en, this message translates to:
  /// **'Strips per box'**
  String get stripsPerBox;

  /// No description provided for @addOneBox.
  ///
  /// In en, this message translates to:
  /// **'+1 box'**
  String get addOneBox;

  /// No description provided for @addOneStrip.
  ///
  /// In en, this message translates to:
  /// **'+1 strip'**
  String get addOneStrip;

  /// No description provided for @refillAlert.
  ///
  /// In en, this message translates to:
  /// **'Refill alert'**
  String get refillAlert;

  /// No description provided for @refillAlertNeedsStock.
  ///
  /// In en, this message translates to:
  /// **'Enter your stock above to get a refill alert.'**
  String get refillAlertNeedsStock;

  /// No description provided for @unitsPerStrip.
  ///
  /// In en, this message translates to:
  /// **'Per strip ({unit})'**
  String unitsPerStrip(String unit);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Runs out today} =1{~1 day left} other{~{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @refillAlertDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before it runs out} other{{count} days before it runs out}}'**
  String refillAlertDays(int count);

  /// No description provided for @refillAlertUnits.
  ///
  /// In en, this message translates to:
  /// **'At your current dose that\'s about {amount} {unit}.'**
  String refillAlertUnits(String amount, String unit);

  /// No description provided for @lowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is running low'**
  String lowStockTitle(String name);

  /// No description provided for @lowStockBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{It runs out today. Time to buy more.} =1{About 1 day left. Time to buy more.} other{About {count} days left. Time to buy more.}}'**
  String lowStockBody(int count);

  /// No description provided for @editThisTime.
  ///
  /// In en, this message translates to:
  /// **'Edit this time'**
  String get editThisTime;

  /// No description provided for @deleteThisTime.
  ///
  /// In en, this message translates to:
  /// **'Delete this time'**
  String get deleteThisTime;

  /// No description provided for @deleteThisTimeBody.
  ///
  /// In en, this message translates to:
  /// **'The {time} reminder for {name} will be deleted. Its other times stay.'**
  String deleteThisTimeBody(String time, String name);

  /// No description provided for @specMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get specMedicine;

  /// No description provided for @specGeneralPhysician.
  ///
  /// In en, this message translates to:
  /// **'General physician'**
  String get specGeneralPhysician;

  /// No description provided for @specCardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology (heart)'**
  String get specCardiology;

  /// No description provided for @specEndocrinology.
  ///
  /// In en, this message translates to:
  /// **'Diabetes & hormones'**
  String get specEndocrinology;

  /// No description provided for @specPaediatrics.
  ///
  /// In en, this message translates to:
  /// **'Child specialist'**
  String get specPaediatrics;

  /// No description provided for @specGynaecology.
  ///
  /// In en, this message translates to:
  /// **'Gynaecology & obstetrics'**
  String get specGynaecology;

  /// No description provided for @specSurgery.
  ///
  /// In en, this message translates to:
  /// **'General surgery'**
  String get specSurgery;

  /// No description provided for @specOrthopaedics.
  ///
  /// In en, this message translates to:
  /// **'Bone & joint (orthopaedics)'**
  String get specOrthopaedics;

  /// No description provided for @specNeurology.
  ///
  /// In en, this message translates to:
  /// **'Neurology (brain & nerves)'**
  String get specNeurology;

  /// No description provided for @specNephrology.
  ///
  /// In en, this message translates to:
  /// **'Kidney (nephrology)'**
  String get specNephrology;

  /// No description provided for @specGastroenterology.
  ///
  /// In en, this message translates to:
  /// **'Stomach & liver'**
  String get specGastroenterology;

  /// No description provided for @specPulmonology.
  ///
  /// In en, this message translates to:
  /// **'Chest & asthma'**
  String get specPulmonology;

  /// No description provided for @specEnt.
  ///
  /// In en, this message translates to:
  /// **'Ear, nose & throat'**
  String get specEnt;

  /// No description provided for @specEye.
  ///
  /// In en, this message translates to:
  /// **'Eye'**
  String get specEye;

  /// No description provided for @specDermatology.
  ///
  /// In en, this message translates to:
  /// **'Skin & VD'**
  String get specDermatology;

  /// No description provided for @specPsychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry (mental health)'**
  String get specPsychiatry;

  /// No description provided for @specUrology.
  ///
  /// In en, this message translates to:
  /// **'Urology'**
  String get specUrology;

  /// No description provided for @specOncology.
  ///
  /// In en, this message translates to:
  /// **'Cancer (oncology)'**
  String get specOncology;

  /// No description provided for @specRheumatology.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology (arthritis)'**
  String get specRheumatology;

  /// No description provided for @specDentistry.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get specDentistry;

  /// No description provided for @specPhysicalMedicine.
  ///
  /// In en, this message translates to:
  /// **'Physical medicine & rehab'**
  String get specPhysicalMedicine;

  /// No description provided for @specNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutritionist'**
  String get specNutrition;

  /// No description provided for @doctorSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Type or pick from the list'**
  String get doctorSpecialtyHint;

  /// No description provided for @doctorClinicHint.
  ///
  /// In en, this message translates to:
  /// **'Search hospitals & clinics'**
  String get doctorClinicHint;

  /// No description provided for @scanDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor on this prescription'**
  String get scanDoctorTitle;

  /// No description provided for @scanDoctorSave.
  ///
  /// In en, this message translates to:
  /// **'Save this doctor'**
  String get scanDoctorSave;

  /// No description provided for @scanDoctorSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Adds them to Doctors and links these medicines to them.'**
  String get scanDoctorSaveHint;

  /// No description provided for @scanDoctorLinked.
  ///
  /// In en, this message translates to:
  /// **'Matches a doctor you\'ve saved, so these medicines are linked to them.'**
  String get scanDoctorLinked;

  /// No description provided for @headerMedicinesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No medicines yet} =1{1 medicine} other{{count} medicines}}'**
  String headerMedicinesCount(int count);

  /// No description provided for @headerRemindersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reminders yet} =1{1 reminder} other{{count} reminders}}'**
  String headerRemindersCount(int count);

  /// No description provided for @headerDoctorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No doctors yet} =1{1 doctor} other{{count} doctors}}'**
  String headerDoctorsCount(int count);

  /// No description provided for @headerRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No records yet} =1{1 record} other{{count} records}}'**
  String headerRecordsCount(int count);

  /// No description provided for @addSheetHeader.
  ///
  /// In en, this message translates to:
  /// **'Quick\nAdd'**
  String get addSheetHeader;

  /// No description provided for @moreSheetHeader.
  ///
  /// In en, this message translates to:
  /// **'Menu\nMore'**
  String get moreSheetHeader;

  /// No description provided for @moreSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Doctors, records, expenses, blood pressure and settings'**
  String get moreSheetSubtitle;

  /// No description provided for @unitTabletPlural.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get unitTabletPlural;

  /// No description provided for @unitCapsulePlural.
  ///
  /// In en, this message translates to:
  /// **'capsules'**
  String get unitCapsulePlural;

  /// No description provided for @unitMlPlural.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMlPlural;

  /// No description provided for @unitInjectionPlural.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitInjectionPlural;

  /// No description provided for @unitDropPlural.
  ///
  /// In en, this message translates to:
  /// **'drops'**
  String get unitDropPlural;

  /// No description provided for @unitPuffPlural.
  ///
  /// In en, this message translates to:
  /// **'puffs'**
  String get unitPuffPlural;

  /// No description provided for @unitApplicationPlural.
  ///
  /// In en, this message translates to:
  /// **'applications'**
  String get unitApplicationPlural;

  /// No description provided for @unitDosePlural.
  ///
  /// In en, this message translates to:
  /// **'doses'**
  String get unitDosePlural;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameBody.
  ///
  /// In en, this message translates to:
  /// **'Optional — you can skip this. Your name stays on this phone.'**
  String get onboardingNameBody;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsAddName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get settingsAddName;

  /// No description provided for @settingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get settingsNameHint;

  /// Home greeting with the user's name, e.g. "Good evening, Rafi"
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Dosey?'**
  String get exitTitle;

  /// No description provided for @exitBody.
  ///
  /// In en, this message translates to:
  /// **'Your reminders will still ring on time, even with the app closed.'**
  String get exitBody;

  /// No description provided for @exitStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get exitStay;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitConfirm;

  /// No description provided for @alarmGroupNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Time for 1 medicine} other{Time for {count} medicines}}'**
  String alarmGroupNotifTitle(int count);

  /// No description provided for @alarmGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medicine} other{{count} medicines}}'**
  String alarmGroupCount(int count);

  /// No description provided for @notifAllTaken.
  ///
  /// In en, this message translates to:
  /// **'All taken'**
  String get notifAllTaken;

  /// No description provided for @alarmMarkAllTaken.
  ///
  /// In en, this message translates to:
  /// **'All taken'**
  String get alarmMarkAllTaken;

  /// No description provided for @bpTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nBlood pressure'**
  String get bpTitle;

  /// No description provided for @bpShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get bpShortTitle;

  /// No description provided for @moreBpHint.
  ///
  /// In en, this message translates to:
  /// **'Log readings and see your trend'**
  String get moreBpHint;

  /// No description provided for @bpAdd.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get bpAdd;

  /// No description provided for @bpEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reading'**
  String get bpEditTitle;

  /// No description provided for @bpEmpty.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get bpEmpty;

  /// No description provided for @bpEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Write down each blood pressure check to see how it changes over time.'**
  String get bpEmptyHint;

  /// No description provided for @bpLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest reading'**
  String get bpLatest;

  /// No description provided for @bpSystolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic (upper)'**
  String get bpSystolic;

  /// No description provided for @bpDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (lower)'**
  String get bpDiastolic;

  /// No description provided for @bpPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse (optional)'**
  String get bpPulse;

  /// No description provided for @bpMeasuredAt.
  ///
  /// In en, this message translates to:
  /// **'Measured at'**
  String get bpMeasuredAt;

  /// No description provided for @bpNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get bpNote;

  /// No description provided for @bpNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. after a walk, left arm'**
  String get bpNoteHint;

  /// No description provided for @bpAverage7.
  ///
  /// In en, this message translates to:
  /// **'7-day average'**
  String get bpAverage7;

  /// No description provided for @bpTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get bpTrend;

  /// No description provided for @bpHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bpHistory;

  /// No description provided for @bpSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get bpSaved;

  /// No description provided for @bpDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This reading will be deleted.'**
  String get bpDeleteBody;

  /// No description provided for @bpDiastolicHigher.
  ///
  /// In en, this message translates to:
  /// **'Must be lower than the upper number'**
  String get bpDiastolicHigher;

  /// No description provided for @bpLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get bpLow;

  /// No description provided for @bpNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bpNormal;

  /// No description provided for @bpElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get bpElevated;

  /// No description provided for @bpStage1.
  ///
  /// In en, this message translates to:
  /// **'High · stage 1'**
  String get bpStage1;

  /// No description provided for @bpStage2.
  ///
  /// In en, this message translates to:
  /// **'High · stage 2'**
  String get bpStage2;

  /// No description provided for @bpCrisis.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get bpCrisis;

  /// No description provided for @bpCrisisHint.
  ///
  /// In en, this message translates to:
  /// **'Very high. If you also have chest pain, shortness of breath, weakness or trouble seeing or speaking, get emergency care now.'**
  String get bpCrisisHint;

  /// No description provided for @bpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Categories follow the American Heart Association guide for adults. This isn\'t a diagnosis — talk to your doctor about your readings.'**
  String get bpDisclaimer;

  /// No description provided for @bpSystolicLegend.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get bpSystolicLegend;

  /// No description provided for @bpDiastolicLegend.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get bpDiastolicLegend;

  /// No description provided for @bpCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No readings yet} =1{1 reading} other{{count} readings}}'**
  String bpCount(int count);

  /// No description provided for @bpValue.
  ///
  /// In en, this message translates to:
  /// **'{systolic}/{diastolic}'**
  String bpValue(String systolic, String diastolic);

  /// No description provided for @bpPulseValue.
  ///
  /// In en, this message translates to:
  /// **'Pulse {pulse}'**
  String bpPulseValue(String pulse);

  /// No description provided for @numberRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from {min} to {max}'**
  String numberRange(String min, String max);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
