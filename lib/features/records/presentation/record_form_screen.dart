import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/pickers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../doctors/presentation/widgets/doctor_picker_field.dart';
import '../providers/records_providers.dart';
import 'widgets/image_source_sheet.dart';
import 'widgets/picked_pages_strip.dart';
import '../../../core/localization/l10n.dart';

/// New record with photographed pages, or editing an existing record's
/// details (pages of existing records are managed on the detail screen).
class RecordFormScreen extends ConsumerStatefulWidget {
  const RecordFormScreen({super.key, this.existing, this.initialDoctorId});

  final MedicalRecord? existing;
  final int? initialDoctorId;

  @override
  ConsumerState<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends ConsumerState<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  MedicalRecord? get _r => widget.existing;
  bool get _isEdit => _r != null;

  late final _title = TextEditingController(text: _r?.title);
  late final _notes = TextEditingController(text: _r?.notes);
  late RecordType _type = _r?.type ?? RecordType.prescription;
  late DateTime _date = _r?.recordDate ?? DateTime.now();
  late int? _doctorId = _r?.doctorId ?? widget.initialDoctorId;
  List<String> _pages = const [];
  bool _submitted = false;
  bool _saving = false;

  String? get _pagesError => _submitted && !_isEdit && _pages.isEmpty
      ? context.l10n.addAtLeastOnePage
      : null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addPages() async {
    final picked = await pickRecordImages(context);
    if (picked.isNotEmpty) setState(() => _pages = [..._pages, ...picked]);
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || _pagesError != null) return;
    setState(() => _saving = true);

    final companion = RecordsCompanion(
      type: Value(_type),
      title: Value(_title.text.trim()),
      recordDate: Value(_date),
      doctorId: Value(_doctorId),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    );
    final repo = ref.read(recordsRepositoryProvider);
    _isEdit
        ? await repo.update(_r!.id, companion)
        : await repo.create(companion, _pages);
    if (!mounted) return;
    showAppSnack(context, context.l10n.saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      title: _isEdit ? context.l10n.edit : context.l10n.addRecord,
      bottomBar: PillButton(
        label: _isEdit ? context.l10n.saveChanges : context.l10n.save,
        showCapsuleArrow: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            if (!_isEdit)
              PickedPagesStrip(
                paths: _pages,
                errorText: _pagesError,
                onAdd: _addPages,
                onRemove: (p) =>
                    setState(() => _pages = [..._pages]..remove(p)),
              ),
            AppTextField(
              label: context.l10n.recordTitle,
              controller: _title,
              hint: context.l10n.recordTitleHint,
              validator: AppTextField.required,
            ),
            LabeledField(
              label: context.l10n.recordType,
              child: ChoicePills<RecordType>(
                columns: 3,
                options: RecordType.values,
                selected: {_type},
                labelOf: (t) => t.label(context.l10n),
                iconOf: (t) => t.icon,
                onChanged: (s) => setState(() => _type = s.single),
              ),
            ),
            PickerField(
              label: context.l10n.recordDate,
              value: AppDateFormat.date(_date),
              icon: Icons.event_rounded,
              onTap: () async {
                final d = await AppPickers.date(context, initial: _date);
                if (d != null) setState(() => _date = d);
              },
            ),
            DoctorPickerField(
              label: context.l10n.recordDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            AppTextField(
              label: context.l10n.recordNotes,
              controller: _notes,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
