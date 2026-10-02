import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/surface_card.dart';

/// One tile of the "Choose Medicine Type" grid: illustration over a serif
/// label, raised when selected.
class MedicineTypeTile extends StatelessWidget {
  const MedicineTypeTile({
    super.key,
    required this.label,
    required this.image,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String image;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = SurfaceCard.isLight(color);
    return AnimatedScale(
      duration: AppSpacing.animFast,
      scale: selected ? 1 : AppSpacing.unselectedTileScale,
      child: SurfaceCard(
        color: color,
        elevated: selected,
        padding: AppSpacing.cardPadding,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: AppSpacing.medTypeImage),
            AppSpacing.gapMd,
            Text(
              label,
              style: light
                  ? AppTextStyles.cardTitleOnLight
                  : AppTextStyles.cardTitle,
            ),
            if (selected) ...[
              AppSpacing.gapXs,
              Icon(
                Icons.check_circle_rounded,
                size: AppSpacing.iconSm,
                color: light ? AppColors.ink : AppColors.textOnDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
