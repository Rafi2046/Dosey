import 'package:dosey/core/database/enums.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/alarm/presentation/widgets/alarm_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppLocale.apply(AppLocale.english));

  Future<void> pump(WidgetTester tester, Locale locale) async {
    AppLocale.apply(locale);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: AlarmActions(
            type: ReminderType.medicine,
            snoozeMinutes: 10,
            busy: false,
            onAction: (_, {snoozeFor}) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('snooze minutes use Bengali digits in Bengali', (tester) async {
    await pump(tester, AppLocale.bangla);
    expect(find.text('স্নুজ ১০ মিনিট'), findsOneWidget);
  });

  testWidgets('and Latin digits in English', (tester) async {
    await pump(tester, AppLocale.english);
    expect(find.text('Snooze 10 min'), findsOneWidget);
  });
}
