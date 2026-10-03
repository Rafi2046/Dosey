import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_pills.dart';
import '../../../core/widgets/screen_header.dart';
import '../providers/reminders_providers.dart';
import 'reminder_form_screen.dart';
import 'widgets/reminder_tile.dart';

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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: AppSpacing.screenPadding.add(AppSpacing.listBottomPadding),
        children: [
          const ScreenHeader(title: ReminderStrings.remindersTitle),
          FilterPills<ReminderType>(
            options: ReminderType.values,
            selected: filter,
            labelOf: (t) => t.label,
            onSelected: ref.read(reminderTypeFilterProvider.notifier).select,
          ),
          AppSpacing.gapLg,
          AsyncValueView(
            value: reminders,
            data: (list) => list.isEmpty
                ? EmptyState(
                    title: ReminderStrings.noReminders,
                    actionLabel: ReminderStrings.addReminder,
                    onAction: () => _openForm(context),
                  )
                : Column(
                    children: [
                      for (final (i, d) in list.indexed) ...[
                        ReminderTile(
                          details: d,
                          color: AppColors
                              .cardCycle[i % AppColors.cardCycle.length],
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
      ),
    );
  }
}
