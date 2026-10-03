import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/providers/reminders_providers.dart';
import '../../domain/medicine_with_doctor.dart';
import '../../../../core/localization/l10n.dart';

/// Medicine summary: illustration, name/strength, dose, doctor, stock and
/// projected monthly cost.
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
    final reminders = <Reminder>[
      for (final d
          in ref.watch(remindersByMedicineProvider(m.id)).value ?? const [])
        d.reminder,
    ];
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final caption = AppTextStyles.caption.copyWith(color: muted);
    final dose =
        '${ReminderText.doseSummary(reminders, m.doseUnit)}'
        '${context.l10n.notifDoseSeparator}${m.mealRelation.label}';

    return SurfaceCard(
      color: color,
      elevated: true,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(m.form.image, width: AppSpacing.medThumb),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(item.doctor!.name, style: caption),
                AppSpacing.gapMd,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (!m.isActive)
                      StatusChip(
                        label: context.l10n.stopped,
                        icon: Icons.pause_rounded,
                      ),
                    if (item.isLowStock)
                      StatusChip(
                        label: context.l10n.lowStock,
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.accent,
                        foreground: AppColors.textOnAccent,
                      )
                    else if (m.stockQuantity != null)
                      _chip(
                        light,
                        context.l10n.unitsLeft(
                          ReminderText.formatAmount(m.stockQuantity!),
                        ),
                        Icons.inventory_2_rounded,
                      ),
                    if ((monthlyCostMinor ?? 0) > 0)
                      _chip(
                        light,
                        '${Money.format(monthlyCostMinor!)} ${context.l10n.perMonth}',
                        Icons.payments_rounded,
                      ),
                  ],
                ),
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
