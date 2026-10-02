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
