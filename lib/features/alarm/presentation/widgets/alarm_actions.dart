import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/localization/l10n.dart';

/// "Medicine Taken ✓" (moss) and "Snooze" (accent) pills, plus Skip for doses.
class AlarmActions extends StatelessWidget {
  const AlarmActions({
    super.key,
    required this.type,
    required this.snoozeMinutes,
    required this.busy,
    required this.onAction,
  });

  final ReminderType type;
  final int snoozeMinutes;
  final bool busy;
  final ValueChanged<AlarmAction> onAction;

  @override
  Widget build(BuildContext context) {
    final isMedicine = type == ReminderType.medicine;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PillButton(
          label: isMedicine
              ? context.l10n.alarmMarkTaken
              : context.l10n.alarmDone,
          tone: PillButtonTone.moss,
          trailingIcon: Icons.check_rounded,
          onPressed: busy ? null : () => onAction(AlarmAction.taken),
        ),
        AppSpacing.gapMd,
        PillButton(
          label:
              '${context.l10n.alarmSnooze} $snoozeMinutes ${context.l10n.minutesShort}',
          trailingIcon: Icons.snooze_rounded,
          onPressed: busy ? null : () => onAction(AlarmAction.snooze),
        ),
        if (isMedicine)
          TextButton(
            onPressed: busy ? null : () => onAction(AlarmAction.skip),
            child: Text(context.l10n.alarmSkip),
          ),
      ],
    );
  }
}
