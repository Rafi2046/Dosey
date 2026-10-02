import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'background_entrypoints.dart';
import 'native_bridge.dart';
import 'notification_channels.dart';

/// One-time bootstrap of the notification + alarm stack.
abstract final class NotificationService {
  static bool _initialized = false;

  /// Registers channels. Safe to call from any isolate (idempotent).
  static Future<void> initialize() async {
    if (_initialized) return;
    await AwesomeNotifications().initialize(
      AppConstants.notificationIcon,
      NotificationChannels.all,
      channelGroups: NotificationChannels.groups,
      debug: kDebugMode,
    );
    _initialized = true;
  }

  /// UI-isolate only: action listeners, alarm plugin and boot hook.
  static Future<void> startForeground() async {
    await initialize();
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onNotificationAction,
    );
    await AndroidAlarmManager.initialize();

    final handle = PluginUtilities.getCallbackHandle(onAlarmCallback);
    if (handle != null) {
      await NativeBridge.registerResyncHandle(handle.toRawHandle());
    }
  }
}
