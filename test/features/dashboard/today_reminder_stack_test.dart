import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosey/core/constants/constants.dart';
import 'package:dosey/core/database/enums.dart';
import 'package:dosey/core/localization/generated/app_localizations.dart';
import 'package:dosey/features/dashboard/presentation/widgets/reminder_stack_card.dart';
import 'package:dosey/features/reminders/domain/reminder_with_details.dart';
import 'package:dosey/features/reminders/domain/scheduled_occurrence.dart';
import 'package:dosey/core/database/app_database.dart';

void main() {
  testWidgets('All ReminderStackCards in stack have the exact same size', (
    tester,
  ) async {
    final now = DateTime(2026, 10, 3, 20, 0);

    ScheduledOccurrence makeOccurrence(int id, String title, DateTime at) {
      final reminder = Reminder(
        id: id,
        type: ReminderType.medicine,
        title: title,
        doseAmount: 2,
        startAt: at,
        repeatRule: RepeatRule.daily,
        isCritical: true,
        snoozeMinutes: 10,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      final medicine = Medicine(
        id: id,
        name: title,
        form: MedicineForm.tablet,
        strength: '500mg',
        doseUnit: 'tablet',
        mealRelation: MealRelation.afterMeal,
        unitPriceMinor: 100,
        startDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final details = ReminderWithDetails(
        reminder: reminder,
        medicine: medicine,
      );
      return ScheduledOccurrence(details: details, at: at);
    }

    final occurrences = [
      makeOccurrence(1, 'Zulfidin', now.subtract(const Duration(hours: 10))),
      makeOccurrence(2, 'Zulfidin', now.subtract(const Duration(hours: 6))),
      makeOccurrence(3, 'Zulfidin', now.add(const Duration(hours: 3))),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                for (final (i, o) in occurrences.indexed)
                  ReminderStackCard(
                    occurrence: o,
                    color: AppColors.cardCycle[i % AppColors.cardCycle.length],
                    isNext: i == 2,
                    now: now,
                    bottomInset: AppSpacing.stackOverlap,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final cardFinders = find.byType(ReminderStackCard);
    expect(cardFinders, findsNWidgets(3));

    final size0 = tester.getSize(cardFinders.at(0));
    final size1 = tester.getSize(cardFinders.at(1));
    final size2 = tester.getSize(cardFinders.at(2));

    // Verify all cards have the exact same height and width
    expect(size0.height, equals(size1.height));
    expect(size1.height, equals(size2.height));
    expect(size0.width, equals(size2.width));
  });
}
