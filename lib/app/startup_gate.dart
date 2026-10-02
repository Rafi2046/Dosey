import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import '../features/onboarding/presentation/permission_onboarding_screen.dart';
import '../features/onboarding/providers/permissions_provider.dart';
import 'home_shell.dart';

/// Shows permission onboarding on launch whenever an essential permission is
/// missing (first run, or the user revoked one later), otherwise home.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  /// Decided once from the first permission check, so granting permissions
  /// mid-onboarding doesn't yank the screen away.
  bool? _needsOnboarding;

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    final needs = _needsOnboarding ??= permissions.whenOrNull(
      data: (granted) => !granted.hasEssentials,
      error: (_, _) => false,
    );

    final Widget page = switch (needs) {
      null => const _Splash(),
      true => PermissionOnboardingScreen(
        onFinished: () => setState(() => _needsOnboarding = false),
      ),
      false => const HomeShell(),
    };
    return AnimatedSwitcher(duration: AppSpacing.animSlow, child: page);
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset(AppImages.logo, width: AppSpacing.logo)),
    );
  }
}
