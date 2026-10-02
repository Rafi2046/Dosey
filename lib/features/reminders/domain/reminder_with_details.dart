import '../../../core/database/app_database.dart';

class ReminderWithDetails {
  const ReminderWithDetails({
    required this.reminder,
    this.medicine,
    this.doctor,
  });

  final Reminder reminder;
  final Medicine? medicine;
  final Doctor? doctor;
}
