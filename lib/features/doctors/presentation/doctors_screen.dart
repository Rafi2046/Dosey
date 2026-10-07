import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../providers/doctors_providers.dart';
import 'doctor_detail_screen.dart';
import 'doctor_form_screen.dart';
import 'widgets/doctor_card.dart';
import '../../../core/localization/l10n.dart';

class DoctorsScreen extends ConsumerWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsWithStatsProvider);

    return TabScrollView(
      // Nothing to list: centre the empty state in the space left.
      centerLast: doctors.value?.isEmpty ?? false,
      onRefresh: () async {
        ref.invalidate(doctorsWithStatsProvider);
      },
      children: [
        ScreenHeader(
          title: context.l10n.doctorsTitle,
          subtitle: switch (doctors.value) {
            final list? => context.l10n.headerDoctorsCount(list.length),
            null => null,
          },
        ),
        AsyncValueView(
          value: doctors,
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.l10n.noDoctors,
                  image: AppImages.emptyDoctors,
                  actionLabel: context.l10n.addDoctor,
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorFormScreen(),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final (i, item) in list.indexed) ...[
                      DoctorCard(
                        item: item,
                        color:
                            AppColors.cardCycle[i % AppColors.cardCycle.length],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                DoctorDetailScreen(doctorId: item.doctor.id),
                          ),
                        ),
                      ),
                      AppSpacing.gapMd,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
