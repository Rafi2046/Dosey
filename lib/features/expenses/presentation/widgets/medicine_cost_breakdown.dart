import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/medicine_cost_projection.dart';

/// Per-medicine projected cost: doses per day and monthly total.
class MedicineCostBreakdown extends StatelessWidget {
  const MedicineCostBreakdown({super.key, required this.projection});

  final MedicineCostProjection projection;

  @override
  Widget build(BuildContext context) {
    final lines = projection.lines.where((l) => l.monthlyMinor > 0).toList();
    return SurfaceCard(
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExpenseStrings.projectedHint,
            style: AppTextStyles.captionOnLight,
          ),
          AppSpacing.gapMd,
          if (lines.isEmpty)
            Text(ExpenseStrings.noProjection, style: AppTextStyles.bodyOnLight)
          else
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
                            ExpenseStrings.unitsPerDayLabel(
                              line.unitsPerDay,
                              line.medicine.doseUnit,
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
