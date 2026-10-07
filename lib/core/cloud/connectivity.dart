import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'cloud_config.dart';

/// Whether the cloud backend can be reached right now. Resolves the
/// Supabase host rather than asking the OS for a network type, so a Wi-Fi
/// with no internet behind it counts as offline.
Future<bool> hasInternet() async {
  // dart:io lookups don't exist on web; the browser reports its own errors.
  if (kIsWeb) return true;
  try {
    final host = Uri.parse(CloudConfig.supabaseUrl).host;
    final result = await InternetAddress.lookup(
      host,
    ).timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  }
}
