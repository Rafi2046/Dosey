import 'package:flutter/material.dart';

import '../../../../core/notifications/permission_service.dart';
import '../../../../core/localization/l10n.dart';

/// Presentation details for each [AppPermission].
extension PermissionMeta on AppPermission {
  String title(AppLocalizations l) => switch (this) {
    AppPermission.notifications => l.permNotificationsTitle,
    AppPermission.exactAlarms => l.permExactAlarmsTitle,
    AppPermission.fullScreen => l.permFullScreenTitle,
    AppPermission.dnd => l.permDndTitle,
  };

  String description(AppLocalizations l) => switch (this) {
    AppPermission.notifications => l.permNotificationsBody,
    AppPermission.exactAlarms => l.permExactAlarmsBody,
    AppPermission.fullScreen => l.permFullScreenBody,
    AppPermission.dnd => l.permDndBody,
  };

  IconData get icon => switch (this) {
    AppPermission.notifications => Icons.notifications_active_rounded,
    AppPermission.exactAlarms => Icons.alarm_rounded,
    AppPermission.fullScreen => Icons.stay_current_portrait_rounded,
    AppPermission.dnd => Icons.do_not_disturb_off_rounded,
  };

  String badge(AppLocalizations l) => isRequired ? l.required : l.recommended;
}
