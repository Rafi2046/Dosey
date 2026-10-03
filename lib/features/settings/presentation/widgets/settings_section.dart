import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// A titled group of settings rows on one rounded card, rows separated by
/// hairlines.
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: AppColors.inkMuted),
            ),
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
