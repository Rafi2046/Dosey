import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Thin wrappers over the Material date/time pickers with app-wide bounds.
abstract final class AppPickers {
  static final DateTime _first = DateTime(2000);
  static final DateTime _last = DateTime(2100);

  static Future<DateTime?> date(BuildContext context, {DateTime? initial}) =>
      showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: _first,
        lastDate: _last,
      );

  static Future<TimeOfDay?> time(BuildContext context, {TimeOfDay? initial}) =>
      showTimePicker(
        context: context,
        initialTime: initial ?? TimeOfDay.now(),
        builder: _roomForTimeInput,
      );

  /// Works around a Flutter bug: in keyboard-entry mode the time picker
  /// needs ≥216px of height but sizes itself as 252px × the phone's font
  /// scale, and also lets a tall keyboard squeeze it. Either way it can end
  /// up under 216px and throw "BoxConstraints has non-normalized height
  /// constraints" (e.g. system font size 0.8 → 201.6px).
  ///
  /// So inside the picker only: text is never scaled below normal, and the
  /// keyboard is reported short enough to leave the dialog its room (the
  /// hour/minute fields sit at its top, above the keyboard).
  static Widget _roomForTimeInput(BuildContext context, Widget? child) {
    final media = MediaQuery.of(context);
    final maxInset = (media.size.height - AppSpacing.timePickerMinRoom).clamp(
      0.0,
      double.infinity,
    );
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(minScaleFactor: 1),
        viewInsets: media.viewInsets.bottom <= maxInset
            ? media.viewInsets
            : media.viewInsets.copyWith(bottom: maxInset),
      ),
      child: child!,
    );
  }

  /// Date then time; null if either is cancelled.
  static Future<DateTime?> dateTime(
    BuildContext context, {
    DateTime? initial,
  }) async {
    final day = await date(context, initial: initial);
    if (day == null || !context.mounted) return null;
    final t = await time(
      context,
      initial: initial == null ? null : TimeOfDay.fromDateTime(initial),
    );
    if (t == null) return null;
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }
}
