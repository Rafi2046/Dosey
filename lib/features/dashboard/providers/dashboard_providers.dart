import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reminders/domain/reminder_with_details.dart';
import '../../reminders/providers/reminders_providers.dart';

/// The single soonest reminder, for the dashboard hero card.
final nextReminderProvider = Provider<AsyncValue<ReminderWithDetails?>>(
  (ref) =>
      ref.watch(upcomingRemindersProvider).whenData((list) => list.firstOrNull),
);
