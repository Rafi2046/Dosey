import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import 'debug_test_alarm_button.dart';

/// Temporary home until the dashboard shell lands in the next step.
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),
              Image.asset(AppImages.logo, width: AppSpacing.logo),
              AppSpacing.gapLg,
              const Text(AppStrings.appName, style: AppTextStyles.display),
              AppSpacing.gapXs,
              const Text(AppStrings.tagline, style: AppTextStyles.bodyMuted),
              const Spacer(),
              if (kDebugMode) const DebugTestAlarmButton(),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}
