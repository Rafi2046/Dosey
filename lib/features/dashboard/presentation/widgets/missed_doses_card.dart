import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/utils/clock_providers.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/sheet_title.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/scheduled_occurrence.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../../../core/localization/l10n.dart';

/// Warning at the top of Home when doses from today or yesterday were
/// missed. Tapping it lists them so each can be marked as taken late.
/// Hidden when there are none.
class MissedDosesCard extends ConsumerWidget {
  const MissedDosesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(missedDosesProvider).value ?? const [];
    if (doses.isEmpty) return const SizedBox.shrink();
    final names = {for (final o in doses) o.details.reminder.title};

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: SurfaceCard(
        color: AppColors.cream,
        elevated: true,
        padding: AppSpacing.cardPadding,
        onTap: () => showMissedDosesSheet(context),
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notification_important_rounded,
                color: AppColors.textOnAccent,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.missedDosesCount(doses.length),
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    names.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    context.l10n.missedDosesHint,
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}

/// Every missed dose with a "Taken late" button, plus one for all of them.
/// Closes by itself once none are left.
Future<void> showMissedDosesSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _MissedDosesSheet(),
    );

class _MissedDosesSheet extends ConsumerStatefulWidget {
  const _MissedDosesSheet();

  @override
  ConsumerState<_MissedDosesSheet> createState() => _MissedDosesSheetState();
}

class _MissedDosesSheetState extends ConsumerState<_MissedDosesSheet> {
  bool _busy = false;

  /// Logs [doses] as taken late through the alarm engine, like any other
  /// answer, so stock, notifications and the home widget stay in step.
  Future<void> _markTakenLate(List<ScheduledOccurrence> doses) async {
    setState(() => _busy = true);
    try {
      final engine = ref.read(alarmEngineProvider);
      final byTime = <DateTime, List<int>>{};
      for (final o in doses) {
        (byTime[o.at] ??= []).add(o.details.reminder.id);
      }
      for (final MapEntry(key: at, value: ids) in byTime.entries) {
        await engine.handleAction(
          reminderIds: ids,
          scheduledFor: at,
          action: AlarmAction.takenLate,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(missedDosesProvider, (_, next) {
      if (next.value?.isEmpty ?? false) Navigator.pop(context);
    });
    final doses = ref.watch(missedDosesProvider).value ?? const [];
    final today =
        ref.watch(currentDayProvider).value ??
        DateUtils.dateOnly(DateTime.now());

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height * AppSpacing.sheetMaxSize,
        ),
        child: Padding(
          padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(context.l10n.missedDosesTitle),
              AppSpacing.gapSm,
              Text(
                context.l10n.missedDosesBody,
                style: AppTextStyles.bodyOnLight,
              ),
              AppSpacing.gapLg,
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: doses.length,
                  separatorBuilder: (_, _) => AppSpacing.gapSm,
                  itemBuilder: (context, i) => _MissedDoseRow(
                    occurrence: doses[i],
                    today: today,
                    onTakenLate: _busy
                        ? null
                        : () => _markTakenLate([doses[i]]),
                  ),
                ),
              ),
              if (doses.length > 1) ...[
                AppSpacing.gapLg,
                PillButton(
                  label: context.l10n.markAllTakenLate,
                  tone: PillButtonTone.moss,
                  trailingIcon: Icons.done_all_rounded,
                  loading: _busy,
                  onPressed: () => _markTakenLate(doses),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MissedDoseRow extends StatelessWidget {
  const _MissedDoseRow({
    required this.occurrence,
    required this.today,
    required this.onTakenLate,
  });

  final ScheduledOccurrence occurrence;
  final DateTime today;
  final VoidCallback? onTakenLate;

  @override
  Widget build(BuildContext context) {
    final details = occurrence.details;
    final time = AppDateFormat.time(occurrence.at);
    final when = DateUtils.isSameDay(occurrence.at, today)
        ? context.l10n.todayAt(time)
        : context.l10n.yesterdayAt(time);

    return Material(
      color: AppColors.creamLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            if (details.medicine case final m?) ...[
              Image.asset(m.form.image, width: AppSpacing.avatarMd),
              AppSpacing.gapMd,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.reminder.title,
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '$when\n${ReminderText.body(context.l10n, details)}',
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            StatusChip(
              label: context.l10n.takenLate,
              icon: Icons.check_rounded,
              onTap: onTakenLate,
            ),
          ],
        ),
      ),
    );
  }
}
