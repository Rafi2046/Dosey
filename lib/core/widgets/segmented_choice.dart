import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Full-width single choice: equal segments in one rounded track
/// ("Phone default | English | বাংলা"). For cream surfaces.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.chipHeight,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: ShapeDecoration(
        color: AppColors.sand,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: labelOf(option),
                icon: iconOf?.call(option),
                selected: option == selected,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
    final fg = selected ? AppColors.onSelected : AppColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: AppSpacing.animFast,
        decoration: ShapeDecoration(
          color: selected ? AppColors.selected : AppColors.transparent,
          shape: const StadiumBorder(),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                // Long labels shrink instead of wrapping.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: AppSpacing.iconSm, color: fg),
                        AppSpacing.gapXs,
                      ],
                      Text(
                        label,
                        style: AppTextStyles.chip.copyWith(color: fg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
