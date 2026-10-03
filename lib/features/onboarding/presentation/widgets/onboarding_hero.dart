import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';

/// Alarm-clock illustration with the serif headline, as on the welcome screen.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AppImages.alarmClock,
          height: AppSpacing.heroIllustration,
          fit: BoxFit.contain,
        ),
        AppSpacing.gapLg,
        Text(
          context.l10n.onboardingTitle,
          style: AppTextStyles.display,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapMd,
        Text(
          context.l10n.onboardingBody,
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
