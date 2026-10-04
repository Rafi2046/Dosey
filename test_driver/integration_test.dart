import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` entry point: saves each `takeScreenshot` to
/// `build/screens/<name>.png`.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/screens/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
