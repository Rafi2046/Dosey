// Writes real home screen widget data on a device/simulator through the
// production path (HomeWidgetSync → home_widget → App Group / prefs), with
// two medicines due together soon and one later. Run with
// --keep-app-running so the data (and the app) stay for the widget.
//
//   flutter drive --keep-app-running --driver test_driver/integration_test.dart \
//     --target integration_test/widget_data_test.dart -d <device>

import 'dart:convert';

import 'package:dosey/core/constants/app_constants.dart';
import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/core/home_widget/home_widget_sync.dart';
import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/features/reminders/data/reminders_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('writes the next doses for the widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('Widget data')));
    await AppLocale.ensureInitialized();
    AppLocale.apply(AppLocale.bangla);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = RemindersRepository(db);
    final now = DateTime.now();
    final soon = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 1));
    for (final (name, at, amount) in [
      ('Metformin', soon, 2.0),
      ('Calbo D', soon, 1.0),
      ('Zulfidin', soon.add(const Duration(hours: 3)), 1.0),
    ]) {
      final med = await db
          .into(db.medicines)
          .insert(
            MedicinesCompanion.insert(
              name: name,
              startDate: now,
              mealRelation: const Value(MealRelation.afterMeal),
            ),
          );
      await repo.create(
        RemindersCompanion.insert(
          type: ReminderType.medicine,
          title: name,
          startAt: at,
          medicineId: Value(med),
          repeatRule: const Value(RepeatRule.daily),
          doseAmount: Value(amount),
        ),
        now: now,
      );
    }

    await HomeWidgetSync(repo).refresh();

    final saved = await HomeWidget.getWidgetData<String>(
      AppConstants.widgetDataKey,
    );
    // ignore: avoid_print
    print('WIDGETDATA $saved');
    final json = jsonDecode(saved!) as Map<String, dynamic>;
    final slots = json['slots'] as List;
    expect(
      (slots.first as Map)['title'],
      lookupAppLocalizations(AppLocale.bangla).alarmGroupCount(2),
    );
    expect(((slots.first as Map)['lines'] as List), hasLength(2));
  });
}
