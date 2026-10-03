import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Wrap of pill-shaped choices ("Sun  Tue  Thu", "Once  Daily"...).
/// Single-select by default; pass [multiSelect] for toggles.
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

  void _toggle(T option) {
    if (!multiSelect) return onChanged({option});
    final next = {...selected};
    next.contains(option) ? next.remove(option) : next.add(option);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          _Pill(
            label: labelOf(option),
            icon: iconOf?.call(option),
            selected: selected.contains(option),
            onDark: onDark,
            onTap: () => _toggle(option),
          ),
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
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

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
            padding: AppSpacing.pillPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSpacing.iconSm, color: fg),
                  AppSpacing.gapXs,
                ],
                Text(label, style: AppTextStyles.chip.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
