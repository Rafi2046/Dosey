import '../../../core/database/app_database.dart';
import 'missed_doses.dart';
import 'reminder_with_details.dart';

/// One past medicine dose and what happened to it.
class DoseHistoryEntry {
  const DoseHistoryEntry({
    required this.details,
    required this.at,
    required this.status,
  });

  final ReminderWithDetails details;
  final DateTime at;

  /// Taken, taken late, skipped or missed (never snoozed: a snoozed dose is
  /// still open until answered or missed).
  final ReminderLogStatus status;
}

/// Every medicine dose over a period, newest first, with adherence totals.
class DoseHistory {
  const DoseHistory(this.entries);

  /// Doses of [reminders] scheduled in [from, now]: everything logged, plus
  /// doses left unanswered past the missed threshold that the background
  /// sweep hasn't logged yet. Doses still open (due within the threshold,
  /// or snoozed) aren't history yet and are left out. With [medicineId],
  /// only that medicine's.
  factory DoseHistory.build(
    List<ReminderWithDetails> reminders,
    List<ReminderLog> logs, {
    required DateTime from,
    required DateTime now,
    int? medicineId,
  }) {
    final byId = {
      for (final d in reminders)
        if (d.reminder.type == ReminderType.medicine &&
            (medicineId == null || d.reminder.medicineId == medicineId))
          d.reminder.id: d,
    };
    final entries = <DoseHistoryEntry>[
      for (final l in logs)
        if (l.status != ReminderLogStatus.snoozed &&
            !l.scheduledFor.isBefore(from) &&
            !l.scheduledFor.isAfter(now))
          if (byId[l.reminderId] case final d?)
            DoseHistoryEntry(details: d, at: l.scheduledFor, status: l.status),
      for (final m in MissedDoses.find(
        [for (final d in byId.values) d.reminder],
        logs,
        from: from,
        now: now,
      ))
        if (!m.logged)
          DoseHistoryEntry(
            details: byId[m.reminder.id]!,
            at: m.at,
            status: ReminderLogStatus.missed,
          ),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return DoseHistory(entries);
  }

  final List<DoseHistoryEntry> entries;

  int count(ReminderLogStatus status) =>
      entries.where((e) => e.status == status).length;

  /// Share of doses actually taken (on time or late), 0–1; null with none.
  double? get adherence => entries.isEmpty
      ? null
      : entries.where((e) => e.status.isTaken).length / entries.length;
}
