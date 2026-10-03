import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/l10n.dart';
import '../core/notifications/notification_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/providers/settings_providers.dart';
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
    final language = ref.watch(languageProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.current,
      // Null follows the phone; unsupported phone languages fall back to
      // English (the first supported locale).
      locale: language == null ? null : Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        // Keep context-free code (validators, number/date formats) in step
        // with the language actually on screen.
        AppLocale.apply(Localizations.localeOf(context));
        return AlarmHost(
          navigatorKey: _navigatorKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const StartupGate(),
    );
  }
}
