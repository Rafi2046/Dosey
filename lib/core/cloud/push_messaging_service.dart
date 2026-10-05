import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'cloud_initializer.dart';

/// FCM push for caregiver nudges, so they arrive while Dosey is in the
/// background or closed.
///
/// The device's FCM token is stored in Supabase (`register_push_token`); the
/// `send-nudge-push` edge function sends to it when a nudge is inserted. With
/// the app closed or in the background the OS shows the notification itself;
/// in the foreground [_showForeground] shows it.
abstract final class PushMessagingService {
  static StreamSubscription<String>? _tokenRefresh;
  static StreamSubscription<RemoteMessage>? _foreground;

  static bool get _available =>
      CloudInitializer.isFirebaseInitialized &&
      CloudInitializer.isSupabaseInitialized &&
      (Platform.isAndroid || Platform.isIOS);

  /// Registers this device to receive pushes for [uid]. Idempotent.
  static Future<void> register(String uid) async {
    if (!_available) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      // iOS: let the system show pushes that land while the app is open.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        sound: true,
        badge: true,
      );

      final token = await messaging.getToken();
      if (token != null) await _save(uid, token);

      await _tokenRefresh?.cancel();
      _tokenRefresh = messaging.onTokenRefresh.listen((t) => _save(uid, t));
      _foreground ??= FirebaseMessaging.onMessage.listen(_showForeground);
    } catch (e) {
      // e.g. iOS without an APNs key / Push capability yet: the in-app
      // realtime listener still delivers while Dosey is open.
      debugPrint('[PushMessagingService] Register failed: $e');
    }
  }

  /// Stops pushes for this device (on sign-out).
  static Future<void> unregister() async {
    if (!_available) return;
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client.rpc(
        'unregister_push_token',
        params: {'p_token': token},
      );
    } catch (e) {
      debugPrint('[PushMessagingService] Unregister failed: $e');
    }
  }

  static Future<void> _save(String uid, String token) async {
    try {
      await Supabase.instance.client.rpc(
        'register_push_token',
        params: {
          'p_uid': uid,
          'p_token': token,
          'p_platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
    } catch (e) {
      debugPrint('[PushMessagingService] Saving token failed: $e');
    }
  }

  /// Android doesn't display FCM notifications while the app is in the
  /// foreground, so show it locally. (iOS shows it via the presentation
  /// options set in [register].)
  static Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null || !Platform.isAndroid) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(1000000),
        channelKey: AppConstants.channelGentle,
        title: notification.title,
        body: notification.body,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        color: AppColors.accent,
      ),
    );
  }
}
