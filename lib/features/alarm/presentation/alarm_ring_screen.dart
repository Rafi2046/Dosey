import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/reminder_alarm_engine.dart';
import '../../reminders/domain/reminder_with_details.dart';
import 'widgets/alarm_actions.dart';
import 'widgets/alarm_details_card.dart';
import 'widgets/shaking_alarm_clock.dart';

/// Full-screen alarm shown over the lock screen when a reminder rings.
/// Closing is driven by `ringingFor` being cleared (see AlarmHost), so a
/// notification-button action elsewhere also dismisses this screen.
class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.details,
    required this.scheduledFor,
  });

  final ReminderWithDetails details;
  final DateTime scheduledFor;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  bool _busy = false;

  Future<void> _act(AlarmAction action) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(alarmEngineProvider)
          .handleAction(
            reminderId: widget.details.reminder.id,
            scheduledFor: widget.scheduledFor,
            action: action,
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.details.reminder;
    return PopScope(
      // Must be answered explicitly; back gesture doesn't silence the alarm.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const Spacer(),
                const ShakingAlarmClock(),
                AppSpacing.gapXl,
                AlarmDetailsCard(
                  details: widget.details,
                  scheduledFor: widget.scheduledFor,
                ),
                const Spacer(),
                AlarmActions(
                  type: reminder.type,
                  snoozeMinutes: reminder.snoozeMinutes,
                  busy: _busy,
                  onAction: _act,
                ),
                AppSpacing.gapLg,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
