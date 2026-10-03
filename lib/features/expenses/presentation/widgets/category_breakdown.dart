import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/localization/l10n.dart';

/// One bar per category, scaled to the largest, with the amount on the right.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.totals});

  final Map<ExpenseCategory, int> totals;

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = math.max(1, entries.firstOrNull?.value ?? 0);

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Icon(e.key.icon, size: AppSpacing.iconSm, color: e.key.color),
                AppSpacing.gapSm,
                SizedBox(
                  width: AppSpacing.categoryLabelWidth,
                  child: Text(e.key.label(context.l10n), style: AppTextStyles.caption),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: e.value / max,
                      minHeight: AppSpacing.barHeight,
                      color: e.key.color,
                      backgroundColor: AppColors.moss,
                    ),
                  ),
                ),
                AppSpacing.gapMd,
                Text(Money.format(e.value), style: AppTextStyles.chip),
              ],
            ),
          ),
      ],
    );
  }
}
