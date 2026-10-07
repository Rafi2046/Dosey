import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/utils/pickers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../domain/bp_category.dart';
import '../providers/blood_pressure_providers.dart';
import 'widgets/bp_category_chip.dart';

/// Add or edit one reading. Shows its category live as the numbers are
/// typed. Pops after saving or deleting.
class BloodPressureFormScreen extends ConsumerStatefulWidget {
  const BloodPressureFormScreen({super.key, this.existing});

  final BloodPressureReading? existing;

  @override
  ConsumerState<BloodPressureFormScreen> createState() =>
      _BloodPressureFormScreenState();
}

class _BloodPressureFormScreenState
    extends ConsumerState<BloodPressureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final BloodPressureReading? _r = widget.existing;
  late final _systolic = TextEditingController(text: _r?.systolic.toString());
  late final _diastolic = TextEditingController(text: _r?.diastolic.toString());
  late final _pulse = TextEditingController(text: _r?.pulse?.toString());
  late final _note = TextEditingController(text: _r?.note);
  late DateTime _measuredAt = _r?.measuredAt ?? DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_systolic, _diastolic, _pulse, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Whole numbers, at most 3 digits (no reading needs more).
  static final _digits = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(3),
  ];

  FormFieldValidator<String> _range(
    int min,
    int max, {
    bool optional = false,
  }) => (v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty && optional) return null;
    final n = int.tryParse(text);
    return n == null || n < min || n > max
        ? context.l10n.numberRange(AppNumber.format(min), AppNumber.format(max))
        : null;
  };

  String? _validateDiastolic(String? v) {
    final rangeError = _range(BpCategory.diastolicMin, BpCategory.diastolicMax)(
      v,
    );
    if (rangeError != null) return rangeError;
    final sys = int.tryParse(_systolic.text.trim());
    final dia = int.parse(v!.trim());
    return sys != null && dia >= sys ? context.l10n.bpDiastolicHigher : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final note = _note.text.trim();
    final companion = BloodPressureReadingsCompanion(
      systolic: Value(int.parse(_systolic.text.trim())),
      diastolic: Value(int.parse(_diastolic.text.trim())),
      pulse: Value(int.tryParse(_pulse.text.trim())),
      measuredAt: Value(_measuredAt),
      note: Value(note.isEmpty ? null : note),
    );
    final repo = ref.read(bloodPressureRepositoryProvider);
    final r = _r;
    r == null
        ? await repo.create(companion)
        : await repo.update(r.id, companion);
    if (!mounted) return;
    showAppSnack(context, context.l10n.bpSaved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final r = _r!;
    if (!await confirmDelete(context, body: context.l10n.bpDeleteBody)) return;
    await ref.read(bloodPressureRepositoryProvider).delete(r.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CreamScaffold(
      title: _r == null ? l10n.bpAdd : l10n.bpEditTitle,
      actions: [
        if (_r != null)
          IconButton(
            tooltip: l10n.delete,
            onPressed: _delete,
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
      ],
      bottomBar: PillButton(
        label: l10n.save,
        showCapsuleArrow: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.bpSystolic,
                    controller: _systolic,
                    hint: '120',
                    keyboardType: TextInputType.number,
                    inputFormatters: _digits,
                    validator: _range(
                      BpCategory.systolicMin,
                      BpCategory.systolicMax,
                    ),
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: AppTextField(
                    label: l10n.bpDiastolic,
                    controller: _diastolic,
                    hint: '80',
                    keyboardType: TextInputType.number,
                    inputFormatters: _digits,
                    validator: _validateDiastolic,
                  ),
                ),
              ],
            ),
            // The category, live as the numbers are typed.
            ListenableBuilder(
              listenable: Listenable.merge([_systolic, _diastolic]),
              builder: (context, _) {
                final sys = int.tryParse(_systolic.text.trim());
                final dia = int.tryParse(_diastolic.text.trim());
                if (sys == null || dia == null || dia >= sys) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.fieldGap),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BpCategoryChip(BpCategory.of(sys, dia)),
                  ),
                );
              },
            ),
            AppTextField(
              label: l10n.bpPulse,
              controller: _pulse,
              hint: '72',
              keyboardType: TextInputType.number,
              inputFormatters: _digits,
              validator: _range(
                BpCategory.pulseMin,
                BpCategory.pulseMax,
                optional: true,
              ),
            ),
            PickerField(
              label: l10n.bpMeasuredAt,
              value: AppDateFormat.dateTime(_measuredAt),
              icon: Icons.event_rounded,
              onTap: () async {
                final at = await AppPickers.dateTime(
                  context,
                  initial: _measuredAt,
                );
                if (at != null) setState(() => _measuredAt = at);
              },
            ),
            AppTextField(
              label: l10n.bpNote,
              controller: _note,
              hint: l10n.bpNoteHint,
              maxLines: 2,
            ),
            AppSpacing.gapXl,
          ],
        ),
      ),
    );
  }
}
