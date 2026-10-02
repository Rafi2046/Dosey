import 'dart:io';

import 'package:dosey/app/app.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots with the dark theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
        ],
        child: const DoseyApp(),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });
}
