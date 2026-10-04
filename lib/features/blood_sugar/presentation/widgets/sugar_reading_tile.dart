import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/sugar_category.dart';
import 'sugar_category_chip.dart';
import 'sugar_value_text.dart';

/// One history row: "7.8 mmol/L", when it was taken, category on the right.
class SugarReadingTile extends StatelessWidget {
  const SugarReadingTile({
    super.key,
    required this.reading,
    required this.onTap,
  });

  final BloodSugarReading reading;
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
                    SugarText.mmol(r.mmol),
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    r.context.label(l10n),
                    style: AppTextStyles.captionOnLight,
                  ),
                  Text(
                    AppDateFormat.dateTime(r.measuredAt),
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
            SugarCategoryChip(SugarCategory.of(r.mmol, r.context)),
          ],
        ),
      ),
    );
  }
}
