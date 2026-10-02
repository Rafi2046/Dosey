import 'package:awesome_notifications/awesome_notifications.dart';

import '../constants/app_constants.dart';

/// Permissions the alarm experience depends on.
enum AppPermission {
  /// POST_NOTIFICATIONS (Android 13+).
  notifications(
    isRequired: true,
    native: [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Vibration,
    ],
  ),

  /// SCHEDULE_EXACT_ALARM (denied by default on Android 14+).
  exactAlarms(isRequired: true, native: [NotificationPermission.PreciseAlarms]),

  /// USE_FULL_SCREEN_INTENT (user-granted on Android 14+).
  fullScreen(
    isRequired: false,
    native: [NotificationPermission.FullScreenIntent],
  ),

  /// Do Not Disturb access, so alarm channels can bypass DND.
  dnd(isRequired: false, native: [NotificationPermission.CriticalAlert]);

  const AppPermission({required this.isRequired, required this.native});

  final bool isRequired;
  final List<NotificationPermission> native;
}

class PermissionService {
  /// Checked against the medicine alarm channel, whose DND bypass matters.
  static const String _channel = AppConstants.channelMedicine;

  final AwesomeNotifications _awn = AwesomeNotifications();

  Future<Set<AppPermission>> granted() async {
    final allNative = [for (final p in AppPermission.values) ...p.native];
    final allowed = (await _awn.checkPermissionList(
      channelKey: _channel,
      permissions: allNative,
    )).toSet();
    return {
      for (final p in AppPermission.values)
        if (p.native.every(allowed.contains)) p,
    };
  }

  /// Shows the system dialog or opens the relevant settings page.
  Future<void> request(AppPermission permission) =>
      _awn.requestPermissionToSendNotifications(
        channelKey: _channel,
        permissions: permission.native,
      );
}
