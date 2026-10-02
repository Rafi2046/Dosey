import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import '../core/notifications/notification_providers.dart';
import '../core/theme/app_theme.dart';
import 'alarm_host.dart';
import 'startup_gate.dart';

class DoseyApp extends ConsumerStatefulWidget {
  const DoseyApp({super.key});

  @override
  ConsumerState<DoseyApp> createState() => _DoseyAppState();
}

class _DoseyAppState extends ConsumerState<DoseyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Keep OS alarms mirrored to the database while the UI is alive.
    ref.watch(alarmSyncProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light,
      builder: (context, child) => AlarmHost(
        navigatorKey: _navigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const StartupGate(),
    );
  }
}
