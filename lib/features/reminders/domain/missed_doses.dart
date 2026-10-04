import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import 'reminder_schedule.dart';

/// One medicine dose that counts as missed.
class MissedDose {
  const MissedDose(this.reminder, this.at, {required this.logged});

  final Reminder reminder;
  final DateTime at;

  /// Already recorded as missed. False: overdue and unanswered, but not
  /// written to the log yet (see `ReminderAlarmEngine.sweepMissed`).
  final bool logged;
}

/// Which medicine doses were missed. Pure, so the background sweep that
/// writes them and the dashboard that shows them always agree.
abstract final class MissedDoses {
  /// Snoozed doses can still be answered; anything else is final.
  static bool isOpen(ReminderLogStatus? status) =>
      status == null || status == ReminderLogStatus.snoozed;

  /// Doses of enabled medicine [reminders] scheduled from [from] that count
  /// as missed at [now], oldest first: those logged as missed, plus those
  /// left open for longer than [AppConstants.missedThreshold]: after their
  /// time, or for a snoozed dose after it last rang ("remind me in 2 h"
  /// mustn't turn into a miss before it even rings).
  ///
  /// A reminder's occurrences before its last edit ([Reminder.updatedAt])
  /// are never inferred as missed: a new medicine, a moved time or a
  /// re-enabled reminder must not report doses nobody was asked to take.
  static List<MissedDose> find(
    Iterable<Reminder> reminders,
    Iterable<ReminderLog> logs, {
    required DateTime from,
    required DateTime now,
  }) {
    final byId = {
      for (final r in reminders)
        if (r.isEnabled && r.type == ReminderType.medicine) r.id: r,
    };
    final byKey = {for (final l in logs) (l.reminderId, l.scheduledFor): l};
    final result = <MissedDose>[
      for (final l in logs)
        if (l.status == ReminderLogStatus.missed &&
            !l.scheduledFor.isBefore(from))
          if (byId[l.reminderId] case final r?)
            MissedDose(r, l.scheduledFor, logged: true),
    ];

    final cutoff = now.subtract(AppConstants.missedThreshold);
    for (final r in byId.values) {
      final floor = r.updatedAt.isAfter(from) ? r.updatedAt : from;
      // Just before [floor], so an occurrence exactly at it is included.
      var cursor = floor.subtract(const Duration(microseconds: 1));
      while (true) {
        final at = ReminderSchedule.nextFor(r, cursor);
        if (at == null || !at.isBefore(cutoff)) break;
        final log = byKey[(r.id, at)];
        // A snoozed dose's clock restarts when it rings again ([actedAt]).
        final lastRang = log?.status == ReminderLogStatus.snoozed
            ? log!.actedAt ?? at
            : at;
        if (isOpen(log?.status) && lastRang.isBefore(cutoff)) {
          result.add(MissedDose(r, at, logged: false));
        }
        cursor = at;
      }
    }
    return result..sort((a, b) => a.at.compareTo(b.at));
  }
}
