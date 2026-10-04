// Screenshots the onboarding "features" page in Bengali and English on a
// real device (build/screens/*.png via test_driver/integration_test.dart).
//
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/onboarding_features_test.dart -d <device>

import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/settings/providers/settings_providers.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fakes.dart';
import '../test/support/harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final locale in [AppLocale.bangla, AppLocale.english]) {
    testWidgets('features page (${locale.languageCode})', (tester) async {
      final l = lookupAppLocalizations(locale);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testOverrides(
              db: db,
              now: DateTime.now(),
              permissions: FakePermissionService(),
            ),
            languageProvider.overrideWith(
              () => LanguageController(locale.languageCode),
            ),
          ],
          child: const DoseyApp(),
        ),
      );
      if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
      await settle(tester);
      await tester.tap(find.text(l.onboardingContinue));
      await settle(tester);
      await tester.tap(find.text(l.skip));
      await settle(tester);
      await binding.takeScreenshot(
        'onboarding_features_${locale.languageCode}',
      );
    });
  }
}
