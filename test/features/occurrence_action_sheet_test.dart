import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/localization/generated/app_localizations.dart';
import 'package:dosey/features/dashboard/presentation/widgets/occurrence_action_sheet.dart';
import 'package:dosey/features/reminders/domain/reminder_with_details.dart';
import 'package:dosey/features/reminders/domain/scheduled_occurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 9, 8, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('occurrence action sheet reflects dynamic card color', (tester) async {
    usePhoneSize(tester);

    final reminder = Reminder(
      profileId: 1,
      id: 1,
      type: ReminderType.medicine,
      title: 'Insulin Glargine',
      doseAmount: 10,
      startAt: now,
      repeatRule: RepeatRule.daily,
      isCritical: true,
      snoozeMinutes: 10,
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
    final medicine = Medicine(
      profileId: 1,
      id: 1,
      name: 'Insulin Glargine',
      form: MedicineForm.injection,
      strength: '100 units/ml',
      doseUnit: 'unit',
      mealRelation: MealRelation.beforeMeal,
      unitPriceMinor: 1200,
      startDate: now,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final occurrence = ScheduledOccurrence(
      details: ReminderWithDetails(reminder: reminder, medicine: medicine),
      at: now,
    );

    for (final testColor in AppColors.cardCycle) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(db: db, now: now),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showOccurrenceActions(
                    context,
                    occurrence,
                    color: testColor,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the dialog container with the given color
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == testColor,
      );

      expect(
        containerFinder,
        findsOneWidget,
        reason: 'Popup container should have color $testColor',
      );

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
    }
  });
}
