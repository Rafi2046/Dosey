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
  const AlarmHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AlarmHost> createState() => _AlarmHostState();
}

class _AlarmHostState extends ConsumerState<AlarmHost>
    with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Watch for reminders that have been marked as ringing to toggle native lock screen
    ref.listenManual(ringingRemindersProvider, (_, next) {
      final ringing = next.value ?? const [];
      NativeBridge.setShowOverLockScreen(ringing.isNotEmpty);
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
  Widget build(BuildContext context) {
    final ringing = ref.watch(ringingRemindersProvider).value ?? const [];
    final group = _firstGroup(ringing);
    final isRinging = group.isNotEmpty && group.first.reminder.ringingFor != null;
    final groupKey = isRinging
        ? '${group.first.reminder.ringingFor!.millisecondsSinceEpoch}_${group.map((d) => d.reminder.id).join(',')}'
        : null;

    return Stack(
      children: [
        Offstage(
          offstage: isRinging,
          child: widget.child,
        ),
        if (isRinging)
          Positioned.fill(
            key: ValueKey(groupKey),
            child: HeroControllerScope.none(
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => AlarmRingScreen(
                    group: group,
                    scheduledFor: group.first.reminder.ringingFor!,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
