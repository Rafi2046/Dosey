import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/native_bridge.dart';
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

class _AlarmHostState extends ConsumerState<AlarmHost> {
  Route<void>? _route;
  (int, DateTime)? _showing;

  void _onRinging(List<ReminderWithDetails> ringing) {
    final first = ringing.firstOrNull;
    final key = first == null
        ? null
        : (first.reminder.id, first.reminder.ringingFor!);
    if (key == _showing) return;

    _removeRoute();
    if (first == null) {
      NativeBridge.setShowOverLockScreen(false);
      return;
    }
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;
    _showing = key;
    _route = MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AlarmRingScreen(details: first, scheduledFor: key!.$2),
    );
    navigator.push(_route!);
  }

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
    ref.listenManual(ringingRemindersProvider, (_, next) {
      final ringing = next.value;
      if (ringing == null) return;
      // The navigator may not exist yet on the very first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRinging(ringing));
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
