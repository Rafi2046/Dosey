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
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedScale(
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
              Flexible(
                child: Image.asset(
                  image,
                  height: AppSpacing.medTypeImage,
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.gapMd,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: light
                    ? AppTextStyles.cardTitleOnLight
                    : AppTextStyles.cardTitle,
              ),
              AppSpacing.gapXs,
              AnimatedOpacity(
                duration: AppSpacing.animFast,
                opacity: selected ? 1.0 : 0.0,
                child: ExcludeSemantics(
                  excluding: !selected,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: AppSpacing.iconSm,
                    color: light ? AppColors.ink : AppColors.textOnDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
