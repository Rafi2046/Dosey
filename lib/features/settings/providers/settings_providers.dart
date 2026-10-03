import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
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
