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
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelect;

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
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnDark : AppColors.ink;
    return AnimatedContainer(
      duration: AppSpacing.animFast,
      decoration: ShapeDecoration(
        color: selected ? AppColors.moss : AppColors.sand,
        shape: const StadiumBorder(),
      ),
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
