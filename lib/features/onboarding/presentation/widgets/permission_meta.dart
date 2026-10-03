import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/notifications/permission_service.dart';

/// Presentation details for each [AppPermission].
extension PermissionMeta on AppPermission {
  String get title => switch (this) {
    AppPermission.notifications => OnboardingStrings.permNotificationsTitle,
    AppPermission.exactAlarms => OnboardingStrings.permExactAlarmsTitle,
    AppPermission.fullScreen => OnboardingStrings.permFullScreenTitle,
    AppPermission.dnd => OnboardingStrings.permDndTitle,
  };

  String get description => switch (this) {
    AppPermission.notifications => OnboardingStrings.permNotificationsBody,
    AppPermission.exactAlarms => OnboardingStrings.permExactAlarmsBody,
    AppPermission.fullScreen => OnboardingStrings.permFullScreenBody,
    AppPermission.dnd => OnboardingStrings.permDndBody,
  };

  IconData get icon => switch (this) {
    AppPermission.notifications => Icons.notifications_active_rounded,
    AppPermission.exactAlarms => Icons.alarm_rounded,
    AppPermission.fullScreen => Icons.stay_current_portrait_rounded,
    AppPermission.dnd => Icons.do_not_disturb_off_rounded,
  };

  String get badge =>
      isRequired ? OnboardingStrings.required : OnboardingStrings.recommended;
}
