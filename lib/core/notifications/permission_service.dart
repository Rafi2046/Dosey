import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';

import 'native_bridge.dart';

/// Permissions the alarm experience depends on.
enum AppPermission {
  /// POST_NOTIFICATIONS (runtime dialog on Android 13+).
  notifications(isRequired: true),

  /// SCHEDULE_EXACT_ALARM (Settings › Alarms & reminders; off by default on
  /// Android 14+).
  exactAlarms(isRequired: true),

  /// USE_FULL_SCREEN_INTENT (Settings page on Android 14+).
  fullScreen(isRequired: false),

  /// Do Not Disturb access, so alarm channels can bypass DND.
  dnd(isRequired: false);

  const AppPermission({required this.isRequired});

  final bool isRequired;
}

/// Notifications go through awesome_notifications' runtime prompt. The rest
/// are special-access permissions granted on Settings pages, handled natively
/// (see SpecialPermissions.kt): awesome tries to request them as runtime
/// permissions, which never completes.
class PermissionService {
  final AwesomeNotifications _awn = AwesomeNotifications();

  static const _defaultPermissions = [
    NotificationPermission.Alert,
    NotificationPermission.Sound,
    NotificationPermission.Badge,
    NotificationPermission.Vibration,
    NotificationPermission.Light,
  ];

  /// Critical Alerts ring through silent/DND, but iOS only grants them once
  /// Apple approves the entitlement (see ios/Runner/CriticalAlerts.entitlements).
  /// Until then iOS silently ignores the request; the rest still applies.
  static const _iosPermissions = [
    ..._defaultPermissions,
    NotificationPermission.CriticalAlert,
  ];

  Future<Set<AppPermission>> granted() async {
    final special = await NativeBridge.specialPermissionStatus();
    return {
      if (await _awn.isNotificationAllowed()) AppPermission.notifications,
      for (final p in AppPermission.values)
        // Null map = platform without these concepts: treat as satisfied.
        if (p != AppPermission.notifications && (special?[p.name] ?? true)) p,
    };
  }

  Future<void> request(AppPermission permission) async {
    if (permission == AppPermission.notifications) {
      await _awn.requestPermissionToSendNotifications(
        permissions: Platform.isIOS ? _iosPermissions : _defaultPermissions,
      );
    } else {
      await NativeBridge.openPermissionSettings(permission.name);
    }
  }
}
