import 'dart:ui' show PlatformDispatcher;

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../profiles/data/profiles_repository.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/backup_service.dart';
import '../data/data_reset_service.dart';
import '../../../core/localization/l10n.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// The chosen language code ("en" / "bn"), or null to follow the phone.
/// main() overrides the initial value with the saved one so the first frame
/// is already in the right language.
final languageProvider = NotifierProvider<LanguageController, String?>(
  LanguageController.new,
);

class LanguageController extends Notifier<String?> {
  LanguageController([this._initial]);

  final String? _initial;

  @override
  String? build() => _initial;

  Future<void> choose(String? code) async {
    state = code;
    await ref.read(settingsRepositoryProvider).set(AppLocale.settingKey, code);
    // The widget's text is written in the app language: rewrite it (the
    // UI applies the new locale on its next build, which is too late here).
    AppLocale.apply(
      AppLocale.resolve(code, PlatformDispatcher.instance.locale),
    );
    await ref.read(homeWidgetSyncProvider).refresh();
  }
}

/// Whether the user has been through onboarding once. Decides where it
/// starts if a permission is later revoked (straight at permissions).
final onboardingDoneProvider = FutureProvider<bool>(
  (ref) async =>
      await ref.watch(settingsRepositoryProvider).get(onboardingDoneKey) !=
      null,
);

const String onboardingDoneKey = 'onboarding_done';

/// AppSettings key for the theme: "light" / "dark"; absent = follow phone.
const String themeKey = 'theme';

/// Chosen appearance. main() overrides the initial value with the saved one
/// so the first frame is already in the right theme.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  ThemeModeController([this._initial = ThemeMode.system]);

  final ThemeMode _initial;

  @override
  ThemeMode build() => _initial;

  static ThemeMode parse(String? saved) => switch (saved) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> choose(ThemeMode mode) async {
    state = mode;
    await ref
        .read(settingsRepositoryProvider)
        .set(themeKey, mode == ThemeMode.system ? null : mode.name);
  }
}

/// AppSettings key for the user's name (optional, from onboarding or
/// Settings).
const String userNameKey = 'user_name';

/// The user's name, or null if they skipped it.
final userNameProvider = AsyncNotifierProvider<UserNameController, String?>(
  UserNameController.new,
);

class UserNameController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() =>
      ref.read(settingsRepositoryProvider).get(userNameKey);

  /// Saves [name]; blank removes it. The user's own profile carries the
  /// same name (blank shows as "Me").
  Future<void> set(String? name) async {
    final trimmed = name?.trim() ?? '';
    final value = trimmed.isEmpty ? null : trimmed;
    state = AsyncData(value);
    await ref.read(settingsRepositoryProvider).set(userNameKey, value);
    await ref
        .read(profilesRepositoryProvider)
        .rename(ProfilesRepository.mainProfileId, trimmed);
  }
}

/// App name/version for Settings (null in tests, where there's no platform).
final packageInfoProvider = FutureProvider<PackageInfo?>((ref) async {
  try {
    return await PackageInfo.fromPlatform();
  } on Exception {
    return null;
  }
});

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    ref.watch(appDatabaseProvider),
    ref.watch(documentsDirectoryProvider),
  ),
);

/// Settings key of the last backup's time (ISO 8601).
const lastBackupKey = 'last_backup_at';

final lastBackupProvider = FutureProvider<DateTime?>((ref) async {
  final raw = await ref.watch(settingsRepositoryProvider).get(lastBackupKey);
  return raw == null ? null : DateTime.tryParse(raw);
});

/// Lets the user pick a backup file; its bytes, or null if cancelled.
/// Replaced in tests.
final backupPickerProvider = Provider<Future<List<int>?> Function()>(
  (ref) => () async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return null;
    return picked.single.xFile.readAsBytes();
  },
);

final dataResetServiceProvider = Provider<DataResetService>(
  (ref) => DataResetService(
    ref.watch(appDatabaseProvider),
    ref.watch(allRemindersRepositoryProvider),
    ref.watch(alarmEngineProvider),
    ref.watch(fileStorageProvider),
  ),
);
