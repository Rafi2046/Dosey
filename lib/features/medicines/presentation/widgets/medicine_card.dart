import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/clock_providers.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../domain/medicine_with_doctor.dart';
import '../../providers/medicines_providers.dart';
import 'course_progress_pill.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';

/// Medicine summary: illustration, name/strength, dose, doctor, course
/// countdown, stock and projected monthly cost.
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

    final chips = <Widget>[
      if (!m.isActive)
        StatusChip(label: context.l10n.stopped, icon: Icons.pause_rounded),
      if (m.endDate != null)
        CourseProgressPill(medicine: m, today: today, onLight: light),
      if (stock.isLow)
        StatusChip(
          label: context.l10n.lowStock,
          icon: Icons.warning_amber_rounded,
          background: AppColors.accent,
          foreground: AppColors.textOnAccent,
        )
      else if (m.stockQuantity != null)
        _chip(
          light,
          stock.daysLeft == null
              ? context.l10n.unitsLeft(AppNumber.format(m.stockQuantity!))
              : context.l10n.daysLeft(stock.daysLeft!),
          Icons.inventory_2_rounded,
        ),
      if ((monthlyCostMinor ?? 0) > 0)
        _chip(
          light,
          '${Money.format(monthlyCostMinor!)} ${context.l10n.perMonth}',
          Icons.payments_rounded,
        ),
    ];

    return SurfaceCard(
      color: color,
      elevated: true,
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
                if (item.doctor != null) ...[
                  AppSpacing.gapXs,
                  Text(item.doctor!.name, style: caption),
                ],
                if (chips.isNotEmpty) ...[
                  AppSpacing.gapMd,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: chips,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(bool light, String label, IconData icon) => StatusChip(
    label: label,
    icon: icon,
    background: light ? AppColors.moss : AppColors.creamLight,
    foreground: light ? AppColors.textOnDark : AppColors.ink,
  );
}
