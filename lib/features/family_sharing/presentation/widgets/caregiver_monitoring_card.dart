import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/family_share.dart';
import '../../providers/family_share_providers.dart';
import '../family_member_adherence_screen.dart';
import '../../../../core/localization/l10n.dart';

class CaregiverMonitoringCard extends ConsumerWidget {
  const CaregiverMonitoringCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregiverSharesAsync = ref.watch(caregiverSharesProvider);
    final shares = caregiverSharesAsync.value ?? const [];
    final accepted = shares.where((s) => s.isAccepted).toList();

    if (accepted.isEmpty) return const SizedBox.shrink();

    // Deduplicate by patientUid so each patient only shows one clean card
    final uniqueShares = <String, FamilyShare>{};
    for (final share in accepted) {
      uniqueShares.putIfAbsent(share.patientUid, () => share);
    }
    final patients = uniqueShares.values.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final share in patients) ...[
            _PatientCard(share: share),
            AppSpacing.gapSm,
          ],
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.share});

  final FamilyShare share;

  @override
  Widget build(BuildContext context) {
    final patientName = share.patientName ?? context.l10n.fsFamilyMember;

    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilyMemberAdherenceScreen(share: share),
          ),
        );
      },
      child: Row(
        children: [
          InitialsAvatar(name: patientName, size: 40),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.fsCaregiverMonitoring,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.tileMint,
                        fontWeight: FontWeight.w800,
                        fontSize: AppSpacing.fontXs,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tileMint,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sync_rounded, size: 9, color: Colors.white),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            context.l10n.fsLive,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSpacing.fontXs,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  patientName,
                  style: AppTextStyles.cardTitleOnLight.copyWith(
                    fontSize: AppSpacing.fontMd,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.l10n.fsTapToViewSchedule,
                  style: AppTextStyles.captionOnLight.copyWith(
                    fontSize: AppSpacing.fontXs,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }
}
