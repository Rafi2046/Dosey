import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/reminders/providers/reminders_providers.dart';
import '../home_widget/home_widget_sync.dart';
import 'alarm_runtime.dart';
import 'awesome_notification_presenter.dart';
import 'permission_service.dart';
import 'reminder_alarm_engine.dart';

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

final alarmEngineProvider = Provider<ReminderAlarmEngine>((ref) {
  final reminders = ref.watch(remindersRepositoryProvider);
  return ReminderAlarmEngine(
    reminders: reminders,
    scheduler: AlarmRuntime.schedulerFor(reminders),
    notifier: AwesomeNotificationPresenter(),
    homeWidget: ref.watch(homeWidgetSyncProvider),
  );
});

/// Home screen widget feed (see HomeWidgetSync).
final homeWidgetSyncProvider = Provider<HomeWidgetSync>(
  (ref) => HomeWidgetSync(ref.watch(remindersRepositoryProvider)),
);

/// While the UI is alive, mirrors every reminder change (create, edit,
/// enable/disable, delete) into OS alarms. Keep it alive by watching it from
/// the app root. Background isolates schedule directly via the engine.
final alarmSyncProvider = Provider<void>((ref) {
  final engine = ref.watch(alarmEngineProvider);
  final signatures = <int, (bool, DateTime?, bool)>{};

  final subscription = ref
      .watch(remindersRepositoryProvider)
      .watchAllRaw()
      .listen((rows) async {
        final present = <int>{};
        var changed = false;
        for (final r in rows) {
          present.add(r.id);
          final signature = (r.isEnabled, r.nextTriggerAt, r.isCritical);
          if (signatures[r.id] == signature) continue;
          signatures[r.id] = signature;
          changed = true;
        }
        final removed = signatures.keys.where((id) => !present.contains(id));
        for (final id in removed.toList()) {
          signatures.remove(id);
          await engine.cancel(id);
          changed = true;
        }
        // Any change can regroup medicines due at the same minute, so
        // re-derive every alarm at once (one alarm per group).
        if (changed) await engine.syncAll();
      });
  ref.onDispose(subscription.cancel);
});
