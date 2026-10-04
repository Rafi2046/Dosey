import 'package:dosey/app/home_tab.dart';
import 'package:dosey/app/widgets/more_sheet.dart';
import 'package:dosey/core/constants/app_spacing.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('showMoreSheet has 65% height factor and renders correctly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.current,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showMoreSheet(
                context,
                current: HomeTab.dashboard,
                onSelected: (_) {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final fractionallySizedBoxFinder = find.byType(FractionallySizedBox);
    expect(fractionallySizedBoxFinder, findsOneWidget);

    final fractionallySizedBox =
        tester.widget<FractionallySizedBox>(fractionallySizedBoxFinder);
    expect(
      fractionallySizedBox.heightFactor,
      equals(AppSpacing.moreSheetHeightFactor),
    );
    expect(AppSpacing.moreSheetHeightFactor, equals(0.65));

    final bottomSheetFinder = find.byType(BottomSheet);
    expect(bottomSheetFinder, findsOneWidget);
    final sheetSize = tester.getSize(bottomSheetFinder);
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;

    // Total bottom sheet height should be around 65% of the screen height.
    expect(sheetSize.height / screenHeight, closeTo(0.65, 0.05));
  });
}
