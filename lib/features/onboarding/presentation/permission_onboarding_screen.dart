import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/notifications/permission_service.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/permissions_provider.dart';
import 'widgets/onboarding_hero.dart';
import 'widgets/permission_tile.dart';

/// Walks the user through every permission the alarms depend on. Permission
/// state is re-checked whenever the app resumes (users grant most of these
/// on a system Settings page).
class PermissionOnboardingScreen extends ConsumerStatefulWidget {
  const PermissionOnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  ConsumerState<PermissionOnboardingScreen> createState() =>
      _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState
    extends ConsumerState<PermissionOnboardingScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(permissionsProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final granted = ref.watch(permissionsProvider).value ?? const {};
    final notifier = ref.read(permissionsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding.copyWith(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  const OnboardingHero(),
                  AppSpacing.gapXl,
                  for (final (i, permission)
                      in AppPermission.values.indexed) ...[
                    PermissionTile(
                      permission: permission,
                      granted: granted.contains(permission),
                      color:
                          AppColors.cardCycle[i % AppColors.cardCycle.length],
                      onRequest: () => notifier.request(permission),
                    ),
                    AppSpacing.gapMd,
                  ],
                ],
              ),
            ),
            _BottomBar(
              canContinue: granted.hasEssentials,
              onContinue: widget.onFinished,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.canContinue, required this.onContinue});

  final bool canContinue;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.bottomBarPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: AppSpacing.animMedium,
            child: canContinue
                ? const SizedBox.shrink()
                : const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      AppStrings.onboardingEssentialHint,
                      style: AppTextStyles.caption,
                    ),
                  ),
          ),
          PillButton(
            label: AppStrings.onboardingContinue,
            showRingChevron: true,
            onPressed: canContinue ? onContinue : null,
          ),
        ],
      ),
    );
  }
}
