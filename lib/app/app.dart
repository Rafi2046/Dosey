import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import '../core/localization/bangla_material_localizations.dart';
import '../core/localization/l10n.dart';
import '../core/notifications/notification_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/providers/settings_providers.dart';
import '../features/lock/presentation/lock_gate.dart';
import 'alarm_host.dart';
import 'startup_gate.dart';

class DoseyApp extends ConsumerStatefulWidget {
  const DoseyApp({super.key});

  @override
  ConsumerState<DoseyApp> createState() => _DoseyAppState();
}

class _DoseyAppState extends ConsumerState<DoseyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  static void _rebuildAll(BuildContext context) {
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) {
    // Keep OS alarms mirrored to the database while the UI is alive.
    ref.watch(alarmSyncProvider);
    final language = ref.watch(languageProvider);
    final mode = ref.watch(themeModeProvider);
    final dark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    // Colors are read from AppColors, not inherited, so a theme change has
    // to redraw everything below (in place: routes and state are kept).
    if (AppColors.apply(dark ? AppPalette.dark : AppPalette.light)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _rebuildAll(context);
      });
    }

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.current,
      // Null follows the phone; unsupported phone languages fall back to
      // English (the first supported locale).
      locale: language == null ? null : Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        // Before the stock delegates so Bengali gets AM/PM time.
        BanglaTwelveHourMaterialLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      builder: (context, child) {
        // Keep context-free code (validators, number/date formats) in step
        // with the language actually on screen.
        AppLocale.apply(Localizations.localeOf(context));
        return AlarmHost(
          child: LockGate(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const StartupGate(),
    );
  }
}
