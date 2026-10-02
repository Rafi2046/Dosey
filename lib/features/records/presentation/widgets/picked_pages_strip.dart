import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Horizontal strip of freshly picked (not yet saved) pages with remove
/// buttons and an "add" tile.
class PickedPagesStrip extends StatelessWidget {
  const PickedPagesStrip({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
    this.errorText,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    return LabeledField(
      label: AppStrings.recordPages,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppSpacing.pageStripHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final path in paths) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: radius,
                        child: Image.file(
                          File(path),
                          width: AppSpacing.pageStripThumbWidth,
                          height: AppSpacing.pageStripHeight,
                          fit: BoxFit.cover,
                          cacheWidth: AppConstants.stripCacheWidth,
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: IconButton.filled(
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.scrim,
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textOnDark,
                          ),
                          onPressed: () => onRemove(path),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapSm,
                ],
                Material(
                  color: AppColors.creamLight,
                  borderRadius: radius,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAdd,
                    child: const SizedBox(
                      width: AppSpacing.pageStripThumbWidth,
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.inkMuted,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorText != null) ...[
            AppSpacing.gapSm,
            Text(errorText!, style: AppTextStyles.errorText),
          ],
        ],
      ),
    );
  }
}
