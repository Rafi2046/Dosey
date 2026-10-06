import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/family_share.dart';
import '../../providers/family_share_providers.dart';
import '../family_member_adherence_screen.dart';

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
    final patientName = share.patientName ?? 'Family Member';

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
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.tileMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'CAREGIVER MONITORING',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.tileMint,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  patientName,
                  style: AppTextStyles.cardTitleOnLight.copyWith(
                    fontSize: 15.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Tap to view today's schedule",
                  style: AppTextStyles.captionOnLight.copyWith(
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StatusChip(
                label: 'Live',
                icon: Icons.sync_rounded,
                background: AppColors.tileMint,
                foreground: Colors.white,
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
