import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/bp_category.dart';
import 'bp_category_chip.dart';

/// The most recent reading, big: "128/84 mmHg", its category, pulse and
/// when it was taken, plus the 7-day average when there is one.
class BpLatestCard extends StatelessWidget {
  const BpLatestCard({super.key, required this.latest, this.average});

  final BloodPressureReading latest;

  /// (systolic, diastolic) over the last 7 days, if 2+ readings.
  final (int, int)? average;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = BpCategory.of(latest.systolic, latest.diastolic);
    return SurfaceCard(
      color: AppColors.cream,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_rounded,
                size: AppSpacing.iconSm,
                color: AppColors.inkMuted,
              ),
              AppSpacing.gapXs,
              Expanded(
                child: Text(
                  l10n.bpLatest,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              BpCategoryChip(category),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.bpValue(
                  AppNumber.format(latest.systolic),
                  AppNumber.format(latest.diastolic),
                ),
                style: AppTextStyles.amount.copyWith(color: AppColors.ink),
              ),
              AppSpacing.gapSm,
              Text(AppConstants.bpUnit, style: AppTextStyles.bodyOnLight),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            [
              if (latest.pulse case final p?)
                l10n.bpPulseValue(AppNumber.format(p)),
              AppDateFormat.dateTime(latest.measuredAt),
            ].join(l10n.notifDoseSeparator),
            style: AppTextStyles.bodyOnLight,
          ),
          if (category == BpCategory.crisis) ...[
            AppSpacing.gapMd,
            Text(
              l10n.bpCrisisHint,
              style: AppTextStyles.bodyOnLight.copyWith(color: AppColors.error),
            ),
          ],
          if (average case (final sys, final dia)?) ...[
            Divider(
              height: AppSpacing.xl,
              thickness: AppSpacing.borderThin,
              color: AppColors.divider,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.bpAverage7,
                    style: AppTextStyles.labelOnLight,
                  ),
                ),
                Text(
                  '${l10n.bpValue(AppNumber.format(sys), AppNumber.format(dia))} '
                  '${AppConstants.bpUnit}',
                  style: AppTextStyles.cardTitleOnLight,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
