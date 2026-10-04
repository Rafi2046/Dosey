import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// Icon in a tinted circle, a short title and one line of explanation.
class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      // Icon centred on its title + explanation, however many lines they wrap
      // to (top-aligned, it hung off the title line).
      child: Row(
        children: [
          Container(
            width: AppSpacing.featureIcon,
            height: AppSpacing.featureIcon,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.textOnDark),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                AppSpacing.gapXs,
                Text(body, style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
