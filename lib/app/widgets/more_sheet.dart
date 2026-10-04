import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/surface_card.dart';
import '../../features/blood_pressure/presentation/blood_pressure_screen.dart';
import '../../features/blood_sugar/presentation/blood_sugar_screen.dart';
import '../../features/reminders/presentation/dose_history_screen.dart';
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
      (HomeTab.doctors, l10n.moreDoctorsHint, AppColors.tileOlive),
      (HomeTab.records, l10n.moreRecordsHint, AppColors.tileMint),
      (HomeTab.expenses, l10n.moreExpensesHint, AppColors.accent),
    ];
    return FractionallySizedBox(
      heightFactor: AppSpacing.moreSheetHeightFactor,
      child: SafeArea(
        top: false,
        // Scrolls on short screens rather than overflowing.
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l10n.moreSheetHeader,
                subtitle: l10n.moreSheetSubtitle,
                onLight: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              ),
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
                icon: Icons.history_rounded,
                color: AppColors.tileMint,
                title: l10n.historyLink,
                subtitle: l10n.moreHistoryHint,
                selected: false,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoseHistoryScreen(),
                    ),
                  );
                },
              ),
              _MoreTile(
                icon: Icons.monitor_heart_rounded,
                color: AppColors.tileMoss,
                title: l10n.bpShortTitle,
                subtitle: l10n.moreBpHint,
                selected: false,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BloodPressureScreen(),
                    ),
                  );
                },
              ),
              _MoreTile(
                icon: Icons.bloodtype_rounded,
                color: AppColors.error,
                title: l10n.sugarShortTitle,
                subtitle: l10n.moreSugarHint,
                selected: false,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BloodSugarScreen(),
                    ),
                  );
                },
              ),
              _MoreTile(
                icon: Icons.settings_rounded,
                color: AppColors.tileStone,
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
            Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
