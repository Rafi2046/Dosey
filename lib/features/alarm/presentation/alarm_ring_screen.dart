import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/reminder_alarm_engine.dart';
import '../../reminders/domain/reminder_with_details.dart';
import 'widgets/alarm_actions.dart';
import 'widgets/alarm_details_card.dart';
import 'widgets/alarm_group_card.dart';
import 'widgets/remind_later_sheet.dart';
import 'widgets/shaking_alarm_clock.dart';

/// Full-screen alarm shown over the lock screen when a reminder rings: one
/// reminder, or every medicine due at that minute (acted on together).
/// Closing is driven by `ringingFor` being cleared (see AlarmHost), so a
/// notification-button action elsewhere also dismisses this screen.
class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.group,
    required this.scheduledFor,
  });

  final List<ReminderWithDetails> group;
  final DateTime scheduledFor;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  bool _busy = false;

  /// "Remind me later": how long, then snooze for that long.
  Future<void> _remindLater() async {
    final wait = await showRemindLaterSheet(context);
    if (wait != null) await _act(AlarmAction.snooze, snoozeFor: wait);
  }

  Future<void> _act(AlarmAction action, {Duration? snoozeFor}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(alarmEngineProvider)
          .handleAction(
            reminderIds: [for (final d in widget.group) d.reminder.id],
            scheduledFor: widget.scheduledFor,
            action: action,
            snoozeFor: snoozeFor,
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final reminder = group.first.reminder;
    // Shortest snooze of the group, so nobody's dose is pushed too late.
    final snooze = group
        .map((d) => d.reminder.snoozeMinutes)
        .reduce((a, b) => a < b ? a : b);

    return PopScope(
      // Must be answered explicitly; back gesture doesn't silence the alarm.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 700;
              final clockHeight = isCompact
                  ? (constraints.maxHeight * 0.18).clamp(90.0, 130.0)
                  : (constraints.maxHeight * 0.22).clamp(140.0, 185.0);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(
                      0.0,
                      constraints.maxHeight - AppSpacing.screenPadding.vertical,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        if (!isCompact) const Spacer(),
                        ShakingAlarmClock(height: clockHeight),
                        SizedBox(
                          height: isCompact ? AppSpacing.md : AppSpacing.lg,
                        ),
                        if (group.length == 1)
                          AlarmDetailsCard(
                            details: group.single,
                            scheduledFor: widget.scheduledFor,
                          )
                        else
                          AlarmGroupCard(
                            group: group,
                            scheduledFor: widget.scheduledFor,
                          ),
                        const Spacer(),
                        SizedBox(
                          height: isCompact ? AppSpacing.sm : AppSpacing.md,
                        ),
                        AlarmActions(
                          type: reminder.type,
                          snoozeMinutes: snooze,
                          grouped: group.length > 1,
                          busy: _busy,
                          onAction: _act,
                          onRemindLater: _remindLater,
                        ),
                        SizedBox(
                          height: isCompact ? AppSpacing.xs : AppSpacing.sm,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
