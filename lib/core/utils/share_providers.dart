import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a file to the system share sheet (Drive, Files, WhatsApp, email…);
/// true if it went somewhere. Replaced in tests.
final fileSharerProvider = Provider<Future<bool> Function(File, String)>(
  (ref) => (file, subject) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
    return result.status != ShareResultStatus.dismissed;
  },
);
