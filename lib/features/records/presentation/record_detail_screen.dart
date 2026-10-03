import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/info_block.dart';
import '../../../core/widgets/pill_button.dart';
import '../../doctors/providers/doctors_providers.dart';
import '../providers/records_providers.dart';
import 'record_form_screen.dart';
import 'widgets/image_source_sheet.dart';
import 'widgets/record_page_viewer.dart';
import '../../../core/localization/l10n.dart';

enum _MenuAction { edit, deletePage, delete }

class RecordDetailScreen extends ConsumerStatefulWidget {
  const RecordDetailScreen({super.key, required this.recordId});

  final int recordId;

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  int _page = 0;

  Future<void> _onMenu(
    _MenuAction action,
    MedicalRecord record,
    List<RecordAttachment> pages,
  ) async {
    final repo = ref.read(recordsRepositoryProvider);
    switch (action) {
      case _MenuAction.edit:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RecordFormScreen(existing: record),
          ),
        );
      case _MenuAction.deletePage:
        if (pages.isEmpty) return;
        if (!await confirmDelete(
          context,
          body: context.l10n.deleteConfirmBody,
        )) {
          return;
        }
        await repo.deletePage(pages[_page.clamp(0, pages.length - 1)]);
        setState(() => _page = 0);
      case _MenuAction.delete:
        if (!await confirmDelete(
          context,
          body: context.l10n.deleteRecordBody,
        )) {
          return;
        }
        if (mounted) Navigator.pop(context);
        await repo.delete(record.id);
    }
  }

  Future<void> _addPages() async {
    final picked = await pickRecordImages(context);
    if (picked.isEmpty) return;
    await ref.read(recordsRepositoryProvider).addPages(widget.recordId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(recordByIdProvider(widget.recordId));
    final pages =
        ref.watch(recordAttachmentsProvider(widget.recordId)).value ?? const [];
    final record = value.value;

    return CreamScaffold(
      title: record?.title ?? context.l10n.records,
      actions: [
        if (record != null)
          PopupMenuButton<_MenuAction>(
            iconColor: AppColors.ink,
            onSelected: (a) => _onMenu(a, record, pages),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.edit,
                child: Text(context.l10n.edit),
              ),
              if (pages.length > 1)
                PopupMenuItem(
                  value: _MenuAction.deletePage,
                  child: Text(context.l10n.deletePage),
                ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text(context.l10n.delete),
              ),
            ],
          ),
      ],
      bottomBar: PillButton(
        label: context.l10n.addPages,
        tone: PillButtonTone.moss,
        trailingIcon: Icons.add_a_photo_rounded,
        onPressed: _addPages,
      ),
      body: AsyncValueView(
        value: value,
        data: (record) => record == null
            ? const SizedBox.shrink()
            : ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  RecordPageViewer(
                    pages: pages,
                    onPageChanged: (i) => _page = i,
                  ),
                  AppSpacing.gapXl,
                  InfoBlock(
                    label: context.l10n.recordType,
                    value: record.type.label(context.l10n),
                  ),
                  InfoBlock(
                    label: context.l10n.recordDate,
                    value: AppDateFormat.date(record.recordDate),
                  ),
                  if (record.doctorId != null)
                    _DoctorBlock(doctorId: record.doctorId!),
                  if (record.notes != null)
                    InfoBlock(
                      label: context.l10n.recordNotes,
                      value: record.notes!,
                    ),
                ],
              ),
      ),
    );
  }
}

class _DoctorBlock extends ConsumerWidget {
  const _DoctorBlock({required this.doctorId});

  final int doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorByIdProvider(doctorId)).value;
    if (doctor == null) return const SizedBox.shrink();
    return InfoBlock(label: context.l10n.recordDoctor, value: doctor.name);
  }
}
