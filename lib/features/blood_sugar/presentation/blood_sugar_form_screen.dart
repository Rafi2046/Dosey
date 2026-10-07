import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/utils/pickers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../domain/sugar_category.dart';
import '../providers/blood_sugar_providers.dart';
import 'widgets/sugar_category_chip.dart';
import 'widgets/sugar_value_text.dart';

/// Add or edit one reading. Its category (which depends on when it was
/// taken) shows live while typing. Pops after saving or deleting.
class BloodSugarFormScreen extends ConsumerStatefulWidget {
  const BloodSugarFormScreen({super.key, this.existing});

  final BloodSugarReading? existing;

  @override
  ConsumerState<BloodSugarFormScreen> createState() =>
      _BloodSugarFormScreenState();
}

class _BloodSugarFormScreenState extends ConsumerState<BloodSugarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final BloodSugarReading? _r = widget.existing;
  late final _value = TextEditingController(text: _r?.mmol.toString());
  late final _note = TextEditingController(text: _r?.note);
  late SugarContext _context = _r?.context ?? _guessContext(DateTime.now());
  late DateTime _measuredAt = _r?.measuredAt ?? DateTime.now();
  bool _saving = false;

  /// Early morning is usually a fasting check.
  static SugarContext _guessContext(DateTime now) =>
      now.hour >= 4 && now.hour < 9
      ? SugarContext.fasting
      : SugarContext.random;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  double? get _mmol => double.tryParse(_value.text.trim());

  String? _validate(String? v) {
    final n = double.tryParse(v?.trim() ?? '');
    return n == null || n < SugarCategory.mmolMin || n > SugarCategory.mmolMax
        ? context.l10n.decimalRange(
            AppNumber.format(SugarCategory.mmolMin),
            AppNumber.format(SugarCategory.mmolMax),
          )
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final note = _note.text.trim();
    final companion = BloodSugarReadingsCompanion(
      mmol: Value((_mmol! * 10).round() / 10),
      context: Value(_context),
      measuredAt: Value(_measuredAt),
      note: Value(note.isEmpty ? null : note),
    );
    final repo = ref.read(bloodSugarRepositoryProvider);
    final r = _r;
    r == null
        ? await repo.create(companion)
        : await repo.update(r.id, companion);
    if (!mounted) return;
    showAppSnack(context, context.l10n.sugarSaved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final r = _r!;
    if (!await confirmDelete(context, body: context.l10n.sugarDeleteBody)) {
      return;
    }
    await ref.read(bloodSugarRepositoryProvider).delete(r.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CreamScaffold(
      title: _r == null ? l10n.sugarAdd : l10n.sugarEditTitle,
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
        showForwardArrow: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            AppTextField.decimal(
              label: l10n.sugarValueLabel,
              controller: _value,
              hint: '6.5',
              validator: _validate,
            ),
            // Category and mg/dL, live as the value or timing changes.
            ListenableBuilder(
              listenable: _value,
              builder: (context, _) {
                final v = _mmol;
                if (v == null ||
                    v < SugarCategory.mmolMin ||
                    v > SugarCategory.mmolMax) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.fieldGap),
                  child: Row(
                    children: [
                      SugarCategoryChip(SugarCategory.of(v, _context)),
                      AppSpacing.gapMd,
                      Text(
                        SugarText.mgDl(l10n, v),
                        style: AppTextStyles.captionOnLight,
                      ),
                    ],
                  ),
                );
              },
            ),
            LabeledField(
              label: l10n.sugarWhen,
              child: ChoicePills<SugarContext>(
                columns: 2,
                options: SugarContext.values,
                selected: {_context},
                labelOf: (c) => c.label(l10n),
                onChanged: (s) => setState(() => _context = s.single),
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
              hint: l10n.sugarNoteHint,
              maxLines: 2,
            ),
            AppSpacing.gapXl,
          ],
        ),
      ),
    );
  }
}
