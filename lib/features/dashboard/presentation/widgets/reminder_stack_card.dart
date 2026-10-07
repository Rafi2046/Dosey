import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../medicines/presentation/widgets/course_progress_pill.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/scheduled_occurrence.dart';
import '../../../../core/localization/l10n.dart';

/// One card in the dashboard's overlapping stack, modelled on the design:
/// small "Evening Medicine" label, serif title, two-line body, time pill.
/// [bottomInset] reserves room for the next card's overlap.
class ReminderStackCard extends StatelessWidget {
  const ReminderStackCard({
    super.key,
    required this.occurrence,
    required this.color,
    required this.isNext,
    required this.now,
    this.bottomInset = AppSpacing.stackOverlap,
    required this.onTap,
  });

  final ScheduledOccurrence occurrence;
  final Color color;
  final bool isNext;
  final DateTime now;
  final double bottomInset;
  final VoidCallback onTap;

  bool get _isOverdue =>
      occurrence.status == null && occurrence.at.isBefore(now);

  /// Pill colors follow the design: moss by default, cream for the next
  /// dose, coral accent for an overdue one. Moss/cream contrast with every card
  /// color in the cycle (a mint "taken" pill vanished on mint cards).
  (Color, Color, IconData?) _pillStyle() => switch (occurrence.status) {
    ReminderLogStatus.taken => (
      AppColors.moss,
      AppColors.textOnDark,
      Icons.check_rounded,
    ),
    ReminderLogStatus.takenLate => (
      AppColors.moss,
      AppColors.textOnDark,
      Icons.history_rounded,
    ),
    ReminderLogStatus.skipped => (
      AppColors.moss,
      AppColors.textOnDark,
      Icons.redo_rounded,
    ),
    ReminderLogStatus.missed => (
      AppColors.accent,
      AppColors.textOnAccent,
      Icons.priority_high_rounded,
    ),
    _ when _isOverdue => (AppColors.accent, AppColors.textOnAccent, null),
    _ when isNext => (AppColors.creamLight, AppColors.ink, null),
    _ => (AppColors.moss, AppColors.textOnDark, null),
  };

  @override
  Widget build(BuildContext context) {
    final r = occurrence.details.reminder;
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final overline = isNext
        ? context.l10n.nextTypeIn(
            r.type.label(context.l10n),
            ReminderText.until(context.l10n, occurrence.at, now),
          )
        : ReminderText.slotLabel(context.l10n, r, occurrence.at);
    final (pillBg, pillFg, pillIcon) = _pillStyle();
    final medicine = occurrence.details.medicine;

    return SurfaceCard(
      color: color,
      elevated: true,
      radius: AppSpacing.radiusXl,
      padding: AppSpacing.cardPaddingLg.copyWith(
        bottom: AppSpacing.lg + bottomInset,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      size: AppSpacing.iconSm,
                      color: muted,
                    ),
                    AppSpacing.gapXs,
                    Flexible(
                      child: Text(
                        overline,
                        style: AppTextStyles.overline.copyWith(color: muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                Text(
                  r.title,
                  style: (light
                      ? AppTextStyles.titleOnLight
                      : AppTextStyles.title),
                ),
                AppSpacing.gapXs,
                Text(
                  ReminderText.body(context.l10n, occurrence.details),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: muted),
                ),
                if (medicine != null && medicine.endDate != null) ...[
                  AppSpacing.gapMd,
                  CourseProgressPill(
                    medicine: medicine,
                    today: DateUtils.dateOnly(now),
                    onLight: light,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapMd,
          StatusChip(
            label: AppDateFormat.time(occurrence.at),
            icon: pillIcon,
            background: pillBg,
            foreground: pillFg,
          ),
        ],
      ),
    );
  }
}
