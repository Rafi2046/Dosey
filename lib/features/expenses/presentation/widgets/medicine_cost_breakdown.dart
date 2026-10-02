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
          Text(AppStrings.projectedHint, style: AppTextStyles.captionOnLight),
          AppSpacing.gapMd,
          if (lines.isEmpty)
            Text(AppStrings.noProjection, style: AppTextStyles.bodyOnLight)
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
                            AppStrings.dosesPerDayLabel(line.dosesPerDay),
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
