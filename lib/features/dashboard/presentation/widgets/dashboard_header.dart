import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../profiles/presentation/profile_widgets.dart';
import '../../../profiles/providers/profiles_providers.dart';
import '../../../settings/presentation/settings_screen.dart';

/// "Good morning" with the app mark on the left and a bell on the right,
/// following the design's "Hello, Lora" header. Integrated with profile switcher.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    required this.now,
    required this.onBellTap,
    this.name,
  });

  final DateTime now;

  /// The user's name, added to the greeting when set.
  final String? name;
  final VoidCallback onBellTap;

  String _greeting(AppLocalizations l) => switch (now.hour) {
    < 12 => l.goodMorning,
    < 17 => l.goodAfternoon,
    _ => l.goodEvening,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final activeProfile = ref.watch(activeProfileProvider);
    final hasMultipleProfiles = profiles.length > 1;
    // The user's own, unnamed profile shows their name ("Rafi", not "Me");
    // "Me" only when there's no name and a family member to switch to.
    final ownName = name ?? '';
    final displayName = switch (activeProfile) {
      final p? when p.name.isNotEmpty => p.name,
      _ when ownName.isNotEmpty => ownName,
      _ when hasMultipleProfiles => context.l10n.profileMe,
      _ => '',
    };

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
            child: InkWell(
              onTap: hasMultipleProfiles
                  ? () => showProfileSwitcher(context)
                  : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: displayName.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _greeting(context.l10n),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnDarkMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasMultipleProfiles) ...[
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 20,
                                  color: AppColors.textOnDark,
                                ),
                              ],
                            ],
                          ),
                        ],
                      )
                    : Text(
                        _greeting(context.l10n),
                        style: AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.settingsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: Icon(Icons.settings_rounded, color: AppColors.textOnDark),
          ),
          IconButton(
            tooltip: context.l10n.navReminders,
            onPressed: onBellTap,
            icon: Icon(
              Icons.notifications_rounded,
              color: AppColors.textOnDark,
            ),
          ),
        ],
      ),
    );
  }
}
