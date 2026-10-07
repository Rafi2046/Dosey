import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../domain/family_share.dart';
import '../domain/remote_prescription.dart';
import '../domain/remote_prescription_sync_service.dart';
import '../providers/family_share_providers.dart';
import 'remote_medicine_form_screen.dart';

class RemoteMedicineManageScreen extends ConsumerStatefulWidget {
  const RemoteMedicineManageScreen({
    super.key,
    required this.share,
  });

  final FamilyShare share;

  @override
  ConsumerState<RemoteMedicineManageScreen> createState() =>
      _RemoteMedicineManageScreenState();
}

class _RemoteMedicineManageScreenState
    extends ConsumerState<RemoteMedicineManageScreen> {
  MedicineForm _parseForm(String str) {
    for (final f in MedicineForm.values) {
      if (f.name.toLowerCase() == str.toLowerCase()) return f;
    }
    return MedicineForm.tablet;
  }

  Future<void> _handleDelete(RemotePrescription item, String patientName) async {
    final confirmed = await confirmDelete(
      context,
      body:
          'Are you sure you want to remove "${item.name}" from $patientName\'s phone schedule?',
    );
    if (!confirmed) return;

    try {
      final repo = ref.read(remotePrescriptionRepositoryProvider);
      await repo.deleteRemotePrescription(item.id);
      ref.invalidate(patientRemotePrescriptionsProvider(widget.share.patientUid));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed and synced.'),
            backgroundColor: AppColors.tileMoss,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openAdd(FamilyShare currentShare) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RemoteMedicineFormScreen(share: currentShare),
      ),
    );
    if (result == true) {
      ref.invalidate(patientRemotePrescriptionsProvider(widget.share.patientUid));
    }
  }

  void _openEdit(RemotePrescription item, FamilyShare currentShare) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RemoteMedicineFormScreen(
          share: currentShare,
          existing: item,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(patientRemotePrescriptionsProvider(widget.share.patientUid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final caregiverShares = ref.watch(caregiverSharesProvider).value;
    final currentShare = caregiverShares?.firstWhere(
          (s) =>
              s.patientUid == widget.share.patientUid ||
              s.id == widget.share.id,
          orElse: () => widget.share,
        ) ??
        widget.share;
    final patientName = currentShare.patientName?.trim().isNotEmpty == true
        ? currentShare.patientName!
        : 'Family Member';
    final prescriptionsAsync =
        ref.watch(patientRemotePrescriptionsProvider(widget.share.patientUid));

    return CreamScaffold(
      title: 'Manage $patientName\'s Medicines',
      bottomBar: PillButton(
        label: 'Add Medicine for $patientName',
        trailingIcon: Icons.add_circle_outline_rounded,
        onPressed: () => _openAdd(currentShare),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            patientRemotePrescriptionsProvider(widget.share.patientUid),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xs,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Banner
              SurfaceCard(
                color: AppColors.creamLight,
                elevated: true,
                radius: AppSpacing.radiusLg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    InitialsAvatar(name: patientName, size: AppSpacing.avatarMd),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: AppTextStyles.cardTitleOnLight.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.tileMint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Live Caregiver Sync',
                                style: AppTextStyles.captionOnLight.copyWith(
                                  color: AppColors.inkMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? AppColors.selected.withValues(alpha: 0.16)
                            : AppColors.sand,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                        border: Border.all(
                          color: AppColors.isDark
                              ? AppColors.selected.withValues(alpha: 0.3)
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: AppColors.isDark
                                ? AppColors.selected
                                : AppColors.moss,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '2-Way',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.isDark
                                  ? AppColors.selected
                                  : AppColors.moss,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,

              // Section Header
              prescriptionsAsync.maybeWhen(
                data: (items) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: AppSpacing.headerTickWidth,
                            height: AppSpacing.headerTickHeight,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          AppSpacing.gapSm,
                          Text(
                            'SCHEDULED MEDICINES (${items.length})',
                            style: AppTextStyles.overline.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      if (items.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _openAdd(currentShare),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.isDark
                                ? AppColors.selected
                                : AppColors.moss,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              AppSpacing.gapSm,

              // List of Remote Prescriptions
              prescriptionsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(patientName);
                  }
                  return Column(
                    children: items
                        .map((item) => _buildMedicineCard(item, currentShare))
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, st) => Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.creamLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 32,
                        color: AppColors.error,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'Could not load prescriptions',
                        style: AppTextStyles.bodyOnLight.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Pull down to retry.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String patientName) {
    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Image.asset(AppImages.emptyMedicines, height: 96),
          AppSpacing.gapLg,
          Text(
            'No medicines configured yet',
            style: AppTextStyles.cardTitleOnLight.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          AppSpacing.gapSm,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Add prescriptions for $patientName. Doses and timings will instantly sync to their phone alarms.',
              textAlign: TextAlign.center,
              style: AppTextStyles.captionOnLight.copyWith(
                color: AppColors.inkMuted,
                height: 1.45,
              ),
            ),
          ),
          AppSpacing.gapXl,

          // Clean Feature Highlights
          _buildFeatureTip(
            icon: Icons.alarm_on_rounded,
            color: AppColors.tileMint,
            title: 'Auto-Alarm Sync',
            desc: 'Configures phone alarms on their device automatically',
          ),
          AppSpacing.gapMd,
          _buildFeatureTip(
            icon: Icons.checklist_rounded,
            color: AppColors.accent,
            title: 'Live Adherence',
            desc: 'Monitor when doses are taken, skipped or missed',
          ),
          AppSpacing.gapMd,
          _buildFeatureTip(
            icon: Icons.notifications_active_outlined,
            color: AppColors.tileOlive,
            title: '1-Tap Dose Nudges',
            desc: 'Send gentle reminders directly to their lock screen',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTip({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sand.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  desc,
                  style: AppTextStyles.captionOnLight.copyWith(
                    fontSize: 11.5,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(RemotePrescription item, FamilyShare currentShare) {
    final form = _parseForm(item.form);
    final patientName = currentShare.patientName?.trim().isNotEmpty == true
        ? currentShare.patientName!
        : 'Family Member';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        color: AppColors.creamLight,
        elevated: true,
        radius: AppSpacing.radiusLg,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Image.asset(form.image),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.doseAmount.toStringAsFixed(0)} ${item.form} • ${item.mealRelation}',
                        style: AppTextStyles.captionOnLight.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.isDark ? AppColors.selected : AppColors.moss,
                  tooltip: 'Edit',
                  onPressed: () => _openEdit(item, currentShare),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.error,
                  tooltip: 'Delete',
                  onPressed: () => _handleDelete(item, patientName),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Timings row
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Daily Timings: ',
                  style: AppTextStyles.captionOnLight.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.times.map((t) {
                      final parts = t.split(':');
                      final hour = int.tryParse(parts.first) ?? 9;
                      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
                      final timeStr = AppDateFormat.timeOfDay(TimeOfDay(hour: hour, minute: minute));

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontFamily: 'NDot',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            if (item.stockQuantity != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 15,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stock remaining: ${item.stockQuantity!.toStringAsFixed(0)} units',
                    style: AppTextStyles.captionOnLight,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
