import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../providers/family_share_providers.dart';
import '../family_member_adherence_screen.dart';

class CaregiverMonitoringCard extends ConsumerWidget {
  const CaregiverMonitoringCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregiverSharesAsync = ref.watch(caregiverSharesProvider);

    return caregiverSharesAsync.when(
      data: (shares) {
        final accepted = shares.where((s) => s.isAccepted).toList();
        if (accepted.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...accepted.map((share) {
              final patientName = share.patientName ?? 'Family Member';
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.tileMint.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: AppColors.isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              FamilyMemberAdherenceScreen(share: share),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          InitialsAvatar(name: patientName, size: 44),
                          AppSpacing.gapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'CAREGIVER MONITORING',
                                      style: AppTextStyles.overline.copyWith(
                                        color: AppColors.tileMint,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSpacing.fontXs,
                                      ),
                                    ),
                                    AppSpacing.gapXs,
                                    const StatusChip(
                                      label: 'Live',
                                      icon: Icons.wifi_tethering_rounded,
                                      background: AppColors.tileMint,
                                      foreground: Colors.white,
                                    ),
                                  ],
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  patientName,
                                  style: AppTextStyles.headlineOnLight.copyWith(
                                    fontSize: AppSpacing.fontMd,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Tap to view today's dose schedule & adherence",
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.inkMuted,
                                    fontSize: AppSpacing.fontXs,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.inkMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
