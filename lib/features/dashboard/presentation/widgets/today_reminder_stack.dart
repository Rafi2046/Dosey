import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/clock_providers.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/overlapping_column.dart';
import '../../../reminders/providers/reminders_providers.dart';
import 'occurrence_action_sheet.dart';
import 'reminder_stack_card.dart';
import '../../../../core/localization/l10n.dart';

/// Today's occurrences as the design's overlapping, color-cycled cards.
/// The first not-yet-handled future occurrence is labelled "Next … in".
class TodayReminderStack extends ConsumerWidget {
  const TodayReminderStack({super.key, required this.onAddReminder});

  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(todayScheduleProvider);
    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();

    return AsyncValueView(
      value: schedule,
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            title: context.l10n.nothingScheduled,
            actionLabel: context.l10n.addReminder,
            onAction: onAddReminder,
          );
        }
        final nextIndex = items.indexWhere(
          (o) => o.status == null && !o.at.isBefore(now),
        );
        return OverlappingColumn(
          overlap: AppSpacing.stackOverlap,
          children: [
            for (final (i, o) in items.indexed)
              ReminderStackCard(
                occurrence: o,
                color: AppColors.cardCycle[i % AppColors.cardCycle.length],
                isNext: i == nextIndex,
                now: now,
                bottomInset: AppSpacing.stackOverlap,
                onTap: () => showOccurrenceActions(context, o),
              ),
          ],
        );
      },
    );
  }
}
