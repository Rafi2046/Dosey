import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/permission_service.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../providers/permissions_provider.dart';
import '../widgets/ios_sound_card.dart';
import '../widgets/permission_tile.dart';

/// Page 3: every permission the alarms need, each with its own card, plus
/// "Allow all", which asks for the missing ones one after another.
///
/// Android grants most of these on a system Settings page, never in-app, so
/// "Allow all" opens each page in turn and continues when the user comes
/// back. Permission state is re-checked on every resume.
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  late final AppLifecycleListener _lifecycle;

  /// Permissions "Allow all" still has to ask for; null when not running.
  List<AppPermission>? _queue;

  /// A Settings page is open; continue the queue when the user returns.
  bool _awaitingReturn = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Set<AppPermission> get _granted =>
      ref.read(permissionsProvider).value ?? const {};

  Future<void> _onResume() async {
    await ref.read(permissionsProvider.notifier).refresh();
    if (_awaitingReturn && mounted) {
      _awaitingReturn = false;
      await _askNext();
    }
  }

  Future<void> _allowAll() async {
    setState(
      () => _queue = [
        for (final p in AppPermission.onThisPlatform)
          if (!_granted.contains(p)) p,
      ],
    );
    await _askNext();
  }

  Future<void> _askNext() async {
    final queue = _queue;
    if (queue == null) return;
    final notifier = ref.read(permissionsProvider.notifier);
    while (queue.isNotEmpty) {
      final permission = queue.removeAt(0);
      if (_granted.contains(permission)) continue;
      await notifier.request(permission);
      if (!mounted) return;
      // Not granted yet and not the in-app prompt: a Settings page is open.
      // Pick up again when the user comes back. (A declined notification
      // prompt just moves on.)
      if (!_granted.contains(permission) &&
          permission != AppPermission.notifications) {
        _awaitingReturn = true;
        return;
      }
    }
    setState(() => _queue = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final granted = ref.watch(permissionsProvider).value ?? const {};
    final permissions = AppPermission.onThisPlatform;
    final allGranted = permissions.every(granted.contains);

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.onboardingPermissionsTitle, style: AppTextStyles.display),
          AppSpacing.gapMd,
          Text(l10n.onboardingBody, style: AppTextStyles.bodyMuted),
          AppSpacing.gapXl,
          AnimatedSwitcher(
            duration: AppSpacing.animMedium,
            child: allGranted
                ? SurfaceCard(
                    key: const ValueKey('all-set'),
                    color: AppColors.mint,
                    padding: AppSpacing.cardPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.textOnDark,
                        ),
                        AppSpacing.gapSm,
                        Text(l10n.allSet, style: AppTextStyles.cardTitle),
                      ],
                    ),
                  )
                : Column(
                    key: const ValueKey('allow-all'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PillButton(
                        label: l10n.allowAll,
                        trailingIcon: Icons.done_all_rounded,
                        loading: _queue != null && !_awaitingReturn,
                        onPressed: _allowAll,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        l10n.allowAllHint,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
          AppSpacing.gapXl,
          for (final (i, permission) in permissions.indexed) ...[
            PermissionTile(
              permission: permission,
              granted: granted.contains(permission),
              color: AppColors.cardCycle[i % AppColors.cardCycle.length],
              onRequest: () =>
                  ref.read(permissionsProvider.notifier).request(permission),
            ),
            AppSpacing.gapMd,
          ],
          const IosSoundCard(),
        ],
      ),
    );
  }
}
