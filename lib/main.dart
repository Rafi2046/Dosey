import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/alarm_runtime.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentsDirectory = await getApplicationDocumentsDirectory();

  // One DB connection shared by Riverpod and notification-action handlers.
  final db = AppDatabase();
  AlarmRuntime.adopt(db);
  await NotificationService.startForeground();

  // Alarms may have been lost (force-stop, missed boot broadcast): re-arm all.
  unawaited(AlarmRuntime.engine().then((engine) => engine.resyncAll()));

  runApp(
    ProviderScope(
      overrides: [
        documentsDirectoryProvider.overrideWithValue(documentsDirectory),
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const DoseyApp(),
    ),
  );
}
