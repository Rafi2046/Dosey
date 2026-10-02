import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/record_summary.dart';
import 'record_image.dart';

/// Grid tile: cover photo on top, title / type / date / pages below.
class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.summary,
    required this.color,
    required this.onTap,
  });

  final RecordSummary summary;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = summary.record;
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final caption = AppTextStyles.caption.copyWith(color: muted);

    return SurfaceCard(
      color: color,
      elevated: true,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppSpacing.recordTileThumbHeight,
            child: RecordImage(
              relativePath: summary.coverPath,
              cacheWidth: AppConstants.thumbCacheWidth,
            ),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(r.type.icon, size: AppSpacing.iconSm, color: muted),
                    AppSpacing.gapXs,
                    Expanded(
                      child: Text(
                        r.type.label,
                        style: AppTextStyles.overline.copyWith(color: muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXs,
                Text(
                  r.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: light
                      ? AppTextStyles.cardTitleOnLight
                      : AppTextStyles.cardTitle,
                ),
                AppSpacing.gapXs,
                Text(AppDateFormat.date(r.recordDate), style: caption),
                Text(AppStrings.pagesCount(summary.pageCount), style: caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
