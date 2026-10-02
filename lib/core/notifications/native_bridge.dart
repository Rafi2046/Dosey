import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// Thin wrapper over the Android channel in MainActivity.kt. On platforms
/// without it (iOS, tests) every call is a harmless no-op.
abstract final class NativeBridge {
  static const MethodChannel _channel = MethodChannel(
    AppConstants.nativeChannel,
  );

  /// Lets the activity appear over the keyguard (only while an alarm rings).
  static Future<void> setShowOverLockScreen(bool show) =>
      _invoke<void>(AppConstants.nativeSetShowOverLock, show);

  /// True when the activity was launched by a notification while locked.
  static Future<bool> wasLaunchedOverLockScreen() async =>
      await _invoke<bool>(AppConstants.nativeWasLaunchedOverLock) ?? false;

  /// Pre-creates alarm channels with alarm-stream audio (rings on silent).
  static Future<void> ensureAlarmChannels(Map<String, Object> args) =>
      _invoke<void>(AppConstants.nativeEnsureAlarmChannels, args);

  /// Grant state of settings-page permissions, keyed by AppPermission name
  /// (exactAlarms, fullScreen, dnd). Null where not applicable (iOS/tests).
  static Future<Map<String, bool>?> specialPermissionStatus() async {
    final raw = await _invoke<Map<Object?, Object?>>(
      AppConstants.nativeSpecialPermissionStatus,
    );
    return raw?.map((k, v) => MapEntry(k! as String, v! as bool));
  }

  /// Opens the Settings page where the user grants [permissionName].
  static Future<void> openPermissionSettings(String permissionName) =>
      _invoke<void>(AppConstants.nativeOpenPermissionSettings, permissionName);

  /// Stores the Dart callback handle the boot receiver uses to resync alarms.
  static Future<void> registerResyncHandle(int rawHandle) =>
      _invoke<void>(AppConstants.nativeRegisterResync, rawHandle);

  static Future<T?> _invoke<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    }
  }
}
