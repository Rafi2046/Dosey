import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_pills.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../domain/record_summary.dart';
import '../providers/records_providers.dart';
import 'record_detail_screen.dart';
import 'record_form_screen.dart';
import 'widgets/record_card.dart';
import '../../../core/localization/l10n.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(recordTypeFilterProvider);
    final records = ref.watch(recordSummariesProvider);
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600 || screenSize.width >= 600;
    final cols = isTablet ? 3 : 2;

    return TabScrollView(
      // Nothing to list: centre the empty state in the space left.
      centerLast: records.value?.isEmpty ?? false,
      onRefresh: () async {
        ref.invalidate(recordSummariesProvider);
      },
      children: [
        ScreenHeader(
          title: context.l10n.recordsTitle,
          subtitle: switch (records.value) {
            final list? => context.l10n.headerRecordsCount(list.length),
            null => null,
          },
        ),
        FilterPills<RecordType>(
          options: RecordType.values,
          selected: filter,
          labelOf: (t) => t.label(context.l10n),
          onSelected: ref.read(recordTypeFilterProvider.notifier).select,
        ),
        AppSpacing.gapLg,
        AsyncValueView(
          value: records,
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.l10n.noRecords,
                  image: AppImages.emptyRecords,
                  actionLabel: context.l10n.addRecord,
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RecordFormScreen(),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < list.length; i += cols) ...[
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var c = 0; c < cols; c++) ...[
                              if (c > 0) AppSpacing.gapMd,
                              Expanded(
                                child: (i + c) < list.length
                                    ? _tile(context, list, i + c)
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
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

  Widget _tile(BuildContext context, List<RecordSummary> list, int i) =>
      RecordCard(
        summary: list[i],
        color: AppColors.cardCycle[i % AppColors.cardCycle.length],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RecordDetailScreen(recordId: list[i].record.id),
          ),
        ),
      );
}
