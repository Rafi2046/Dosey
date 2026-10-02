import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/permission_service.dart';

/// Re-creates alarm channels so they gain `bypassDnd` (overridable in tests).
final alarmChannelRefresherProvider = Provider<Future<void> Function()>(
  (ref) => NotificationService.refreshAlarmChannels,
);

final permissionsProvider =
    AsyncNotifierProvider<PermissionsNotifier, Set<AppPermission>>(
      PermissionsNotifier.new,
    );

class PermissionsNotifier extends AsyncNotifier<Set<AppPermission>> {
  PermissionService get _service => ref.read(permissionServiceProvider);

  @override
  Future<Set<AppPermission>> build() => _service.granted();

  /// Re-checks without flashing a loading state (e.g. back from Settings).
  Future<void> refresh() async {
    final before = state.value;
    state = await AsyncValue.guard(_service.granted);
    final dndNewlyGranted =
        state.value?.contains(AppPermission.dnd) == true &&
        before?.contains(AppPermission.dnd) != true;
    if (dndNewlyGranted) await ref.read(alarmChannelRefresherProvider)();
  }

  Future<void> request(AppPermission permission) async {
    await _service.request(permission);
    await refresh();
  }
}

extension GrantedPermissions on Set<AppPermission> {
  bool get hasEssentials =>
      AppPermission.values.where((p) => p.isRequired).every(contains);
}
