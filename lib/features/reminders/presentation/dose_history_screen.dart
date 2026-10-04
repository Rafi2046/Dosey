import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/reminder_alarm_engine.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../domain/dose_history.dart';
import '../domain/reminder_text.dart';
import '../providers/reminders_providers.dart';

/// Every past medicine dose, day by day, with what happened to it (taken,
/// taken late, skipped, missed) and the share taken over the period. A
/// missed or skipped dose can be marked as taken late from here.
///
/// With [medicineId], only that medicine's doses ([medicineName] under the
/// title).
class DoseHistoryScreen extends ConsumerStatefulWidget {
  const DoseHistoryScreen({super.key, this.medicineId, this.medicineName});

  final int? medicineId;
  final String? medicineName;

  /// Periods offered, in days.
  static const List<int> periods = [7, 30];

  @override
  ConsumerState<DoseHistoryScreen> createState() => _DoseHistoryScreenState();
}

class _DoseHistoryScreenState extends ConsumerState<DoseHistoryScreen> {
  int _days = DoseHistoryScreen.periods.first;

  ({int days, int? medicineId}) get _query =>
      (days: _days, medicineId: widget.medicineId);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = ref.watch(doseHistoryProvider(_query));
    final empty = history.value?.entries.isEmpty ?? false;

    return Scaffold(
      body: TabScrollView(
        bottomPadding: const EdgeInsets.only(bottom: AppSpacing.xl),
        centerLast: empty,
        onRefresh: () async => ref.invalidate(doseHistoryProvider(_query)),
        children: [
          ScreenHeader(title: l10n.historyTitle, subtitle: widget.medicineName),
          ChoicePills<int>(
            options: DoseHistoryScreen.periods,
            onDark: true,
            selected: {_days},
            labelOf: l10n.historyLastDays,
            onChanged: (s) => setState(() => _days = s.single),
          ),
          AppSpacing.gapLg,
          AsyncValueView(
            value: history,
            data: (h) => h.entries.isEmpty
                ? EmptyState(
                    title: l10n.historyEmpty,
                    message: l10n.historyEmptyHint,
                    image: null,
                  )
                : _HistoryBody(history: h),
          ),
        ],
      ),
    );
  }
}

/// Fill color of each outcome, used for chips, the bar and its legend.
Color _statusColor(ReminderLogStatus s) => switch (s) {
  ReminderLogStatus.taken => AppColors.tileMint,
  ReminderLogStatus.takenLate => AppColors.tileOlive,
  ReminderLogStatus.skipped => AppColors.tileStone,
  ReminderLogStatus.missed || ReminderLogStatus.snoozed => AppColors.accent,
};

IconData _statusIcon(ReminderLogStatus s) => switch (s) {
  ReminderLogStatus.taken => Icons.check_rounded,
  ReminderLogStatus.takenLate => Icons.history_rounded,
  ReminderLogStatus.skipped => Icons.redo_rounded,
  ReminderLogStatus.missed ||
  ReminderLogStatus.snoozed => Icons.priority_high_rounded,
};

/// Outcomes in the order they're summarised.
const _outcomes = [
  ReminderLogStatus.taken,
  ReminderLogStatus.takenLate,
  ReminderLogStatus.skipped,
  ReminderLogStatus.missed,
];

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.history});

  final DoseHistory history;

  String _dayLabel(BuildContext context, DateTime day) {
    final today = DateUtils.dateOnly(DateTime.now());
    if (day == today) return context.l10n.historyToday;
    if (day == today.subtract(const Duration(days: 1))) {
      return context.l10n.historyYesterday;
    }
    return AppDateFormat.shortDate(day);
  }

  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, List<DoseHistoryEntry>>{};
    for (final e in history.entries) {
      (byDay[DateUtils.dateOnly(e.at)] ??= []).add(e);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AdherenceCard(history: history),
        for (final MapEntry(key: day, value: entries) in byDay.entries) ...[
          SectionHeader(title: _dayLabel(context, day)),
          for (final e in entries) _DoseRow(entry: e),
        ],
      ],
    );
  }
}

/// "86%  Doses taken", a bar split by outcome, and a count of each.
class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.history});

  final DoseHistory history;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = history.entries.length;
    final taken = history.entries.where((e) => e.status.isTaken).length;
    final percent = ((history.adherence ?? 0) * 100).round();

    return SurfaceCard(
      color: AppColors.cream,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppNumber.format(percent)}%',
                style: AppTextStyles.amount.copyWith(color: AppColors.ink),
              ),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.historyAdherence,
                      style: AppTextStyles.cardTitleOnLight,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      l10n.historyAdherenceHint(taken, total),
                      style: AppTextStyles.captionOnLight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: SizedBox(
              height: AppSpacing.barHeight,
              child: Row(
                // Fill the bar's height (empty boxes would collapse to 0).
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final s in _outcomes)
                    if (history.count(s) > 0)
                      Expanded(
                        flex: history.count(s),
                        child: ColoredBox(color: _statusColor(s)),
                      ),
                ],
              ),
            ),
          ),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              for (final s in _outcomes)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSpacing.sm,
                      height: AppSpacing.sm,
                      decoration: BoxDecoration(
                        color: _statusColor(s),
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '${s.label(l10n)} ${AppNumber.format(history.count(s))}',
                      style: AppTextStyles.captionOnLight,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One dose: time, medicine and amount, outcome chip. A missed or skipped
/// one can be tapped to record that it was taken late after all.
class _DoseRow extends ConsumerWidget {
  const _DoseRow({required this.entry});

  final DoseHistoryEntry entry;

  Future<void> _markTakenLate(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.details.reminder.title),
        content: Text(l10n.historyMarkLateBody),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.takenLate),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(alarmEngineProvider)
        .handleAction(
          reminderIds: [entry.details.reminder.id],
          scheduledFor: entry.at,
          action: AlarmAction.takenLate,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = entry.status;
    final missed = s == ReminderLogStatus.missed;
    final correctable = missed || s == ReminderLogStatus.skipped;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SurfaceCard(
        color: AppColors.creamLight,
        padding: AppSpacing.cardPadding,
        radius: AppSpacing.radiusMd,
        onTap: correctable ? () => _markTakenLate(context, ref) : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.details.reminder.title,
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '${AppDateFormat.time(entry.at)}'
                    '${context.l10n.notifDoseSeparator}'
                    '${ReminderText.body(context.l10n, entry.details)}',
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            StatusChip(
              label: s.label(context.l10n),
              icon: _statusIcon(s),
              background: _statusColor(s),
              foreground: missed
                  ? AppColors.textOnAccent
                  : AppColors.textOnDark,
            ),
          ],
        ),
      ),
    );
  }
}
