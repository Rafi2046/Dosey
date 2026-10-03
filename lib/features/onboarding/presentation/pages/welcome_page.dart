import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../settings/providers/settings_providers.dart';
import '../widgets/language_choice.dart';

/// Page 1: the alarm-clock hero, what Dosey is, and the language choice
/// (applied instantly, so the rest of onboarding is already in it).
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected =
        ref.watch(languageProvider) ??
        Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            AppImages.alarmClock,
            height: AppSpacing.onboardingHero,
            fit: BoxFit.contain,
          ),
          AppSpacing.gapLg,
          Text(
            l10n.onboardingTitle,
            style: AppTextStyles.display,
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapMd,
          Text(
            l10n.onboardingWelcomeBody,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapXxl,
          Text(l10n.onboardingChooseLanguage, style: AppTextStyles.subtitle),
          AppSpacing.gapMd,
          LanguageChoice(
            selected: selected,
            onChanged: (code) =>
                ref.read(languageProvider.notifier).choose(code),
          ),
        ],
      ),
    );
  }
}
