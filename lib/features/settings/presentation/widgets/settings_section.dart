import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// A titled group of settings rows on one rounded light card (on the sage
/// Settings page), rows separated by hairlines.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Lines up with the icons inside the card.
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text(title.toUpperCase(), style: AppTextStyles.overline),
          ),
          Material(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, child) in children.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: AppSpacing.borderThin,
                      thickness: AppSpacing.borderThin,
                      indent: AppSpacing.settingsDividerIndent,
                      color: AppColors.divider,
                    ),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
