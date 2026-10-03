import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/surface_card.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../home_tab.dart';

/// "More" from the nav bar: the less-frequent destinations, each with a
/// one-line description so they're easy to tell apart.
Future<void> showMoreSheet(
  BuildContext context, {
  required HomeTab current,
  required ValueChanged<HomeTab> onSelected,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) {
    final l10n = sheetContext.l10n;
    void open(HomeTab tab) {
      Navigator.pop(sheetContext);
      onSelected(tab);
    }

    final items = [
      (HomeTab.doctors, l10n.moreDoctorsHint, AppColors.olive),
      (HomeTab.records, l10n.moreRecordsHint, AppColors.mint),
      (HomeTab.expenses, l10n.moreExpensesHint, AppColors.accent),
    ];
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.navMore, style: AppTextStyles.titleOnLight),
            AppSpacing.gapMd,
            for (final (tab, hint, color) in items)
              _MoreTile(
                icon: tab.icon,
                color: color,
                title: tab.label(l10n),
                subtitle: hint,
                selected: tab == current,
                onTap: () => open(tab),
              ),
            _MoreTile(
              icon: Icons.settings_rounded,
              color: AppColors.stone,
              title: l10n.settingsTitle,
              subtitle: l10n.moreSettingsHint,
              selected: false,
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  },
);

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SurfaceCard(
        color: selected ? AppColors.sand : AppColors.creamLight,
        padding: AppSpacing.cardPadding,
        radius: AppSpacing.radiusMd,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.textOnDark),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitleOnLight),
                  Text(subtitle, style: AppTextStyles.captionOnLight),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
