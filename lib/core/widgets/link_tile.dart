import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Compact row on cream screens linking to a related item (a doctor's
/// medicines, records, appointments...).
class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.inkMuted),
          title: Text(title, style: AppTextStyles.inputOnLight),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: AppTextStyles.captionOnLight),
          trailing: onTap == null
              ? null
              : Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ),
      ),
    );
  }
}
