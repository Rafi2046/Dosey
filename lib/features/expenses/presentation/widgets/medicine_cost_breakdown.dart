import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/medicine_cost_projection.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/utils/dose_unit.dart';

/// Per-medicine projected cost: doses per day and monthly total.
class MedicineCostBreakdown extends StatelessWidget {
  const MedicineCostBreakdown({super.key, required this.projection});

  final MedicineCostProjection projection;

  @override
  Widget build(BuildContext context) {
    final lines = projection.lines.where((l) => l.monthlyMinor > 0).toList();
    // Nothing priced yet: a one-line tip instead of an empty card.
    if (lines.isEmpty) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineOnDark),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Text(
                context.l10n.noProjection,
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ],
        ),
      );
    }
    return SurfaceCard(
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.projectedHint, style: AppTextStyles.captionOnLight),
          AppSpacing.gapSm,
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.medicine.name,
                          style: AppTextStyles.cardTitleOnLight,
                        ),
                        Text(
                          context.l10n.unitsPerDayLabel(
                            AppNumber.format(line.unitsPerDay),
                            DoseUnit.display(
                              line.medicine.doseUnit,
                              context.l10n,
                            ),
                          ),
                          style: AppTextStyles.captionOnLight,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Money.format(line.monthlyMinor),
                    style: AppTextStyles.subtitleOnLight,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
