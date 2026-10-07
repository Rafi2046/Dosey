import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../../expenses/providers/expenses_providers.dart';
import '../providers/medicines_providers.dart';
import 'medicine_detail_screen.dart';
import 'medicine_type_screen.dart';
import 'widgets/medicine_card.dart';
import '../../../core/localization/l10n.dart';
import '../../profiles/presentation/profile_widgets.dart';

class MedicinesScreen extends ConsumerWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showStopped = ref.watch(showStoppedMedicinesProvider);
    final medicines = ref.watch(medicinesProvider);
    final monthlyById = {
      for (final line
          in ref.watch(medicineCostProjectionProvider).value?.lines ?? const [])
        line.medicine.id: line.monthlyMinor,
    };

    return TabScrollView(
      // Nothing to list: centre the empty state in the space left.
      centerLast:
          medicines.value?.every((m) => m.medicine.isActive == showStopped) ??
          false,
      onRefresh: () async {
        ref.invalidate(medicinesProvider);
        ref.invalidate(medicineCostProjectionProvider);
      },
      children: [
        ScreenHeader(
          // Whose list this is (only shown with family profiles).
          trailing: const ProfilePill(),
          title: context.l10n.medicinesTitle,
          subtitle: switch (medicines.value) {
            // Empty: the empty state below already says so.
            final list? when list.isNotEmpty =>
              context.l10n.headerMedicinesCount(list.length),
            _ => null,
          },
        ),
        ChoicePills<bool>(
          options: const [false, true],
          onDark: true,
          selected: {showStopped},
          labelOf: (stopped) =>
              stopped ? context.l10n.stopped : context.l10n.active,
          onChanged: (s) =>
              ref.read(showStoppedMedicinesProvider.notifier).set(s.single),
        ),
        AppSpacing.gapLg,
        AsyncValueView(
          value: medicines,
          data: (all) {
            final list = all
                .where((m) => m.medicine.isActive != showStopped)
                .toList();
            if (list.isEmpty) {
              return EmptyState(
                title: context.l10n.noMedicines,
                image: AppImages.emptyMedicines,
                actionLabel: showStopped ? null : context.l10n.addMedicine,
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MedicineTypeScreen(),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final (i, item) in list.indexed) ...[
                  MedicineCard(
                    item: item,
                    color: AppColors.cardCycle[i % AppColors.cardCycle.length],
                    monthlyCostMinor: monthlyById[item.medicine.id],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            MedicineDetailScreen(medicineId: item.medicine.id),
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
