import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/localization/l10n.dart';

/// "Medicine Taken ✓" (moss) and "Snooze" (accent) pills; below them
/// "Remind me later" (a longer snooze, for when it can't be taken now) and,
/// for doses, Skip.
class AlarmActions extends StatelessWidget {
  const AlarmActions({
    super.key,
    required this.type,
    required this.snoozeMinutes,
    required this.busy,
    required this.onAction,
    this.onRemindLater,
    this.grouped = false,
  });

  final ReminderType type;
  final int snoozeMinutes;
  final bool busy;
  final ValueChanged<AlarmAction> onAction;

  /// Opens the "remind me in…" choice; hidden when null.
  final VoidCallback? onRemindLater;

  /// Several medicines at once: "All taken".
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final isMedicine = type == ReminderType.medicine;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PillButton(
          label: grouped
              ? context.l10n.alarmMarkAllTaken
              : isMedicine
              ? context.l10n.alarmMarkTaken
              : context.l10n.alarmDone,
          tone: PillButtonTone.moss,
          trailingIcon: Icons.check_rounded,
          onPressed: busy ? null : () => onAction(AlarmAction.taken),
        ),
        AppSpacing.gapMd,
        PillButton(
          // AppNumber: "১০" in Bengali, "10" in English.
          label:
              '${context.l10n.alarmSnooze} ${AppNumber.format(snoozeMinutes)} '
              '${context.l10n.minutesShort}',
          trailingIcon: Icons.snooze_rounded,
          onPressed: busy ? null : () => onAction(AlarmAction.snooze),
        ),
        AppSpacing.gapSm,
        // Each link at its own width, side by side and centred; if both
        // don't fit (longer English labels), they wrap onto two centred
        // lines rather than being cut off.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.lg,
          children: [
            if (onRemindLater case final remindLater?)
              _Link(
                icon: Icons.schedule_rounded,
                label: context.l10n.remindLater,
                onPressed: busy ? null : remindLater,
              ),
            if (isMedicine)
              _Link(
                icon: Icons.redo_rounded,
                label: context.l10n.alarmSkip,
                onPressed: busy ? null : () => onAction(AlarmAction.skip),
              ),
          ],
        ),
      ],
    );
  }
}

/// Secondary action under the pills: small icon + label.
class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: Icon(icon, size: AppSpacing.iconSm),
    label: Text(label),
    onPressed: onPressed,
  );
}
