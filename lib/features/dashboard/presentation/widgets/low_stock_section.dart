import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../medicines/presentation/medicine_detail_screen.dart';
import '../../../medicines/providers/medicines_providers.dart';
import '../../../reminders/domain/reminder_text.dart';

/// Medicines at or below their refill threshold. Hidden when none.
class LowStockSection extends ConsumerWidget {
  const LowStockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(lowStockMedicinesProvider).value ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: DashboardStrings.runningLow),
        for (final item in items) ...[
          SurfaceCard(
            color: AppColors.cream,
            padding: AppSpacing.cardPadding,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    MedicineDetailScreen(medicineId: item.medicine.id),
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
                    item.medicine.name,
                    style: AppTextStyles.cardTitleOnLight,
                  ),
                ),
                StatusChip(
                  label: DashboardStrings.unitsLeft(
                    ReminderText.formatAmount(item.medicine.stockQuantity!),
                  ),
                  background: AppColors.accent,
                  foreground: AppColors.textOnAccent,
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
        ],
      ],
    );
  }
}
