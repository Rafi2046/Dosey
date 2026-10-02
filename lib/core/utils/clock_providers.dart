import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's date (midnight), re-emitted when the day changes so "today"
/// views roll over without an app restart.
final currentDayProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    final now = DateTime.now();
    yield DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    await Future<void>.delayed(tomorrow.difference(now));
  }
});

/// Current time, re-emitted at the start of every minute (for countdowns).
final minuteTickerProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    final now = DateTime.now();
    yield now;
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    await Future<void>.delayed(nextMinute.difference(now));
  }
});
