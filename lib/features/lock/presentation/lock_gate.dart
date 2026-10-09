import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/app_lock_providers.dart';

/// With App lock on, covers the app until the phone confirms its owner: on
/// a cold start and after [AppConstants.lockAfter] in the background.
///
/// A ringing alarm is never hidden behind it: taking a medicine on time
/// matters more than the lock (the alarm screen shows only that dose).
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  DateTime? _leftAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        _leftAt ??= ref.read(appLockClockProvider)();
      case AppLifecycleState.resumed:
        final left = _leftAt;
        _leftAt = null;
        if (left != null &&
            ref.read(appLockClockProvider)().difference(left) >=
                AppConstants.lockAfter) {
          ref.read(appLockedProvider.notifier).lock();
        }
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(appLockEnabledProvider).value ?? false;
    final locked = ref.watch(appLockedProvider);
    final show = enabled && locked;
    return Stack(
      children: [
        // Kept underneath (and its state with it), but out of reach.
        ExcludeSemantics(
          excluding: show,
          child: IgnorePointer(ignoring: show, child: widget.child),
        ),
        if (show) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}

/// "Dosey is locked" with an Unlock button; asks once by itself.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_asking || !mounted) return;
    setState(() => _asking = true);
    final ok = await ref.read(appLockAuthProvider)(context.l10n.appLockReason);
    if (!mounted) return;
    setState(() => _asking = false);
    if (ok) ref.read(appLockedProvider.notifier).unlock();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.sage,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.asset(AppImages.logo, width: AppSpacing.logo),
              ),
              AppSpacing.gapXl,
              Icon(
                Icons.lock_rounded,
                color: AppColors.textOnDark,
                size: AppSpacing.iconLg,
              ),
              AppSpacing.gapMd,
              Text(
                l10n.appLockLocked,
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSm,
              Text(
                l10n.appLockLockedHint,
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PillButton(
                label: l10n.appLockUnlock,
                trailingIcon: Icons.fingerprint_rounded,
                loading: _asking,
                onPressed: _unlock,
              ),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}
