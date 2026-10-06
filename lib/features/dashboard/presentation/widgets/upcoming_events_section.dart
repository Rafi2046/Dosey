import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../../../core/localization/l10n.dart';

/// Next few appointments, vaccines and tests. Hidden when none.
class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  static const int _maxItems = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(
      upcomingRemindersProvider.select(
        (r) => (r.value ?? const [])
            .where((d) => d.reminder.type != ReminderType.medicine)
            .toList(),
      ),
    );
    if (events.isEmpty) return const SizedBox.shrink();

    final displayEvents = events.take(_maxItems).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: context.l10n.upcoming,
          actionLabel: context.l10n.seeAll,
          onAction: onSeeAll,
        ),
        for (int i = 0; i < displayEvents.length; i++) ...[
          SurfaceCard(
            color: AppColors.moss,
            padding: AppSpacing.cardPadding,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ReminderFormScreen(existing: displayEvents[i].reminder),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  displayEvents[i].reminder.type.icon,
                  color: AppColors.textOnDark,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayEvents[i].reminder.title,
                        style: AppTextStyles.cardTitle,
                      ),
                      if (displayEvents[i].doctor != null ||
                          displayEvents[i].reminder.location != null)
                        Text(
                          displayEvents[i].doctor?.name ??
                              displayEvents[i].reminder.location!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                StatusChip(
                  label: AppDateFormat.shortDate(
                    displayEvents[i].reminder.nextTriggerAt!,
                  ),
                  background: AppColors.creamLight,
                  foreground: AppColors.ink,
                ),
              ],
            ),
          ),
          if (i < displayEvents.length - 1) AppSpacing.gapSm,
        ],
      ],
    );
  }
}
