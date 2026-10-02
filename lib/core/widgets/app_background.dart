import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Deep-navy gradient with soft cyan orbs, giving [GlassCard]s something to blur.
/// Placed once under the whole app via `MaterialApp.builder`.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Stack(
        children: [
          const _GlowOrb(alignment: AppSpacing.orbTopLeft),
          const _GlowOrb(alignment: AppSpacing.orbBottomRight),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).shortestSide;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.neonGlowFaint, AppColors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
