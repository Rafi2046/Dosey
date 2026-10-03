/// Notification content, actions and channel names.
abstract final class NotificationStrings {
  static const String notifTaken = 'Taken ✓';
  static const String notifSnooze = 'Snooze';
  static const String notifSkip = 'Skip';
  static const String notifDoseSeparator = ' · ';
  static const String notifAtLocation = 'At ';
  static const String notifWithDoctor = 'With ';
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
