import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/sugar_category.dart';
import 'sugar_category_chip.dart';
import 'sugar_value_text.dart';

/// The most recent reading, big: "7.8 mmol/L", when (fasting, after a
/// meal…), its category, plus the 7-day average when there is one.
class SugarLatestCard extends StatelessWidget {
  const SugarLatestCard({super.key, required this.latest, this.average});

  final BloodSugarReading latest;
  final double? average;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = SugarCategory.of(latest.mmol, latest.context);
    return SurfaceCard(
      color: AppColors.cream,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bloodtype_rounded,
                size: AppSpacing.iconSm,
                color: AppColors.inkMuted,
              ),
              AppSpacing.gapXs,
              Expanded(
                child: Text(
                  l10n.sugarLatest,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              SugarCategoryChip(category),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppNumber.format(latest.mmol),
                    style: AppTextStyles.amount.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Text(SugarText.unit, style: AppTextStyles.bodyOnLight),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            [
              latest.context.label(l10n),
              SugarText.mgDl(l10n, latest.mmol),
              AppDateFormat.dateTime(latest.measuredAt),
            ].join(l10n.notifDoseSeparator),
            style: AppTextStyles.bodyOnLight,
          ),
          if (category == SugarCategory.veryLow) ...[
            AppSpacing.gapMd,
            Text(
              l10n.sugarVeryLowHint,
              style: AppTextStyles.bodyOnLight.copyWith(color: AppColors.error),
            ),
          ],
          if (average case final avg?) ...[
            Divider(
              height: AppSpacing.xl,
              thickness: AppSpacing.borderThin,
              color: AppColors.divider,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.sugarAverage7,
                    style: AppTextStyles.labelOnLight,
                  ),
                ),
                Text(
                  SugarText.mmol(avg),
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
