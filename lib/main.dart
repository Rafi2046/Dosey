import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/alarm_runtime.dart';
import 'core/notifications/notification_service.dart';
import 'core/localization/l10n.dart';
import 'core/storage/storage_providers.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentsDirectory = await getApplicationDocumentsDirectory();

  // One DB connection shared by Riverpod and notification-action handlers.
  final db = AppDatabase();
  AlarmRuntime.adopt(db);
  // Language before the first frame (and before notification channels get
  // their names).
  await AppLocale.ensureInitialized();
  final language = await SettingsRepository(db).get(AppLocale.settingKey);
  AppLocale.apply(
    AppLocale.resolve(language, PlatformDispatcher.instance.locale),
  );
  await NotificationService.startForeground();

  // Alarms may have been lost (force-stop, missed boot broadcast): re-arm all.
  unawaited(AlarmRuntime.engine().then((engine) => engine.resyncAll()));

  runApp(
    ProviderScope(
      overrides: [
        documentsDirectoryProvider.overrideWithValue(documentsDirectory),
        appDatabaseProvider.overrideWithValue(db),
        languageProvider.overrideWith(() => LanguageController(language)),
      ],
      child: const DoseyApp(),
    ),
  );
}
