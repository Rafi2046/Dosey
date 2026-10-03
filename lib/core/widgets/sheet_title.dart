import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Bottom-sheet heading with the orange accent line, matching the page
/// headers ("| খাওয়ার সময়").
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSpacing.headerTickWidth,
          height: AppSpacing.sheetTickHeight,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(child: Text(title, style: AppTextStyles.titleOnLight)),
      ],
    );
  }
}
