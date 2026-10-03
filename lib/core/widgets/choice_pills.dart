import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Pill-shaped choices ("Sun  Tue  Thu", "Once  Daily"...). Single-select
/// by default; pass [multiSelect] for toggles.
///
/// By default they wrap at their natural widths. With [columns] they sit
/// on an even grid instead: equal widths, so both edges line up and no row
/// ends in a ragged gap.
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
    this.multiSelect = false,
    this.onDark = false,
    this.columns,
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelect;

  /// Use on sage screens: selected = cream, unselected = moss (on cream
  /// forms it's the reverse, matching the design's chips).
  final bool onDark;

  /// Pills per row on an even grid; null wraps at natural widths.
  final int? columns;

  void _toggle(T option) {
    if (!multiSelect) return onChanged({option});
    final next = {...selected};
    next.contains(option) ? next.remove(option) : next.add(option);
    onChanged(next);
  }

  Widget _pill(T option, {bool fill = false}) => _Pill(
    label: labelOf(option),
    icon: iconOf?.call(option),
    selected: selected.contains(option),
    onDark: onDark,
    fill: fill,
    onTap: () => _toggle(option),
  );

  @override
  Widget build(BuildContext context) {
    final perRow = columns;
    if (perRow == null) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [for (final option in options) _pill(option)],
      );
    }
    return Column(
      children: [
        for (var start = 0; start < options.length; start += perRow) ...[
          if (start > 0) AppSpacing.gapSm,
          Row(
            children: [
              for (var i = start; i < start + perRow; i++) ...[
                if (i > start) AppSpacing.gapSm,
                // Empty cells keep the last row on the same grid.
                Expanded(
                  child: i < options.length
                      ? _pill(options[i], fill: true)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onDark,
    this.icon,
    this.fill = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

  /// Takes the full cell width (grid mode), label centred and shrunk if
  /// it doesn't fit.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch ((selected, onDark)) {
      (true, false) => (AppColors.selected, AppColors.onSelected),
      (false, false) => (AppColors.sand, AppColors.ink),
      (true, true) => (AppColors.highlight, AppColors.onHighlight),
      (false, true) => (AppColors.moss, AppColors.textOnDark),
    };
    return AnimatedContainer(
      duration: AppSpacing.animFast,
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Material(
        type: MaterialType.transparency,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: fill
                ? AppSpacing.pillPadding.copyWith(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                  )
                : AppSpacing.pillPadding,
            child: _content(fg),
          ),
        ),
      ),
    );
  }

  Widget _content(Color fg) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSpacing.iconSm, color: fg),
          AppSpacing.gapXs,
        ],
        Text(label, style: AppTextStyles.chip.copyWith(color: fg)),
      ],
    );
    if (!fill) return row;
    return Center(
      child: FittedBox(fit: BoxFit.scaleDown, child: row),
    );
  }
}
