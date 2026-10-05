import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../blood_pressure/domain/bp_category.dart';
import '../../../blood_pressure/presentation/blood_pressure_screen.dart';
import '../../../blood_pressure/presentation/widgets/bp_category_chip.dart';
import '../../../blood_pressure/providers/blood_pressure_providers.dart';

/// Latest blood pressure reading on Home. Hidden until the first reading
/// (the log is reached from More until then).
class BloodPressureSection extends ConsumerWidget {
  const BloodPressureSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestBloodPressureProvider).value;
    if (latest == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BloodPressureScreen()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.bpShortTitle,
          actionLabel: l10n.seeAll,
          onAction: open,
        ),
        SurfaceCard(
          color: AppColors.cream,
          padding: AppSpacing.cardPadding,
          onTap: open,
          child: Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: AppColors.accent),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.bpValue(AppNumber.format(latest.systolic), AppNumber.format(latest.diastolic))} '
                      '${AppConstants.bpUnit}',
                      style: AppTextStyles.cardTitleOnLight,
                    ),
                    Text(
                      AppDateFormat.dateTime(latest.measuredAt),
                      style: AppTextStyles.captionOnLight,
                    ),
                  ],
                ),
              ),
              BpCategoryChip(BpCategory.of(latest.systolic, latest.diastolic)),
            ],
          ),
        ),
      ],
    );
  }
}
