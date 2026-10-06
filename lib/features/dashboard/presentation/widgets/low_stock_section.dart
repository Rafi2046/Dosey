import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../medicines/domain/stock_status.dart';
import '../../../medicines/presentation/medicine_detail_screen.dart';
import '../../../medicines/providers/medicines_providers.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';

/// Medicines at or below their refill threshold. Hidden when none.
class LowStockSection extends ConsumerWidget {
  const LowStockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Computed here rather than in a derived provider, which Riverpod can
    // invalidate mid-build after a pull-to-refresh.
    final units = ref.watch(unitsPerDayProvider);
    final items = [
      for (final m in ref.watch(activeMedicinesProvider).value ?? const [])
        if (StockStatus(m.medicine, units[m.medicine.id] ?? 0).isLow) m,
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: context.l10n.runningLow),
        for (int i = 0; i < items.length; i++) ...[
          SurfaceCard(
            color: AppColors.cream,
            padding: AppSpacing.cardPadding,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    MedicineDetailScreen(medicineId: items[i].medicine.id),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accent,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Text(
                    items[i].medicine.name,
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                ),
                StatusChip(
                  label: switch (ref
                      .watch(stockStatusProvider(items[i].medicine))
                      .daysLeft) {
                    final d? => context.l10n.daysLeft(d),
                    null => context.l10n.unitsLeft(
                      AppNumber.format(items[i].medicine.stockQuantity!),
                    ),
                  },
                  background: AppColors.accent,
                  foreground: AppColors.textOnAccent,
                ),
              ],
            ),
          ),
          if (i < items.length - 1) AppSpacing.gapSm,
        ],
      ],
    );
  }
}
