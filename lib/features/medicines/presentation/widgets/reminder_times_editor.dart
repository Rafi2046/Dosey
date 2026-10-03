import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../domain/dose_time.dart';
import 'dose_time_sheet.dart';
import '../../../../core/localization/l10n.dart';

/// "Medicine Time": one-tap Morning · Lunch · Dinner · Bedtime buttons, then
/// a chip per time with its own amount (08:00 · 2 tablet), plus "Add time"
/// for anything else. Tap a chip to change or remove it.
class ReminderTimesEditor extends StatelessWidget {
  const ReminderTimesEditor({
    super.key,
    required this.doses,
    required this.unit,
    required this.onChanged,
  });

  final List<DoseTime> doses;

  /// The medicine's dose unit, e.g. "tablet".
  final String unit;
  final ValueChanged<List<DoseTime>> onChanged;

  /// Default for a new time: the first unused morning/noon/night slot.
  DoseTime _suggestion() {
    final used = {for (final d in doses) d.minutes};
    for (final hour in const [
      AppConstants.doseMorningHour,
      AppConstants.doseNoonHour,
      AppConstants.doseNightHour,
    ]) {
      if (!used.contains(hour * 60)) {
        return DoseTime(TimeOfDay(hour: hour, minute: 0));
      }
    }
    return DoseTime(TimeOfDay.now());
  }

  /// Amount for a newly added time: same as the latest one ("2 tablets
  /// three times a day" only needs setting once).
  double get _defaultAmount => doses.isEmpty ? 1 : doses.last.amount;

  void _toggleSlots(Set<_Slot> selected) {
    final before = {
      for (final s in _Slot.values)
        if (_has(s)) s,
    };
    final added = selected.difference(before);
    final removed = before.difference(selected);
    onChanged(
      DoseTime.sorted([
        for (final d in doses)
          if (!removed.any((s) => s.minutes == d.minutes)) d,
        for (final s in added) DoseTime(s.time, _defaultAmount),
      ]),
    );
  }

  bool _has(_Slot slot) => doses.any((d) => d.minutes == slot.minutes);

  Future<void> _add(BuildContext context) async {
    final result = await showDoseTimeSheet(
      context,
      initial: _suggestion().copyWith(amount: _defaultAmount),
      unit: unit,
    );
    if (result is! DoseSaved) return;
    // Same time twice: the new amount replaces the old one.
    onChanged(
      DoseTime.sorted([
        for (final d in doses)
          if (d.minutes != result.dose.minutes) d,
        result.dose,
      ]),
    );
  }

  Future<void> _edit(BuildContext context, DoseTime dose) async {
    final result = await showDoseTimeSheet(
      context,
      initial: dose,
      unit: unit,
      canRemove: true,
    );
    switch (result) {
      case DoseSaved(dose: final updated):
        onChanged(
          DoseTime.sorted([
            for (final d in doses)
              if (d != dose && d.minutes != updated.minutes) d,
            updated,
          ]),
        );
      case DoseRemoved():
        onChanged([...doses]..remove(dose));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: context.l10n.medicineTime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoicePills<_Slot>(
            options: _Slot.values,
            selected: {
              for (final s in _Slot.values)
                if (_has(s)) s,
            },
            multiSelect: true,
            iconOf: (s) => s.icon,
            labelOf: (s) => s.label(context.l10n),
            onChanged: _toggleSlots,
          ),
          AppSpacing.gapSm,
          Text(
            context.l10n.quickTimesHint,
            style: AppTextStyles.captionOnLight,
          ),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final d in doses)
                StatusChip(
                  label:
                      '${d.time.format(context).toLowerCase()}'
                      '${context.l10n.notifDoseSeparator}'
                      '${ReminderText.dose(d.amount, unit)}',
                  icon: Icons.edit_rounded,
                  background: AppColors.sand,
                  foreground: AppColors.ink,
                  onTap: () => _edit(context, d),
                ),
              StatusChip(
                label: context.l10n.addTime,
                icon: Icons.add_alarm_rounded,
                onTap: () => _add(context),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            context.l10n.reminderTimesHint,
            style: AppTextStyles.captionOnLight,
          ),
        ],
      ),
    );
  }
}

/// Quick-add intake times.
enum _Slot {
  morning(AppConstants.doseMorningHour, 0, Icons.wb_sunny_rounded),
  lunch(AppConstants.doseNoonHour, 0, Icons.lunch_dining_rounded),
  dinner(AppConstants.doseNightHour, 0, Icons.dinner_dining_rounded),
  bedtime(
    AppConstants.doseBedtimeHour,
    AppConstants.doseBedtimeMinute,
    Icons.bedtime_rounded,
  );

  const _Slot(this.hour, this.minute, this.icon);

  final int hour;
  final int minute;
  final IconData icon;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);
  int get minutes => hour * 60 + minute;

  String label(AppLocalizations l) => switch (this) {
    morning => l.slotMorning,
    lunch => l.slotLunch,
    dinner => l.slotDinner,
    bedtime => l.slotBedtime,
  };
}
