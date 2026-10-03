import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/constants.dart';

/// Shimmering placeholders shown while a screen's data loads, shaped like
/// the content that's coming, in light and dark mode.
class Skeleton extends StatelessWidget {
  /// A column of card-shaped blocks (lists: medicines, reminders, records…).
  const Skeleton.cards({super.key, this.onLight = false}) : _detail = false;

  /// A header block and text lines (detail pages on cream).
  const Skeleton.detail({super.key, this.onLight = true}) : _detail = true;

  /// On a cream surface (dark shimmer) rather than the sage background.
  final bool onLight;
  final bool _detail;

  @override
  Widget build(BuildContext context) {
    final tone = onLight ? AppColors.ink : AppColors.textOnDark;
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: Shimmer.fromColors(
        period: AppSpacing.shimmerPeriod,
        baseColor: tone.withValues(alpha: AppSpacing.skeletonFaint),
        highlightColor: tone.withValues(alpha: AppSpacing.skeletonShine),
        child: _detail ? const _DetailShape() : const _CardsShape(),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, this.width, this.radius});

  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      // Shimmer paints over this with its gradient; any opaque color works.
      color: AppColors.textOnAccent,
      borderRadius: BorderRadius.circular(radius ?? AppSpacing.radiusLg),
    ),
  );
}

class _CardsShape extends StatelessWidget {
  const _CardsShape();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < AppSpacing.skeletonCount; i++) ...[
          if (i > 0) AppSpacing.gapMd,
          const _Block(height: AppSpacing.skeletonCard),
        ],
      ],
    );
  }
}

class _DetailShape extends StatelessWidget {
  const _DetailShape();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: LayoutBuilder(
        builder: (context, box) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Block(height: AppSpacing.skeletonHeader),
            AppSpacing.gapXl,
            for (final fraction in const [0.5, 0.9, 0.75, 0.35, 0.8, 0.6]) ...[
              _Block(
                height: AppSpacing.skeletonLine,
                width: box.maxWidth * fraction,
                radius: AppSpacing.xs,
              ),
              AppSpacing.gapMd,
            ],
          ],
        ),
      ),
    );
  }
}
