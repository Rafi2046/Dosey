import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/bp_category.dart';
import 'bp_category_chip.dart';

/// One history row: "128/84", pulse and time, category chip on the right.
class BpReadingTile extends StatelessWidget {
  const BpReadingTile({super.key, required this.reading, required this.onTap});

  final BloodPressureReading reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = reading;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SurfaceCard(
        color: AppColors.creamLight,
        padding: AppSpacing.cardPadding,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.bpValue(AppNumber.format(r.systolic), AppNumber.format(r.diastolic))} '
                    '${AppConstants.bpUnit}',
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    [
                      AppDateFormat.dateTime(r.measuredAt),
                      if (r.pulse case final p?)
                        l10n.bpPulseValue(AppNumber.format(p)),
                    ].join(l10n.notifDoseSeparator),
                    style: AppTextStyles.captionOnLight,
                  ),
                  if (r.note case final n? when n.isNotEmpty)
                    Text(
                      n,
                      style: AppTextStyles.captionOnLight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            BpCategoryChip(BpCategory.of(r.systolic, r.diastolic)),
          ],
        ),
      ),
    );
  }
}
