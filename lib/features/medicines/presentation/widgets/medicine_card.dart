import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/clock_providers.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../domain/course_progress.dart';
import '../../domain/medicine_with_doctor.dart';
import '../../providers/medicines_providers.dart';
import 'course_progress_pill.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';

/// Medicine summary: illustration, name/strength, dose, doctor, then one
/// compact line of facts (course day, stock, monthly cost) and any warning
/// chips (stopped, low stock).
class MedicineCard extends ConsumerWidget {
  const MedicineCard({
    super.key,
    required this.item,
    required this.color,
    required this.onTap,
    this.monthlyCostMinor,
  });

  final MedicineWithDoctor item;
  final Color color;
  final VoidCallback onTap;
  final int? monthlyCostMinor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = item.medicine;
    final stock = ref.watch(stockStatusProvider(m));
    final reminders = <Reminder>[
      for (final d
          in ref.watch(remindersByMedicineProvider(m.id)).value ?? const [])
        d.reminder,
    ];
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final caption = AppTextStyles.caption.copyWith(color: muted);
    final dose =
        '${ReminderText.doseSummary(context.l10n, reminders, m.doseUnit)}'
        '${context.l10n.notifDoseSeparator}${m.mealRelation.label(context.l10n)}';

    final today =
        ref.watch(currentDayProvider).value ??
        DateUtils.dateOnly(DateTime.now());

    final course = CourseProgress.of(m, today);
    final strong = light ? AppColors.ink : AppColors.textOnDark;

    // Warnings stay as filled chips so they stand out.
    final alerts = <Widget>[
      if (!m.isActive)
        StatusChip(label: context.l10n.stopped, icon: Icons.pause_rounded),
      if (stock.isLow)
        StatusChip(
          label: context.l10n.lowStock,
          icon: Icons.warning_amber_rounded,
          background: AppColors.accent,
          foreground: AppColors.textOnAccent,
        ),
    ];
    // Everyday facts: one quiet line of icon + text, no pill backgrounds.
    final stats = <Widget>[
      if (course != null)
        _Stat(
          leading: course.isComplete
              ? Icon(
                  Icons.check_circle_rounded,
                  size: AppSpacing.iconSm,
                  color: strong,
                )
              : CourseProgressPill.ring(course, strong),
          label: course.isComplete
              ? context.l10n.courseComplete
              : course.notStarted
              ? context.l10n.courseStarts(AppDateFormat.shortDate(m.startDate))
              : CourseProgressPill.dayLabel(
                  context.l10n,
                  course,
                  compact: true,
                ),
          style: caption,
        ),
      if (!stock.isLow && m.stockQuantity != null)
        _Stat(
          leading: Icon(
            Icons.inventory_2_rounded,
            size: AppSpacing.iconSm,
            color: strong,
          ),
          label: stock.daysLeft == null
              ? context.l10n.unitsLeft(AppNumber.format(m.stockQuantity!))
              : context.l10n.daysLeft(stock.daysLeft!),
          style: caption,
        ),
      if ((monthlyCostMinor ?? 0) > 0)
        _Stat(
          leading: Icon(
            Icons.payments_rounded,
            size: AppSpacing.iconSm,
            color: strong,
          ),
          label: '${Money.format(monthlyCostMinor!)} ${context.l10n.perMonth}',
          style: caption,
        ),
    ];

    return SurfaceCard(
      color: color,
      elevated: true,
      padding: AppSpacing.cardPadding,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(m.form.image, width: AppSpacing.medThumb),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  [m.name, ?m.strength].join(' '),
                  style: light
                      ? AppTextStyles.cardTitleOnLight
                      : AppTextStyles.cardTitle,
                ),
                AppSpacing.gapXs,
                Text(dose, style: caption),
                if (item.doctor != null)
                  Text(
                    item.doctor!.name,
                    style: caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (stats.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: stats,
                  ),
                ],
                if (alerts.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: alerts,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One fact on the card's stat line: a small icon (or ring) and its text.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.leading,
    required this.label,
    required this.style,
  });

  final Widget leading;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      leading,
      AppSpacing.gapXs,
      Flexible(
        child: Text(
          label,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
