import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/record_summary.dart';
import 'record_image.dart';
import '../../../../core/localization/l10n.dart';

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
    final caption = (light
            ? AppTextStyles.captionOnLight
            : AppTextStyles.caption)
        .copyWith(color: muted, fontSize: 12);

    return SurfaceCard(
      color: color,
      elevated: true,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg),
                  ),
                  child: RecordImage(
                    relativePath: summary.coverPath,
                    cacheWidth: AppConstants.thumbCacheWidth,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_none_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.pagesCount(summary.pageCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(r.type.icon, size: 14, color: muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r.type.label(context.l10n),
                        style: AppTextStyles.overline.copyWith(
                          color: muted,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  r.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (light
                          ? AppTextStyles.cardTitleOnLight
                          : AppTextStyles.cardTitle)
                      .copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11.5,
                      color: muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppDateFormat.date(r.recordDate),
                      style: caption,
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
}
