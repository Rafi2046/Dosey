import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/widgets/guarded_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final en = lookupAppLocalizations(AppLocale.english);

void main() {
  final formKey = GlobalKey<FormState>();

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: GuardedForm(
                    formKey: formKey,
                    child: Column(
                      children: [
                        TextFormField(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('back on an untouched form just closes it', (tester) async {
    await openForm(tester);
    await tester.binding.handlePopRoute(); // System back.
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('back after typing asks; Keep editing stays, Discard leaves', (
    tester,
  ) async {
    await openForm(tester);
    await tester.enterText(find.byType(TextFormField), 'Napa');
    await tester.pump();

    await tester.binding.handlePopRoute(); // System back.
    await tester.pumpAndSettle();
    expect(find.text(en.discardTitle), findsOneWidget);
    await tester.tap(find.text(en.discardKeep));
    await tester.pumpAndSettle();
    expect(find.text('Napa'), findsOneWidget);

    await tester.binding.handlePopRoute(); // System back.
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.discardConfirm));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('saving closes the page without asking', (tester) async {
    await openForm(tester);
    await tester.enterText(find.byType(TextFormField), 'Napa');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text(en.discardTitle), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
