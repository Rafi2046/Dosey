import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../settings/presentation/settings_screen.dart';

/// "Good morning" with the app mark on the left and a bell on the right,
/// following the design's "Hello, Lora" header.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.now,
    required this.onBellTap,
  });

  final DateTime now;
  final VoidCallback onBellTap;

  String _greeting(AppLocalizations l) => switch (now.hour) {
    < 12 => l.goodMorning,
    < 17 => l.goodAfternoon,
    _ => l.goodEvening,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              AppImages.logo,
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Text(_greeting(context.l10n), style: AppTextStyles.subtitle),
          ),
          IconButton(
            tooltip: context.l10n.settingsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.textOnDark,
            ),
          ),
          IconButton(
            tooltip: context.l10n.navReminders,
            onPressed: onBellTap,
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.textOnDark,
            ),
          ),
        ],
      ),
    );
  }
}
