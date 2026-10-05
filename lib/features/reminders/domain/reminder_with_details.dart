import '../../../core/database/app_database.dart';

class ReminderWithDetails {
  const ReminderWithDetails({
    required this.reminder,
    this.medicine,
    this.doctor,
    this.profile,
  });

  final Reminder reminder;
  final Medicine? medicine;
  final Doctor? doctor;

  /// Whose reminder it is (named on alarms when there are several).
  final Profile? profile;
}
