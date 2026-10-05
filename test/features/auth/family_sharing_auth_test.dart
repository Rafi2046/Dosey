import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/auth/data/auth_repository.dart';
import 'package:dosey/features/auth/presentation/family_sharing_auth_sheet.dart';
import 'package:dosey/features/auth/providers/auth_providers.dart';
import 'package:dosey/features/family_sharing/data/family_share_repository.dart';
import 'package:dosey/features/family_sharing/domain/family_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  group('FamilySharingAuthSheet UI Tests', () {
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
      expect(find.text('Forgot Password?'), findsOneWidget);
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

      expect(find.text('Your Name (Optional)'), findsOneWidget);
      expect(find.text('At least 6 characters'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsNothing);
    });

    testWidgets('toggles to Reset Password and back', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Tap Forgot Password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);

      // Tap Back to Sign In
      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsNothing);
      expect(find.text('Sign In'), findsWidgets);
    });
  });

  group('AuthRepository Error Formatting Tests', () {
    test('formats FirebaseAuthException codes into user-friendly messages', () {
      final notFound = FirebaseAuthException(
        code: 'user-not-found',
        message: 'Raw error',
      );
      expect(
        AuthRepository.formatAuthError(notFound),
        'No account found with this email address.',
      );

      final wrongPass = FirebaseAuthException(
        code: 'wrong-password',
        message: 'Raw error',
      );
      expect(
        AuthRepository.formatAuthError(wrongPass),
        'Incorrect password. Please try again.',
      );

      final inUse = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Raw error',
      );
      expect(
        AuthRepository.formatAuthError(inUse),
        'An account with this email already exists.',
      );

      final invalidEmail = FirebaseAuthException(
        code: 'invalid-email',
        message: 'Raw error',
      );
      expect(
        AuthRepository.formatAuthError(invalidEmail),
        'Please enter a valid email address.',
      );

      final weakPass = FirebaseAuthException(
        code: 'weak-password',
        message: 'Raw error',
      );
      expect(
        AuthRepository.formatAuthError(weakPass),
        'Password must be at least 6 characters.',
      );

      final fallback = FirebaseAuthException(
        code: 'custom-error',
        message: 'Something specific',
      );
      expect(AuthRepository.formatAuthError(fallback), 'Something specific');

      expect(
        AuthRepository.formatAuthError('Generic error string'),
        'Generic error string',
      );
    });
  });

  group('FamilyShare Model & Repository Code Generator Tests', () {
    test('generateCode produces 6-character uppercase alphanumeric code', () {
      for (var i = 0; i < 20; i++) {
        final code = FamilyShareRepository.generateCode();
        expect(code.length, 6);
        expect(code, matches(RegExp(r'^[A-Z0-9]{6}$')));
      }
    });

    test('FamilyShare json serialization and copyWith', () {
      final now = DateTime.utc(2026, 10, 5, 12, 0, 0);
      final share = FamilyShare(
        id: 'test-uuid-1',
        patientUid: 'patient-123',
        patientName: 'Jane Doe',
        shareCode: '8K2P9A',
        createdAt: now,
      );

      expect(share.isClaimed, isFalse);

      final json = share.toJson();
      expect(json['id'], 'test-uuid-1');
      expect(json['patient_uid'], 'patient-123');
      expect(json['share_code'], '8K2P9A');
      expect(json['is_active'], isTrue);

      final deserialized = FamilyShare.fromJson(json);
      expect(deserialized.id, share.id);
      expect(deserialized.patientUid, share.patientUid);
      expect(deserialized.shareCode, share.shareCode);
      expect(deserialized.patientName, share.patientName);

      final claimed = share.copyWith(
        caregiverUid: 'caregiver-456',
        caregiverName: 'Dr. John',
      );
      expect(claimed.isClaimed, isTrue);
      expect(claimed.caregiverUid, 'caregiver-456');
      expect(claimed.caregiverName, 'Dr. John');
    });
  });
}
