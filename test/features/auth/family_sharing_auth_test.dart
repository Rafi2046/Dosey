import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/auth/presentation/family_sharing_auth_sheet.dart';
import 'package:dosey/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: FamilySharingAuthSheet(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders guest auth options when not signed in', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('FAMILY SHARING'), findsOneWidget);
    expect(find.text('Caregiver & Family Mode'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(
      find.textContaining('Dosey remains 100% offline-first'),
      findsOneWidget,
    );
  });

  testWidgets('toggles between Sign In and Create Account tabs', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsWidgets);

    // Switch to Create Account
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('At least 6 characters'), findsOneWidget);
  });
}
