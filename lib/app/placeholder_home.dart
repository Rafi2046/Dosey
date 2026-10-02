import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import '../core/widgets/glass_card.dart';

/// Temporary home that previews the theme. Replaced by the dashboard shell.
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: GlassCard(
            glowColor: AppColors.neonCyan,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.logo, width: AppSpacing.logo),
                AppSpacing.gapMd,
                const Text(AppStrings.appName, style: AppTextStyles.display),
                AppSpacing.gapXs,
                const Text(
                  AppStrings.tagline,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
