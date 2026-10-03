import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/localization/l10n.dart';
import '../home_tab.dart';

/// Bottom navigation: Home · Reminders · (+) · Medicines · More.
///
/// Every destination has a label (icons alone were hard to tell apart), the
/// most-used screens are one tap away, and the rest (doctors, records,
/// expenses, settings) live behind More, which stays highlighted while one
/// of them is open.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.current,
    required this.onSelected,
    required this.onAdd,
    required this.onMore,
  });

  /// Tabs shown directly in the bar; the rest are under More.
  static const List<HomeTab> primary = [
    HomeTab.dashboard,
    HomeTab.reminders,
    HomeTab.medicines,
  ];

  final HomeTab current;
  final ValueChanged<HomeTab> onSelected;
  final VoidCallback onAdd;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tab(HomeTab t) => Expanded(
      child: _NavItem(
        icon: t.icon,
        label: t.label(l10n),
        selected: current == t,
        onTap: () => onSelected(t),
      ),
    );

    return Padding(
      padding: AppSpacing.navBarMargin,
      child: SizedBox(
        height: AppSpacing.navBarHeight + AppSpacing.navAddLift,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.moss,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppSpacing.shadowBlur,
                    offset: AppSpacing.shadowOffset,
                  ),
                ],
              ),
              child: Container(
                height: AppSpacing.navBarHeight,
                // Keeps the end tabs' highlight clear of the rounded corners.
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                // Five equal slots, "+" in the middle one: perfectly
                // symmetric spacing on every screen width.
                child: Row(
                  children: [
                    tab(HomeTab.dashboard),
                    tab(HomeTab.reminders),
                    const Spacer(),
                    tab(HomeTab.medicines),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.grid_view_rounded,
                        label: l10n.navMore,
                        selected: !primary.contains(current),
                        onTap: onMore,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _AddButton(tooltip: l10n.add, onPressed: onAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.textOnDarkMuted;
    return Tooltip(
      message: label,
      child: Semantics(
        selected: selected,
        button: true,
        excludeSemantics: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: AppSpacing.navIndicatorWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppSpacing.animFast,
                curve: Curves.easeOut,
                width: AppSpacing.navIndicatorWidth,
                height: AppSpacing.navIndicatorHeight,
                decoration: BoxDecoration(
                  color: selected ? AppColors.cream : AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Icon(icon, size: AppSpacing.iconMd, color: color),
              ),
              AppSpacing.gapXs,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.navLabel.copyWith(
                  color: selected
                      ? AppColors.textOnDark
                      : AppColors.textOnDarkMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.accent,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.moss, width: AppSpacing.xs),
        ),
        elevation: AppSpacing.xs,
        shadowColor: AppColors.accent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox.square(
            dimension: AppSpacing.navAddButton,
            child: Icon(
              Icons.add_rounded,
              size: AppSpacing.iconLg,
              color: AppColors.textOnAccent,
            ),
          ),
        ),
      ),
    );
  }
}
