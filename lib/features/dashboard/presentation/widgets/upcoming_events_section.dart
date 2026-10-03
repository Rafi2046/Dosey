import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';

/// Next few appointments, vaccines and tests. Hidden when none.
class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  static const int _maxItems = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(upcomingEventsProvider).value ?? const [];
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: DashboardStrings.upcoming,
          actionLabel: AppStrings.seeAll,
          onAction: onSeeAll,
        ),
        for (final d in events.take(_maxItems)) ...[
          SurfaceCard(
            color: AppColors.moss,
            padding: AppSpacing.cardPadding,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReminderFormScreen(existing: d.reminder),
              ),
            ),
            child: Row(
              children: [
                Icon(d.reminder.type.icon, color: AppColors.textOnDark),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.reminder.title, style: AppTextStyles.cardTitle),
                      if (d.doctor != null || d.reminder.location != null)
                        Text(
                          d.doctor?.name ?? d.reminder.location!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                StatusChip(
                  label: AppDateFormat.shortDate(d.reminder.nextTriggerAt!),
                  background: AppColors.creamLight,
                  foreground: AppColors.ink,
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
        ],
      ],
    );
  }
}
