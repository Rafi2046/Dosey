import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../blood_sugar/domain/sugar_category.dart';
import '../../../blood_sugar/presentation/blood_sugar_screen.dart';
import '../../../blood_sugar/presentation/widgets/sugar_category_chip.dart';
import '../../../blood_sugar/presentation/widgets/sugar_value_text.dart';
import '../../../blood_sugar/providers/blood_sugar_providers.dart';

/// Latest blood sugar on Home. Hidden until the first reading.
class BloodSugarSection extends ConsumerWidget {
  const BloodSugarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(bloodSugarReadingsProvider).value?.firstOrNull;
    if (latest == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    void open() => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BloodSugarScreen()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.sugarShortTitle,
          actionLabel: l10n.seeAll,
          onAction: open,
        ),
        SurfaceCard(
          color: AppColors.cream,
          padding: AppSpacing.cardPadding,
          onTap: open,
          child: Row(
            children: [
              const Icon(Icons.bloodtype_rounded, color: AppColors.accent),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SugarText.mmol(latest.mmol),
                      style: AppTextStyles.cardTitleOnLight,
                    ),
                    Text(
                      '${latest.context.label(l10n)}'
                      '${l10n.notifDoseSeparator}'
                      '${AppDateFormat.dateTime(latest.measuredAt)}',
                      style: AppTextStyles.captionOnLight,
                    ),
                  ],
                ),
              ),
              SugarCategoryChip(SugarCategory.of(latest.mmol, latest.context)),
            ],
          ),
        ),
      ],
    );
  }
}
