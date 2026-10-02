import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentsDirectory = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      overrides: [
        documentsDirectoryProvider.overrideWithValue(documentsDirectory),
      ],
      child: const DoseyApp(),
    ),
  );
}
