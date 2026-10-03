import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/notifications/permission_service.dart';
import '../../../../core/localization/l10n.dart';

/// Presentation details for each [AppPermission].
extension PermissionMeta on AppPermission {
  String get title => switch (this) {
    AppPermission.notifications => context.l10n.permNotificationsTitle,
    AppPermission.exactAlarms => context.l10n.permExactAlarmsTitle,
    AppPermission.fullScreen => context.l10n.permFullScreenTitle,
    AppPermission.dnd => context.l10n.permDndTitle,
  };

  String get description => switch (this) {
    AppPermission.notifications => context.l10n.permNotificationsBody,
    AppPermission.exactAlarms => context.l10n.permExactAlarmsBody,
    AppPermission.fullScreen => context.l10n.permFullScreenBody,
    AppPermission.dnd => context.l10n.permDndBody,
  };

  IconData get icon => switch (this) {
    AppPermission.notifications => Icons.notifications_active_rounded,
    AppPermission.exactAlarms => Icons.alarm_rounded,
    AppPermission.fullScreen => Icons.stay_current_portrait_rounded,
    AppPermission.dnd => Icons.do_not_disturb_off_rounded,
  };

  String get badge =>
      isRequired ? context.l10n.required : context.l10n.recommended;
}
