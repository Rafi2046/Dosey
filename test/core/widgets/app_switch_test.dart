import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/widgets/app_switch.dart';
import 'package:dosey/core/widgets/switch_row.dart';

void main() {
  testWidgets('AppSwitch scales to 68% and toggles correctly', (tester) async {
    bool value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return AppSwitch(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      ),
    );

    // Verify scale constant is 0.68
    expect(AppSpacing.switchScale, 0.68);
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(AppSwitch),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.entry(0, 0), closeTo(0.68, 0.001));
    expect(transform.transform.entry(1, 1), closeTo(0.68, 0.001));

    // Verify toggling works
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(value, true);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(value, false);
  });

  testWidgets('SwitchRow contains AppSwitch and row tap toggles value', (
    tester,
  ) async {
    bool value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SwitchRow(
                title: 'Ring as an alarm',
                subtitle: 'Full-screen alarm that rings even on silent.',
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(AppSwitch), findsOneWidget);
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(AppSwitch),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.entry(0, 0), closeTo(0.68, 0.001));
    expect(transform.transform.entry(1, 1), closeTo(0.68, 0.001));

    // Tapping on the row toggles the switch
    await tester.tap(find.text('Ring as an alarm'));
    await tester.pumpAndSettle();
    expect(value, true);
  });
}
