import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/enums.dart';
import '../core/notifications/native_bridge.dart';
import '../core/notifications/notification_providers.dart';
import '../core/utils/clock_providers.dart';
import '../features/alarm/presentation/alarm_ring_screen.dart';
import '../features/reminders/domain/reminder_with_details.dart';
import '../features/reminders/providers/reminders_providers.dart';

/// Shows [AlarmRingScreen] whenever a reminder is ringing (DB `ringingFor`),
/// whether the app was opened by the full-screen intent, a notification tap,
/// or was already in the foreground. Removes it when the occurrence is handled
/// anywhere, then hands the lock screen back to the keyguard.
class AlarmHost extends ConsumerStatefulWidget {
  const AlarmHost({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<AlarmHost> createState() => _AlarmHostState();
}

class _AlarmHostState extends ConsumerState<AlarmHost>
    with WidgetsBindingObserver {
  Route<void>? _route;
  (List<int>, DateTime)? _showing;

  /// The oldest ringing occurrence: every medicine ringing for that same
  /// time together, or a single other reminder.
  static List<ReminderWithDetails> _firstGroup(
    List<ReminderWithDetails> ringing,
  ) {
    final first = ringing.firstOrNull;
    if (first == null) return const [];
    if (first.reminder.type != ReminderType.medicine) return [first];
    return [
      for (final d in ringing)
        if (d.reminder.type == ReminderType.medicine &&
            d.reminder.ringingFor == first.reminder.ringingFor)
          d,
    ];
  }

  void _onRinging(List<ReminderWithDetails> ringing) {
    final group = _firstGroup(ringing);
    final key = group.isEmpty
        ? null
        : (
            [for (final d in group) d.reminder.id],
            group.first.reminder.ringingFor!,
          );
    if (_sameKey(key, _showing)) return;

    _removeRoute();
    if (key == null) {
      NativeBridge.setShowOverLockScreen(false);
      return;
    }
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;
    _showing = key;
    _route = MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AlarmRingScreen(group: group, scheduledFor: key.$2),
    );
    navigator.push(_route!);
  }

  static bool _sameKey((List<int>, DateTime)? a, (List<int>, DateTime)? b) =>
      a == null || b == null ? a == b : a.$2 == b.$2 && listEquals(a.$1, b.$1);

  void _removeRoute() {
    final route = _route;
    if (route != null && route.isActive) {
      widget.navigatorKey.currentState?.removeRoute(route);
    }
    _route = null;
    _showing = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Watch for reminders that have been marked as ringing
    ref.listenManual(ringingRemindersProvider, (_, next) {
      final ringing = next.value;
      if (ringing == null) return;
      // The navigator may not exist yet on the very first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRinging(ringing));
    }, fireImmediately: true);

    // While in foreground, actively check for due occurrences on minute ticks
    ref.listenManual(minuteTickerProvider, (_, next) {
      final now = next.value;
      if (now != null) {
        ref.read(alarmEngineProvider).checkDueNow(now);
      }
    }, fireImmediately: true);

    // Initial foreground check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmEngineProvider).checkDueNow();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(alarmEngineProvider).checkDueNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
