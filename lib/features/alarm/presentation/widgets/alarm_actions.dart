import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/pill_button.dart';

typedef AlarmActionCallback = void Function(
  AlarmAction action, {
  Duration? snoozeFor,
});

/// "Medicine Taken ✓" (moss) and an adjustable "Snooze [ - ] [ 10 mins ] [ + ]"
/// (accent) interactive stepper bar; below them "Remind me later" and Skip.
class AlarmActions extends StatefulWidget {
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
  final AlarmActionCallback onAction;

  /// Opens the "remind me in…" choice; hidden when null.
  final VoidCallback? onRemindLater;

  /// Several medicines at once: "All taken".
  final bool grouped;

  @override
  State<AlarmActions> createState() => _AlarmActionsState();
}

class _AlarmActionsState extends State<AlarmActions> {
  late int _snoozeMinutes;
  static const List<int> _steps = [5, 10, 15, 20, 25, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _snoozeMinutes = widget.snoozeMinutes > 0 ? widget.snoozeMinutes : 10;
  }

  void _decrease() {
    if (widget.busy) return;
    HapticFeedback.lightImpact();
    final prevIndex = _steps.lastIndexWhere((s) => s < _snoozeMinutes);
    if (prevIndex >= 0) {
      setState(() => _snoozeMinutes = _steps[prevIndex]);
    } else if (_snoozeMinutes > 5) {
      setState(() => _snoozeMinutes = (_snoozeMinutes - 5).clamp(5, 60));
    }
  }

  void _increase() {
    if (widget.busy) return;
    HapticFeedback.lightImpact();
    final nextIndex = _steps.indexWhere((s) => s > _snoozeMinutes);
    if (nextIndex >= 0) {
      setState(() => _snoozeMinutes = _steps[nextIndex]);
    } else if (_snoozeMinutes < 60) {
      setState(() => _snoozeMinutes = (_snoozeMinutes + 5).clamp(5, 60));
    }
  }

  bool get _canDecrease => _snoozeMinutes > _steps.first;
  bool get _canIncrease => _snoozeMinutes < _steps.last;

  @override
  Widget build(BuildContext context) {
    final isMedicine = widget.type == ReminderType.medicine;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PillButton(
          label: widget.grouped
              ? l10n.alarmMarkAllTaken
              : isMedicine
              ? l10n.alarmMarkTaken
              : l10n.alarmDone,
          tone: PillButtonTone.moss,
          trailingIcon: Icons.check_rounded,
          scaleDownText: true,
          onPressed: widget.busy
              ? null
              : () => widget.onAction(AlarmAction.taken),
        ),
        AppSpacing.gapMd,
        // Duolingo / Google Clock style interactive Snooze bar with [-] and [+]
        Row(
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              onPressed: !widget.busy && _canDecrease ? _decrease : null,
            ),
            AppSpacing.gapSm,
            Expanded(
              child: PillButton(
                label:
                    '${l10n.alarmSnooze} ${AppNumber.format(_snoozeMinutes)} '
                    '${l10n.minutesShort}',
                tone: PillButtonTone.accent,
                trailingIcon: Icons.snooze_rounded,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                scaleDownText: true,
                onPressed: widget.busy
                    ? null
                    : () => widget.onAction(
                          AlarmAction.snooze,
                          snoozeFor: Duration(minutes: _snoozeMinutes),
                        ),
              ),
            ),
            AppSpacing.gapSm,
            _StepButton(
              icon: Icons.add_rounded,
              onPressed: !widget.busy && _canIncrease ? _increase : null,
            ),
          ],
        ),
        AppSpacing.gapSm,
        // Each link at its own width, side by side and centred
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.lg,
          children: [
            if (widget.onRemindLater case final remindLater?)
              _Link(
                icon: Icons.schedule_rounded,
                label: l10n.remindLater,
                onPressed: widget.busy ? null : remindLater,
              ),
            if (isMedicine)
              _Link(
                icon: Icons.redo_rounded,
                label: l10n.alarmSkip,
                onPressed: widget.busy
                    ? null
                    : () => widget.onAction(AlarmAction.skip),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      duration: AppSpacing.animFast,
      opacity: enabled ? 1.0 : 0.35,
      child: Material(
        color: AppColors.accent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSpacing.circleButton,
            child: Center(
              child: Icon(
                icon,
                color: AppColors.textOnAccent,
                size: AppSpacing.iconMd,
              ),
            ),
          ),
        ),
      ),
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
    style: TextButton.styleFrom(
      foregroundColor: AppColors.textOnDarkMuted,
      visualDensity: VisualDensity.compact,
    ),
  );
}
