import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import '../core/constants/constants.dart';
import '../core/storage/storage_providers.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/providers/permissions_provider.dart';
import '../features/settings/providers/settings_providers.dart';
import 'home_shell.dart';

/// Shows onboarding on launch whenever an essential permission is missing:
/// the full flow on first run, or straight to the permissions page if the
/// user has onboarded before and later revoked one. Otherwise home.
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
  void initState() {
    super.initState();
    _checkLegacyDemoImages();
  }

  Future<void> _checkLegacyDemoImages() async {
    try {
      final bytes = await rootBundle.load(AppImages.samplePrescription);
      await ref
          .read(fileStorageProvider)
          .upgradeLegacyDemoImages(bytes.buffer.asUint8List());
    } catch (_) {}
  }

  Future<void> _finish() async {
    setState(() => _needsOnboarding = false);
    await ref.read(settingsRepositoryProvider).set(onboardingDoneKey, '1');
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    final onboarded = ref.watch(onboardingDoneProvider).value;
    final needs = _needsOnboarding ??= permissions.whenOrNull(
      data: (granted) => !granted.hasEssentials,
      error: (_, _) => false,
    );

    final Widget page = switch (needs) {
      null => const _Splash(),
      true when onboarded == null => const _Splash(),
      true => OnboardingScreen(
        initialPage: onboarded! ? OnboardingScreen.permissionsPage : 0,
        onFinished: _finish,
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
