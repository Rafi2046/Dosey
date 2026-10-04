import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/reminders/data/reminders_repository.dart';
import '../../features/reminders/domain/reminder_schedule.dart';
import '../../features/reminders/domain/reminder_text.dart';
import '../../features/reminders/domain/reminder_with_details.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../localization/l10n.dart';
import '../utils/date_format.dart';
import '../utils/enum_labels.dart';

/// One upcoming time on the widget: the medicines due then, ready to show.
class WidgetSlot {
  const WidgetSlot({
    required this.at,
    required this.title,
    required this.lines,
  });

  final DateTime at;

  /// Medicine name, or "2 medicines" when several are due together.
  final String title;

  /// "2 tablets · After meal", or one "Name · dose" line per medicine.
  final List<String> lines;
}

/// Feeds the native home screen widget (NextDoseWidget.kt on Android,
/// DoseyWidget.swift on iOS) with the next medicine doses.
///
/// The widget can't query the database, so this writes a short list of
/// upcoming slots (already worded and in the user's language) to the
/// storage the widget reads, then asks it to redraw. The widget shows the
/// first slot that's still due, so it stays right between refreshes; it's
/// refreshed whenever the schedule changes, a dose is taken/skipped/
/// snoozed, the language changes, an Android alarm fires and on every
/// launch.
class HomeWidgetSync {
  HomeWidgetSync(this._reminders, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final RemindersRepository _reminders;
  final DateTime Function() _clock;

  /// How far ahead slots are written, and how many at most.
  static const Duration horizon = Duration(days: 3);
  static const int maxSlots = 12;

  /// A dose not yet taken or skipped keeps showing ("Due now") this long.
  static const Duration dueWindow = AppConstants.missedThreshold;

  /// Upcoming medicine slots from [now]: doses due in the last [dueWindow]
  /// that are still open, then everything up to [horizon], medicines due at
  /// the same minute together. Doses already taken, skipped or missed are
  /// left out.
  static List<WidgetSlot> plan(
    AppLocalizations l,
    List<ReminderWithDetails> reminders,
    List<ReminderLog> logs,
    DateTime now,
  ) {
    final done = {
      for (final log in logs)
        if (log.status != ReminderLogStatus.snoozed)
          (log.reminderId, log.scheduledFor),
    };
    final from = now.subtract(dueWindow);
    final until = now.add(horizon);
    final bySlot = <DateTime, List<ReminderWithDetails>>{};
    for (final d in reminders) {
      final r = d.reminder;
      if (!r.isEnabled || r.type != ReminderType.medicine) continue;
      var cursor = from;
      while (true) {
        final at = ReminderSchedule.nextFor(r, cursor);
        if (at == null || at.isAfter(until)) break;
        if (!done.contains((r.id, at))) (bySlot[at] ??= []).add(d);
        cursor = at;
      }
    }
    final times = bySlot.keys.toList()..sort();
    return [
      for (final at in times.take(maxSlots))
        _slot(
          l,
          at,
          bySlot[at]!..sort((a, b) => a.reminder.id - b.reminder.id),
        ),
    ];
  }

  static WidgetSlot _slot(
    AppLocalizations l,
    DateTime at,
    List<ReminderWithDetails> group,
  ) {
    String dose(ReminderWithDetails d) => switch (d.medicine) {
      final m? => ReminderText.dose(l, d.reminder.doseAmount ?? 1, m.doseUnit),
      null => '',
    };
    if (group.length == 1) {
      final d = group.single;
      return WidgetSlot(
        at: at,
        title: d.reminder.title,
        lines: [
          [
            dose(d),
            if (d.medicine case final m?) m.mealRelation.label(l),
          ].where((s) => s.isNotEmpty).join(l.notifDoseSeparator),
        ],
      );
    }
    return WidgetSlot(
      at: at,
      title: l.alarmGroupCount(group.length),
      lines: [
        for (final d in group)
          '${d.reminder.title}${l.notifDoseSeparator}${dose(d)}',
      ],
    );
  }

  /// The JSON the native widgets read.
  static String encode(AppLocalizations l, List<WidgetSlot> slots) =>
      jsonEncode({
        'labels': {
          'next': l.widgetNext,
          'due': l.widgetDue,
          'empty': l.widgetEmpty,
          'today': l.widgetToday,
          'tomorrow': l.widgetTomorrow,
        },
        'slots': [
          for (final s in slots)
            {
              'at': s.at.millisecondsSinceEpoch,
              'time': AppDateFormat.time(s.at),
              'date': AppDateFormat.shortDate(s.at),
              'title': s.title,
              'lines': s.lines,
            },
        ],
      });

  Future<void> refresh() async {
    // Not on desktop/tests; and a widget glitch must never break alarms.
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final now = _clock();
      final l = AppLocale.l10n;
      final slots = plan(
        l,
        await _reminders.getEnabledDetails(),
        await _reminders.logsBetween(
          now.subtract(dueWindow),
          now.add(horizon).add(const Duration(minutes: 1)),
        ),
        now,
      );
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      }
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetDataKey,
        encode(l, slots),
      );
      await HomeWidget.updateWidget(
        androidName: AppConstants.widgetAndroidName,
        iOSName: AppConstants.widgetIosKind,
      );
    } on PlatformException {
      // Widget not supported/added: nothing to update.
    } on MissingPluginException {
      // Isolate without the plugin.
    }
  }
}
