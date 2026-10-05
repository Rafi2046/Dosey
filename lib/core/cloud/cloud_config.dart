import 'package:flutter/foundation.dart';

/// Configuration constants for Cloud Services (Firebase & Supabase).
///
/// Values can be supplied at build/run time via `--dart-define`:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
abstract final class CloudConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://datkdpcomjgtuhodggml.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_6_tYTOVDvrmj6Z20XLsPfA_eXwczaFo',
  );

  /// Whether Supabase has been configured with real non-placeholder credentials.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseUrl != 'https://placeholder.supabase.co' &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'placeholder-anon-key';
}
