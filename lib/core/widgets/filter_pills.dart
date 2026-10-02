import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Horizontally scrolling single-select filter with an "All" option (null),
/// styled for sage screens.
class FilterPills<T> extends StatelessWidget {
  const FilterPills({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <(T?, String)>[
      (null, AppStrings.all),
      for (final o in options) (o, labelOf(o)),
    ];
    return SizedBox(
      height: AppSpacing.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => AppSpacing.gapSm,
        itemBuilder: (context, i) {
          final (value, label) = entries[i];
          final isSelected = value == selected;
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(value),
            labelStyle: AppTextStyles.chip.copyWith(
              color: isSelected ? AppColors.ink : AppColors.textOnDark,
            ),
            backgroundColor: AppColors.moss,
            selectedColor: AppColors.creamLight,
          );
        },
      ),
    );
  }
}
