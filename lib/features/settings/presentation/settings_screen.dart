import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/notifications/permission_service.dart';
import '../../../app/home_tab.dart';
import '../../../core/widgets/segmented_choice.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/status_chip.dart';
import '../../onboarding/providers/permissions_provider.dart';
import '../domain/legal_document.dart';
import '../providers/settings_providers.dart';
import 'legal_screen.dart';
import 'permissions_screen.dart';
import 'widgets/name_sheet.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

/// App preferences, alarm health, support and the legal pages.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Null = follow the phone.
  static const List<String?> _languages = [null, 'en', 'bn'];

  static void _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  static Future<void> _launch(BuildContext context, Uri uri) async {
    final failed = context.l10n.couldNotOpen;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  /// Two confirmations (it can't be undone), then wipe, back to Home.
  static Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    if (!await confirmDelete(
      context,
      title: l10n.deleteAllTitle,
      body: l10n.deleteAllBody,
      confirmLabel: l10n.continueLabel,
    )) {
      return;
    }
    if (!context.mounted) return;
    if (!await confirmDelete(
      context,
      title: l10n.deleteAllConfirmTitle,
      body: l10n.deleteAllConfirmBody,
      confirmLabel: l10n.deleteEverything,
    )) {
      return;
    }
    await ref.read(dataResetServiceProvider).deleteAll();
    await ref.read(userNameProvider.notifier).set(null);
    ref.read(homeTabProvider.notifier).select(HomeTab.dashboard);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(l10n.allDataDeleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = ref.watch(languageProvider);
    final theme = ref.watch(themeModeProvider);
    final granted = ref.watch(permissionsProvider).value ?? const {};
    final missing = AppPermission.onThisPlatform
        .where((p) => !granted.contains(p))
        .length;
    final name = ref.watch(userNameProvider).value;
    final info = ref.watch(packageInfoProvider).value;
    final version = info == null
        ? null
        : l10n.appVersion('${info.version} (${info.buildNumber})');

    return CreamScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xxl),
        children: [
          SettingsSection(
            title: l10n.settingsProfile,
            children: [
              SettingsTile(
                icon: Icons.person_rounded,
                color: AppColors.tileOlive,
                title: name ?? l10n.settingsAddName,
                subtitle: name == null ? l10n.settingsNameHint : l10n.yourName,
                onTap: () async {
                  final entered = await showNameSheet(context, current: name);
                  if (entered != null) {
                    await ref.read(userNameProvider.notifier).set(entered);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsPreferences,
            children: [
              SettingsTile(
                icon: Icons.translate_rounded,
                color: AppColors.tileMint,
                title: l10n.settingsLanguage,
                below: SegmentedChoice<String?>(
                  options: _languages,
                  selected: language,
                  labelOf: (code) => switch (code) {
                    'en' => l10n.languageEnglish,
                    'bn' => l10n.languageBangla,
                    _ => l10n.languageSystem,
                  },
                  onChanged: ref.read(languageProvider.notifier).choose,
                ),
              ),
              SettingsTile(
                icon: Icons.contrast_rounded,
                color: AppColors.tileStone,
                title: l10n.settingsAppearance,
                below: SegmentedChoice<ThemeMode>(
                  options: ThemeMode.values,
                  selected: theme,
                  iconOf: (m) => switch (m) {
                    ThemeMode.system => Icons.brightness_auto_rounded,
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                  },
                  labelOf: (m) => switch (m) {
                    ThemeMode.system => l10n.themeSystem,
                    ThemeMode.light => l10n.themeLight,
                    ThemeMode.dark => l10n.themeDark,
                  },
                  onChanged: ref.read(themeModeProvider.notifier).choose,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsReminders,
            children: [
              SettingsTile(
                icon: Icons.alarm_on_rounded,
                color: AppColors.accent,
                title: l10n.settingsPermissions,
                trailing: missing == 0
                    ? StatusChip(
                        label: l10n.permissionsAllAllowed,
                        icon: Icons.check_rounded,
                        background: AppColors.mint,
                      )
                    : StatusChip(
                        label: l10n.permissionsMissing(missing),
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.accent,
                        foreground: AppColors.textOnAccent,
                      ),
                onTap: () => _push(context, const PermissionsScreen()),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsYourData,
            children: [
              SettingsTile(
                icon: Icons.delete_forever_rounded,
                color: AppColors.error,
                title: l10n.deleteAllData,
                subtitle: l10n.deleteAllDataHint,
                onTap: () => _deleteAll(context, ref),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsSupport,
            children: [
              SettingsTile(
                icon: Icons.mail_rounded,
                color: AppColors.tileOlive,
                title: l10n.contactSupport,
                subtitle: l10n.contactSupportHint,
                onTap: () => _launch(
                  context,
                  Uri(
                    scheme: 'mailto',
                    path: AppConstants.supportEmail,
                    query:
                        'subject=${Uri.encodeComponent(l10n.supportEmailSubject)}'
                        '${version == null ? '' : ' (${Uri.encodeComponent(version)})'}',
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.star_rounded,
                color: AppColors.warning,
                title: l10n.rateApp,
                subtitle: l10n.rateAppHint,
                onTap: () =>
                    _launch(context, Uri.parse(AppConstants.playStoreUrl)),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsAbout,
            children: [
              SettingsTile(
                icon: Icons.lock_rounded,
                color: AppColors.tileMoss,
                title: l10n.privacyPolicy,
                subtitle: l10n.privacyPolicyHint,
                onTap: () => _push(
                  context,
                  const LegalScreen(document: LegalDocument.privacy),
                ),
              ),
              SettingsTile(
                icon: Icons.description_rounded,
                color: AppColors.tileStone,
                title: l10n.termsOfUse,
                onTap: () => _push(
                  context,
                  const LegalScreen(document: LegalDocument.terms),
                ),
              ),
              SettingsTile(
                icon: Icons.health_and_safety_rounded,
                color: AppColors.tileMint,
                title: l10n.medicalDisclaimer,
                subtitle: l10n.medicalDisclaimerHint,
                onTap: () => _push(
                  context,
                  const LegalScreen(document: LegalDocument.disclaimer),
                ),
              ),
              SettingsTile(
                icon: Icons.code_rounded,
                color: AppColors.tileOlive,
                title: l10n.licenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: version,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Image.asset(
                      AppImages.logo,
                      width: AppSpacing.appIconLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (version != null)
            Center(
              child: Text(
                '${l10n.appName} · $version',
                style: AppTextStyles.captionOnLight,
              ),
            ),
        ],
      ),
    );
  }
}
