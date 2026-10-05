import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/cloud/cloud_initializer.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/alarm_runtime.dart';
import 'core/notifications/notification_service.dart';
import 'core/localization/l10n.dart';
import 'core/storage/storage_providers.dart';
import 'features/profiles/data/profiles_repository.dart';
import 'features/profiles/providers/profiles_providers.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CloudInitializer.initialize();
  // Portrait only (also set natively: AndroidManifest / Info.plist).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Hospital/clinic search data (assets/data) is OpenStreetMap's; credit it
  // in Settings › Open-source licences as the ODbL requires.
  LicenseRegistry.addLicense(
    () => Stream.value(
      const LicenseEntryWithLineBreaks(
        ['OpenStreetMap'],
        'Hospital and clinic data © OpenStreetMap contributors.\n'
        'Available under the Open Database License (ODbL) 1.0: '
        'https://opendatacommons.org/licenses/odbl/',
      ),
    ),
  );
  final documentsDirectory = await getApplicationDocumentsDirectory();

  // One DB connection shared by Riverpod and notification-action handlers.
  final db = AppDatabase();
  AlarmRuntime.adopt(db);
  // Language before the first frame (and before notification channels get
  // their names).
  await AppLocale.ensureInitialized();
  final settings = SettingsRepository(db);
  final language = await settings.get(AppLocale.settingKey);
  final theme = ThemeModeController.parse(await settings.get(themeKey));
  // The profile open last time, if it still exists.
  final savedProfile = int.tryParse(await settings.get(activeProfileKey) ?? '');
  final profile =
      savedProfile != null &&
          await (db.select(
                db.profiles,
              )..where((p) => p.id.equals(savedProfile))).getSingleOrNull() !=
              null
      ? savedProfile
      : ProfilesRepository.mainProfileId;
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
        themeModeProvider.overrideWith(() => ThemeModeController(theme)),
        activeProfileIdProvider.overrideWith(() => ActiveProfile(profile)),
      ],
      child: const DoseyApp(),
    ),
  );
}
