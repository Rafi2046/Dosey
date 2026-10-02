import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../home_tab.dart';

/// The design's floating frosted pill of icons with a round orange "+"
/// button beside it.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.current,
    required this.onSelected,
    required this.onAdd,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.bottomBarPadding,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppSpacing.navBarBlur,
                  sigmaY: AppSpacing.navBarBlur,
                ),
                child: Container(
                  height: AppSpacing.navBarHeight,
                  color: AppColors.navBar,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      for (final tab in HomeTab.values)
                        Expanded(
                          child: _NavItem(
                            tab: tab,
                            selected: tab == current,
                            onTap: () => onSelected(tab),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapMd,
          SizedBox.square(
            dimension: AppSpacing.fabSize,
            child: FloatingActionButton(
              heroTag: null,
              elevation: AppSpacing.elevationNone,
              tooltip: AppStrings.add,
              onPressed: onAdd,
              child: const Icon(Icons.add_rounded, size: AppSpacing.iconLg),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final HomeTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.label,
      child: Semantics(
        selected: selected,
        button: true,
        label: tab.label,
        child: InkResponse(
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: AppSpacing.animFast,
              width: AppSpacing.circleButton,
              height: AppSpacing.circleButton,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.ink : AppColors.transparent,
              ),
              child: Icon(
                tab.icon,
                size: AppSpacing.navIcon,
                color: selected ? AppColors.creamLight : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
