import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloud_config.dart';

/// Initializes Firebase and Supabase gracefully without crashing
/// the app if cloud services are unconfigured, keeping the app strictly offline-first.
abstract final class CloudInitializer {
  static bool _firebaseInitialized = false;
  static bool _supabaseInitialized = false;

  static bool get isFirebaseInitialized => _firebaseInitialized;
  static bool get isSupabaseInitialized => _supabaseInitialized;

  /// Initializes cloud services. Fails gracefully so offline features remain 100% operational.
  static Future<void> initialize() async {
    await _initFirebase();
    await _initSupabase();
  }

  static Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseInitialized = true;
      debugPrint('[CloudInitializer] Firebase initialized successfully.');
    } catch (e, st) {
      // Expected in dev/test when google-services.json / GoogleService-Info.plist
      // is not yet added to native directories.
      debugPrint('[CloudInitializer] Firebase initialization skipped/failed: $e');
      if (kDebugMode) {
        debugPrint(st.toString());
      }
    }
  }

  static Future<void> _initSupabase() async {
    try {
      if (CloudConfig.isSupabaseConfigured) {
        await Supabase.initialize(
          url: CloudConfig.supabaseUrl,
          anonKey: CloudConfig.supabaseAnonKey,
        );
        _supabaseInitialized = true;
        debugPrint('[CloudInitializer] Supabase initialized successfully.');
      } else {
        debugPrint(
          '[CloudInitializer] Supabase credentials not set via --dart-define. Offline mode active.',
        );
      }
    } catch (e) {
      debugPrint('[CloudInitializer] Supabase initialization failed: $e');
    }
  }
}
