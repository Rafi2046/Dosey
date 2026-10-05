import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_pills.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../providers/reminders_providers.dart';
import 'reminder_form_screen.dart';
import 'widgets/reminder_tile.dart';
import '../../../core/localization/l10n.dart';
import '../../profiles/presentation/profile_widgets.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  void _openForm(BuildContext context, [ReminderFormScreen? screen]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => screen ?? const ReminderFormScreen(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reminderTypeFilterProvider);
    final reminders = ref.watch(filteredRemindersProvider);
    final repo = ref.read(remindersRepositoryProvider);

    return TabScrollView(
      // Nothing to list: centre the empty state in the space left.
      centerLast: reminders.value?.isEmpty ?? false,
      onRefresh: () async {
        ref.invalidate(remindersProvider);
      },
      children: [
        ScreenHeader(
          // Whose list this is (only shown with family profiles).
          trailing: const ProfilePill(),
          title: context.l10n.remindersTitle,
          subtitle: switch (reminders.value) {
            final list? => context.l10n.headerRemindersCount(list.length),
            null => null,
          },
        ),
        FilterPills<ReminderType>(
          options: ReminderType.values,
          selected: filter,
          labelOf: (t) => t.label(context.l10n),
          onSelected: ref.read(reminderTypeFilterProvider.notifier).select,
        ),
        AppSpacing.gapLg,
        AsyncValueView(
          value: reminders,
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.l10n.noReminders,
                  actionLabel: context.l10n.addReminder,
                  onAction: () => _openForm(context),
                )
              : Column(
                  children: [
                    for (final (i, d) in list.indexed) ...[
                      ReminderTile(
                        details: d,
                        color:
                            AppColors.cardCycle[i % AppColors.cardCycle.length],
                        onTap: () => _openForm(
                          context,
                          ReminderFormScreen(existing: d.reminder),
                        ),
                        onToggle: (on) =>
                            repo.setEnabled(d.reminder.id, enabled: on),
                      ),
                      AppSpacing.gapMd,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
