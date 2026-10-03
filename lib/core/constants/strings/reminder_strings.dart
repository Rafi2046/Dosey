/// Reminders list, form and schedule descriptions.
abstract final class ReminderStrings {
  static const String reminders = 'Reminders';
  static const String addReminder = 'Add reminder';
  static const String editReminder = 'Edit reminder';
  static const String reminderTitle = 'Title';
  static const String reminderNotes = 'Notes';
  static const String reminderLocation = 'Location';
  static const String reminderRepeat = 'Repeat';
  static const String reminderEndDate = 'End date';
  static const String reminderEveryNDays = 'Every how many days';
  static const String reminderCritical = 'Ring in Do Not Disturb';
  static const String reminderCriticalHint =
      'Uses a full-screen alarm that bypasses silent and DND modes';
  static const String noReminders = 'No reminders yet';
  static const String markTaken = 'Taken';
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
}
