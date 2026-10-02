import '../../../core/database/app_database.dart';
import 'reminder_with_details.dart';

/// One concrete firing of a reminder on a given day, with its logged outcome.
class ScheduledOccurrence {
  const ScheduledOccurrence({required this.details, required this.at, this.status});

  final ReminderWithDetails details;
  final DateTime at;

  /// Null when the user hasn't acted on it yet.
  final ReminderLogStatus? status;
}
