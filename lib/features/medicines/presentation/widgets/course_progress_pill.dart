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
    this.compact = false,
    this.muted = false,
  });

  final Medicine medicine;
  final DateTime today;

  /// Sits on a light card (cream): moss pill. Otherwise a cream pill.
  final bool onLight;

  /// Narrow spots (Home cards): "Day 3 of 7" alone, or "Last day".
  final bool compact;

  /// Quiet sand chip on cream (alarm card, detail page) instead of a
  /// filled one.
  final bool muted;

  /// "Day 3 of 7" (compact) or "Day 3 of 7 · 4 days left"; "Last day" in
  /// compact form on the final day.
  static String dayLabel(
    AppLocalizations l,
    CourseProgress progress, {
    bool compact = false,
  }) => switch ((compact, progress.daysLeft)) {
    (true, 0) => l.courseDaysLeft(0),
    (true, _) => l.courseDayOf(progress.day, progress.totalDays),
    _ =>
      '${l.courseDayOf(progress.day, progress.totalDays)}'
          '${l.notifDoseSeparator}${l.courseDaysLeft(progress.daysLeft)}',
  };

  /// Small ring filled to how far the course has got.
  static Widget ring(CourseProgress progress, Color color) => SizedBox.square(
    dimension: AppSpacing.iconSm,
    child: CircularProgressIndicator(
      value: progress.fraction,
      strokeWidth: AppSpacing.progressRingStroke,
      color: color,
      backgroundColor: color.withValues(alpha: AppSpacing.badgeOpacity),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final progress = CourseProgress.of(medicine, today);
    if (progress == null) return const SizedBox.shrink();
    final l = context.l10n;
    final (background, foreground) = muted
        ? (AppColors.sand, AppColors.ink)
        : onLight
        ? (AppColors.moss, AppColors.textOnDark)
        : (AppColors.creamLight, AppColors.ink);

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
      label: dayLabel(l, progress, compact: compact),
      background: background,
      foreground: foreground,
      leading: ring(progress, foreground),
    );
  }
}
