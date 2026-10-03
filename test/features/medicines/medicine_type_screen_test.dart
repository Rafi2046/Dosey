import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/localization/generated/app_localizations.dart';
import 'package:dosey/features/medicines/presentation/medicine_type_screen.dart';
import 'package:dosey/features/medicines/presentation/widgets/medicine_type_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  Widget testable(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: textScaler ?? TextScaler.noScaling,
        ),
        child: child,
      ),
    );
  }

  testWidgets('MedicineTypeScreen renders without overflow on phone viewport', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(testable(const MedicineTypeScreen()));
    await settle(tester);

    // Initial load: Tablet is selected by default.
    expect(tester.takeException(), isNull);
    expect(find.byType(MedicineTypeTile), findsNWidgets(4));

    final en = await AppLocalizations.delegate.load(const Locale('en'));

    // Tap each medicine type and verify no RenderFlex overflow occurs.
    for (final label in [en.formCapsule, en.formInjection, en.formOther, en.formTablet]) {
      await tester.tap(find.text(label).first);
      await settle(tester);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('MedicineTypeScreen renders without overflow on small device with text scaling', (
    tester,
  ) async {
    // 360 logical width (common compact Android phone)
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3.0; // 360x720
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      testable(
        const MedicineTypeScreen(),
        textScaler: const TextScaler.linear(1.15),
      ),
    );
    await settle(tester);

    expect(tester.takeException(), isNull);

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    for (final label in [en.formCapsule, en.formInjection, en.formOther, en.formTablet]) {
      await tester.tap(find.text(label).first);
      await settle(tester);
      expect(tester.takeException(), isNull);
    }
  });
}
