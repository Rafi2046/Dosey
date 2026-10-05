import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/sheet_title.dart';
import '../../settings/presentation/widgets/name_sheet.dart';
import '../data/profiles_repository.dart';
import '../providers/profiles_providers.dart';

/// "Ammu", or "Me" for the user's own profile before it's named.
String profileName(AppLocalizations l, Profile p) =>
    p.name.isEmpty ? l.profileMe : p.name;

/// The family member [p] is, for labelling alarms; null for the user's own
/// profile (their alarms stay as they were).
String? familyMemberName(AppLocalizations l, Profile? p) =>
    p == null || p.id == ProfilesRepository.mainProfileId
    ? null
    : profileName(l, p);

/// Avatar + name above a family member's dose on the alarm screen.
class ForProfileLabel extends StatelessWidget {
  const ForProfileLabel(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      InitialsAvatar(name: name, size: AppSpacing.iconLg),
      AppSpacing.gapSm,
      Flexible(
        child: Text(
          name,
          style: AppTextStyles.subtitleOnLight,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// Asks for a name and adds a family member; returns their id, or null.
Future<int?> addFamilyMember(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final name = await showNameSheet(
    context,
    label: l10n.profileNameLabel,
    hint: l10n.profileNameHint,
  );
  if (name == null || name.trim().isEmpty) return null;
  final count = ref.read(profilesProvider).value?.length ?? 1;
  return ref
      .read(profilesRepositoryProvider)
      .create(name, colorIndex: count % AppColors.cardCycle.length);
}

/// "◉ Ammu ▾" on Home and the medicine/reminder tabs: whose data is on
/// screen, tap to switch. Hidden while there's only one profile, so a
/// single user never sees it.
class ProfilePill extends ConsumerWidget {
  const ProfilePill({super.key, this.margin = EdgeInsets.zero});

  /// Space around it, only taken while it shows.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final active = ref.watch(activeProfileProvider);
    if (profiles.length < 2 || active == null) return const SizedBox.shrink();
    final name = profileName(context.l10n, active);
    final pill = Material(
      color: AppColors.moss,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showProfileSwitcher(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InitialsAvatar(name: name, size: AppSpacing.iconLg),
              AppSpacing.gapSm,
              Flexible(
                child: Text(
                  name,
                  style: AppTextStyles.chip.copyWith(
                    color: AppColors.textOnDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: AppSpacing.iconSm,
                color: AppColors.textOnDark,
              ),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: margin,
      child: Align(alignment: Alignment.centerLeft, child: pill),
    );
  }
}

/// "Whose medicines?": pick a profile, add one, or manage them.
Future<void> showProfileSwitcher(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProfileSwitcher(),
    );

class _ProfileSwitcher extends ConsumerWidget {
  const _ProfileSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final activeId = ref.watch(activeProfileIdProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l10n.profileSwitchTitle),
            AppSpacing.gapLg,
            for (final p in profiles) ...[
              _ProfileRow(
                profile: p,
                selected: p.id == activeId,
                onTap: () {
                  ref.read(activeProfileIdProvider.notifier).select(p.id);
                  Navigator.pop(context);
                },
              ),
              AppSpacing.gapSm,
            ],
            AppSpacing.gapSm,
            PillButton(
              label: l10n.profileAdd,
              tone: PillButtonTone.moss,
              trailingIcon: Icons.person_add_rounded,
              onPressed: () async {
                final id = await addFamilyMember(context, ref);
                if (id == null) return;
                ref.read(activeProfileIdProvider.notifier).select(id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.manage_accounts_rounded),
              label: Text(l10n.profileManage),
              style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfilesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name ("You" under the user's own), and a trailing widget.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  final Profile profile;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = profileName(l10n, profile);
    return Material(
      color: selected ? AppColors.sand : AppColors.creamLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              InitialsAvatar(name: name),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.cardTitleOnLight),
                    if (profile.id == ProfilesRepository.mainProfileId)
                      Text(
                        l10n.profileYou,
                        style: AppTextStyles.captionOnLight,
                      ),
                  ],
                ),
              ),
              ?trailing,
              if (selected && trailing == null)
                Icon(Icons.check_circle_rounded, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProfileAction { rename, delete }

/// Settings › Family profiles: add, rename and delete.
class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    Profile p,
    _ProfileAction action,
  ) async {
    final l10n = context.l10n;
    final repo = ref.read(profilesRepositoryProvider);
    switch (action) {
      case _ProfileAction.rename:
        final name = await showNameSheet(
          context,
          current: p.name,
          label: l10n.profileNameLabel,
          hint: l10n.profileNameHint,
        );
        if (name != null) await repo.rename(p.id, name);
      case _ProfileAction.delete:
        if (!await confirmDelete(
          context,
          title: l10n.profileDelete,
          body: l10n.profileDeleteBody(profileName(l10n, p)),
        )) {
          return;
        }
        if (ref.read(activeProfileIdProvider) == p.id) {
          await ref
              .read(activeProfileIdProvider.notifier)
              .select(ProfilesRepository.mainProfileId);
        }
        await repo.delete(p.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profiles = ref.watch(profilesProvider).value ?? const [];
    return CreamScaffold(
      title: l10n.profilesTitle,
      bottomBar: PillButton(
        label: l10n.profileAdd,
        showRingChevron: true,
        onPressed: () => addFamilyMember(context, ref),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(l10n.profilesHint, style: AppTextStyles.bodyOnLight),
          AppSpacing.gapLg,
          for (final p in profiles) ...[
            _ProfileRow(
              profile: p,
              selected: p.id == ref.watch(activeProfileIdProvider),
              onTap: () {
                ref.read(activeProfileIdProvider.notifier).select(p.id);
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              trailing: PopupMenuButton<_ProfileAction>(
                iconColor: AppColors.ink,
                onSelected: (a) => _onAction(context, ref, p, a),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _ProfileAction.rename,
                    child: Text(l10n.profileRename),
                  ),
                  if (p.id != ProfilesRepository.mainProfileId)
                    PopupMenuItem(
                      value: _ProfileAction.delete,
                      child: Text(l10n.profileDelete),
                    ),
                ],
              ),
            ),
            AppSpacing.gapSm,
          ],
        ],
      ),
    );
  }
}
