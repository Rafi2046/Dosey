import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/notifications/permission_service.dart';

/// Presentation details for each [AppPermission].
extension PermissionMeta on AppPermission {
  String get title => switch (this) {
    AppPermission.notifications => AppStrings.permNotificationsTitle,
    AppPermission.exactAlarms => AppStrings.permExactAlarmsTitle,
    AppPermission.fullScreen => AppStrings.permFullScreenTitle,
    AppPermission.dnd => AppStrings.permDndTitle,
  };

  String get description => switch (this) {
    AppPermission.notifications => AppStrings.permNotificationsBody,
    AppPermission.exactAlarms => AppStrings.permExactAlarmsBody,
    AppPermission.fullScreen => AppStrings.permFullScreenBody,
    AppPermission.dnd => AppStrings.permDndBody,
  };

  IconData get icon => switch (this) {
    AppPermission.notifications => Icons.notifications_active_rounded,
    AppPermission.exactAlarms => Icons.alarm_rounded,
    AppPermission.fullScreen => Icons.stay_current_portrait_rounded,
    AppPermission.dnd => Icons.do_not_disturb_off_rounded,
  };

  String get badge => isRequired ? AppStrings.required : AppStrings.recommended;
}
