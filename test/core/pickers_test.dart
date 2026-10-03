import 'package:dosey/core/theme/app_theme.dart';
import 'package:dosey/core/utils/pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: switching the time picker to keyboard entry crashed with
/// "BoxConstraints has non-normalized height constraints" on phones with a
/// small system font (0.8 on a Galaxy S21) or a tall on-screen keyboard.
void main() {
  for (final (keyboard, fontScale) in [
    (0.0, 1.0),
    (0.0, 0.8), // the Galaxy S21 crash
    (0.0, 0.7),
    (300.0, 0.8),
    (450.0, 1.0),
    (620.0, 1.0),
    (650.0, 1.0),
    (700.0, 1.3),
  ]) {
    testWidgets(
      'time picker: ${keyboard.toInt()}px keyboard, font $fontScale',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard * 2.75);
        tester.platformDispatcher.textScaleFactorTestValue = fontScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.current,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => AppPickers.time(context),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        // Switch to keyboard entry, the mode that used to throw.
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
