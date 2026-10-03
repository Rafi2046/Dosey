import 'package:intl/intl.dart';

/// Numbers for display, in the current language's digits: 2.0 → "2",
/// 2.5 → "2.5" ("২.৫" in Bengali). Text-field values must stay Latin; use
/// `ReminderText.formatAmount` for those.
abstract final class AppNumber {
  static String format(num value) => NumberFormat('0.##').format(value);
}
