import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/course_progress.dart';
import '../../../../core/localization/l10n.dart';

/// "◔ Day 3 of 7 · 4 days left" for a medicine with an end date, with a
/// small ring filling up as the course goes on. Nothing for ongoing ones.
class CourseProgressPill extends StatelessWidget {
  const CourseProgressPill({
    super.key,
    required this.medicine,
    required this.today,
    required this.onLight,
  });

  final Medicine medicine;
  final DateTime today;

  /// Sits on a light card (cream): moss pill. Otherwise a cream pill.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final progress = CourseProgress.of(medicine, today);
    if (progress == null) return const SizedBox.shrink();
    final l = context.l10n;
    final background = onLight ? AppColors.moss : AppColors.creamLight;
    final foreground = onLight ? AppColors.textOnDark : AppColors.ink;

    if (progress.isComplete) {
      return StatusChip(
        label: l.courseComplete,
        icon: Icons.check_circle_rounded,
        background: background,
        foreground: foreground,
      );
    }
    if (progress.notStarted) {
      return StatusChip(
        label: l.courseStarts(AppDateFormat.shortDate(medicine.startDate)),
        icon: Icons.event_rounded,
        background: background,
        foreground: foreground,
      );
    }
    return StatusChip(
      label:
          '${l.courseDayOf(progress.day, progress.totalDays)}'
          '${l.notifDoseSeparator}${l.courseDaysLeft(progress.daysLeft)}',
      background: background,
      foreground: foreground,
      leading: SizedBox.square(
        dimension: AppSpacing.iconSm,
        child: CircularProgressIndicator(
          value: progress.fraction,
          strokeWidth: AppSpacing.progressRingStroke,
          color: foreground,
          backgroundColor: foreground.withValues(
            alpha: AppSpacing.badgeOpacity,
          ),
        ),
      ),
    );
  }
}
