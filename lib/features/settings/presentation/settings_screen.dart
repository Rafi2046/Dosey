import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/home_tab.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/notifications/permission_service.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/share_providers.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/segmented_choice.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/presentation/family_sharing_auth_sheet.dart';
import '../../auth/providers/auth_providers.dart';
import '../../lock/providers/app_lock_providers.dart';
import '../../onboarding/providers/permissions_provider.dart';
import '../../profiles/data/profiles_repository.dart';
import '../../profiles/presentation/profile_widgets.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/backup_service.dart';
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

  /// Turning App lock on or off needs the phone's owner first, so nobody
  /// can lock someone out of (or into) their records.
  static Future<void> _setAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(appLockAuthProvider)(l10n.appLockReason);
    if (!ok) {
      if (enable) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.appLockUnavailable)),
        );
      }
      return;
    }
    await ref.read(appLockEnabledProvider.notifier).set(enable);
    // Just proved who it is: don't lock straight away.
    ref.read(appLockedProvider.notifier).unlock();
  }

  /// Builds a backup file and hands it to the share sheet (Drive, Files,
  /// WhatsApp…), remembering when it was taken.
  static Future<void> _backUp(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = Directory.systemTemp.createTempSync('dosey_backup');
      final file = await ref.read(backupServiceProvider).create(dir);
      final shared = await ref.read(fileSharerProvider)(
        file,
        l10n.backupShareSubject,
      );
      if (shared) {
        await ref
            .read(settingsRepositoryProvider)
            .set(lastBackupKey, DateTime.now().toIso8601String());
        ref.invalidate(lastBackupProvider);
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupFailed)));
    }
  }

  /// Picks a backup file, confirms (it replaces everything), restores it and
  /// re-arms every alarm from the restored reminders.
  static Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final bytes = await ref.read(backupPickerProvider)();
    if (bytes == null || !context.mounted) return;
    if (!await confirmDelete(
      context,
      title: l10n.restoreConfirmTitle,
      body: l10n.restoreConfirmBody,
      confirmLabel: l10n.restoreConfirm,
    )) {
      return;
    }
    try {
      await ref
          .read(backupServiceProvider)
          .restore(
            bytes,
            workDir: Directory.systemTemp.createTempSync('dosey_restore'),
          );
    } on RestoreException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (e.error) {
            RestoreError.notABackup => l10n.restoreNotABackup,
            RestoreError.tooNew => l10n.restoreTooNew,
          }),
        ),
      );
      return;
    }
    await ref.read(alarmEngineProvider).resyncAll();
    // The backup may not have the profile that was open.
    await ref
        .read(activeProfileIdProvider.notifier)
        .select(ProfilesRepository.mainProfileId);
    ref
      ..invalidate(userNameProvider)
      ..invalidate(lastBackupProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
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
    await ref
        .read(activeProfileIdProvider.notifier)
        .select(ProfilesRepository.mainProfileId);
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
    final authUser = ref.watch(currentUserProvider);
    final info = ref.watch(packageInfoProvider).value;
    final version = info == null
        ? null
        : l10n.appVersion('${info.version} (${info.buildNumber})');

    return Scaffold(
      backgroundColor: AppColors.sage,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xxl),
          children: [
            ScreenHeader(title: l10n.settingsHeader),
            // ── ACCOUNT & FAMILY SHARING ───────────────────────────────────────
            SettingsSection(
              title: l10n.settingsProfile,
              children: [
                SettingsTile(
                  icon: Icons.person_rounded,
                  color: AppColors.tileOlive,
                  title: name ?? authUser?.displayName ?? l10n.settingsAddName,
                  subtitle: name == null
                      ? l10n.settingsNameHint
                      : l10n.yourName,
                  onTap: () async {
                    final entered = await showNameSheet(context, current: name);
                    if (entered != null) {
                      await ref.read(userNameProvider.notifier).set(entered);
                    }
                  },
                ),
                SettingsTile(
                  icon: Icons.family_restroom_rounded,
                  color: AppColors.tileMint,
                  title: l10n.profilesTitle,
                  subtitle: l10n.profilesHint,
                  onTap: () => _push(context, const ProfilesScreen()),
                ),
                SettingsTile(
                  icon: Icons.diversity_1_rounded,
                  color: AppColors.accent,
                  title: 'Caregiver & Family Mode',
                  subtitle: authUser != null
                      ? (authUser.email ?? 'Family Sharing Connected')
                      : 'Link with family & caregivers',
                  subtitleMaxLines: 1,
                  trailing: authUser != null
                      ? StatusChip(
                          label: 'Active',
                          icon: Icons.cloud_done_rounded,
                          background: AppColors.tileMint,
                          foreground: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        )
                      : null,
                  onTap: () => showFamilySharingAuthSheet(context),
                ),
              ],
            ),

            // ── PREFERENCES & CONTROLS ─────────────────────────────────────────
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
                SettingsTile(
                  icon: Icons.lock_rounded,
                  color: AppColors.tileMoss,
                  title: l10n.appLockTitle,
                  subtitle: l10n.appLockHint,
                  trailing: AppSwitch(
                    value: ref.watch(appLockEnabledProvider).value ?? false,
                    onChanged: (v) => _setAppLock(context, ref, v),
                  ),
                ),
                SettingsTile(
                  icon: Icons.alarm_on_rounded,
                  color: AppColors.accent,
                  title: l10n.settingsPermissions,
                  trailing: missing == 0
                      ? StatusChip(
                          label: l10n.permissionsAllAllowed,
                          icon: Icons.check_rounded,
                          background: AppColors.tileMint,
                          foreground: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        )
                      : StatusChip(
                          label: l10n.permissionsMissing(missing),
                          icon: Icons.warning_amber_rounded,
                          background: AppColors.accent,
                          foreground: AppColors.textOnAccent,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                  onTap: () => _push(context, const PermissionsScreen()),
                ),
              ],
            ),

            // ── YOUR DATA & BACKUP ─────────────────────────────────────────────
            SettingsSection(
              title: l10n.settingsYourData,
              children: [
                SettingsTile(
                  icon: Icons.cloud_upload_rounded,
                  color: AppColors.tileMint,
                  title: l10n.backupTitle,
                  subtitle: switch (ref.watch(lastBackupProvider).value) {
                    final at? => l10n.backupLast(AppDateFormat.date(at)),
                    null => l10n.backupNever,
                  },
                  onTap: () => _backUp(context, ref),
                ),
                SettingsTile(
                  icon: Icons.settings_backup_restore_rounded,
                  color: AppColors.tileOlive,
                  title: l10n.restoreTitle,
                  subtitle: l10n.restoreHint,
                  onTap: () => _restore(context, ref),
                ),
                SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  color: AppColors.error,
                  title: l10n.deleteAllData,
                  subtitle: l10n.deleteAllDataHint,
                  onTap: () => _deleteAll(context, ref),
                ),
              ],
            ),

            // ── HELP & SUPPORT ─────────────────────────────────────────────────
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
                  color: AppColors.accent,
                  title: l10n.rateApp,
                  subtitle: l10n.rateAppHint,
                  onTap: () =>
                      _launch(context, Uri.parse(AppConstants.playStoreUrl)),
                ),
              ],
            ),

            // ── ABOUT & LEGAL ──────────────────────────────────────────────────
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
              ],
            ),

            // ── FOOTER BRANDING ────────────────────────────────────────────────
            if (version != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(AppImages.logo, width: 28, height: 28),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${l10n.appName} · $version',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDarkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Offline-first • Privacy conscious',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDarkMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
