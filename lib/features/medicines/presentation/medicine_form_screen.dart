import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/pickers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../doctors/presentation/widgets/doctor_picker_field.dart';
import '../../records/presentation/widgets/prescription_picker_field.dart';
import '../../reminders/domain/reminder_text.dart';
import '../providers/medicines_providers.dart';
import 'widgets/dose_section.dart';
import 'widgets/reminder_times_editor.dart';
import 'widgets/stock_price_section.dart';

/// Step 2 of "Add Medicine", or editing an existing medicine. Reminder times
/// are entered here on create; afterwards they're managed on the detail page.
class MedicineFormScreen extends ConsumerStatefulWidget {
  const MedicineFormScreen({
    super.key,
    this.existing,
    this.initialForm = MedicineForm.tablet,
    this.initialDoctorId,
  });

  final Medicine? existing;
  final MedicineForm initialForm;
  final int? initialDoctorId;

  @override
  ConsumerState<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends ConsumerState<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Medicine? get _m => widget.existing;
  bool get _isEdit => _m != null;

  late MedicineForm _form = _m?.form ?? widget.initialForm;
  late final _name = TextEditingController(text: _m?.name);
  late final _strength = TextEditingController(text: _m?.strength);
  late final _notes = TextEditingController(text: _m?.notes);
  late final _doseAmount = TextEditingController(
    text: ReminderText.formatAmount(_m?.doseAmount ?? 1),
  );
  late final _doseUnit = TextEditingController(
    text: _m?.doseUnit ?? _form.defaultUnit,
  );
  late final _unitPrice = TextEditingController(
    text: (_m?.unitPriceMinor ?? 0) > 0
        ? Money.formatPlain(_m!.unitPriceMinor)
        : null,
  );
  late final _stock = TextEditingController(
    text: _formatOptional(_m?.stockQuantity),
  );
  late final _refillAt = TextEditingController(
    text: _formatOptional(_m?.refillThreshold),
  );

  late MealRelation _meal = _m?.mealRelation ?? MealRelation.afterMeal;
  late int? _doctorId = _m?.doctorId ?? widget.initialDoctorId;
  late int? _prescriptionId = _m?.prescriptionId;
  late DateTime _startDate = _m?.startDate ?? DateTime.now();
  late DateTime? _endDate = _m?.endDate;
  List<TimeOfDay> _times = const [];
  bool _saving = false;

  static String? _formatOptional(double? v) =>
      v == null ? null : ReminderText.formatAmount(v);

  static double? _parseOptional(TextEditingController c) =>
      double.tryParse(c.text.trim());

  @override
  void dispose() {
    for (final c in [
      _name,
      _strength,
      _notes,
      _doseAmount,
      _doseUnit,
      _unitPrice,
      _stock,
      _refillAt,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFormChanged(MedicineForm form) {
    // Keep the unit in sync unless the user typed a custom one.
    if (_doseUnit.text == _form.defaultUnit) _doseUnit.text = form.defaultUnit;
    setState(() => _form = form);
  }

  MedicinesCompanion _companion() => MedicinesCompanion(
    name: Value(_name.text.trim()),
    strength: Value(
      _strength.text.trim().isEmpty ? null : _strength.text.trim(),
    ),
    notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    form: Value(_form),
    doseAmount: Value(double.parse(_doseAmount.text.trim())),
    doseUnit: Value(_doseUnit.text.trim()),
    mealRelation: Value(_meal),
    doctorId: Value(_doctorId),
    prescriptionId: Value(_prescriptionId),
    unitPriceMinor: Value(Money.parse(_unitPrice.text) ?? 0),
    stockQuantity: Value(_parseOptional(_stock)),
    refillThreshold: Value(_parseOptional(_refillAt)),
    startDate: Value(_startDate),
    endDate: Value(_endDate),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    if (_isEdit) {
      await ref.read(medicinesRepositoryProvider).update(_m!.id, _companion());
      if (_endDate != _m!.endDate) {
        await ref
            .read(medicineScheduleServiceProvider)
            .syncEndDate(_m!.id, _endDate);
      }
    } else {
      await ref
          .read(medicineScheduleServiceProvider)
          .createWithTimes(
            _companion(),
            _times,
            startDate: _startDate,
            endDate: _endDate,
          );
    }
    if (!mounted) return;
    showAppSnack(context, AppStrings.saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      title: _isEdit ? AppStrings.editMedicine : AppStrings.addMedicine,
      bottomBar: PillButton(
        label: _isEdit ? AppStrings.saveChanges : AppStrings.save,
        showRingChevron: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            LabeledField(
              label: AppStrings.medicineForm,
              child: ChoicePills<MedicineForm>(
                options: MedicineForm.values,
                selected: {_form},
                labelOf: (f) => f.label,
                onChanged: (s) => _onFormChanged(s.single),
              ),
            ),
            AppTextField(
              label: AppStrings.medicineName,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: AppTextField.required,
            ),
            AppTextField(
              label: AppStrings.medicineStrength,
              controller: _strength,
              hint: AppStrings.optional,
            ),
            AppTextField(
              label: AppStrings.medicineDescription,
              controller: _notes,
              hint: AppStrings.medicineDescriptionHint,
              maxLines: 3,
            ),
            DoseSection(
              amount: _doseAmount,
              unit: _doseUnit,
              meal: _meal,
              onMealChanged: (m) => setState(() => _meal = m),
            ),
            if (!_isEdit)
              ReminderTimesEditor(
                times: _times,
                onChanged: (t) => setState(() => _times = t),
              ),
            DoctorPickerField(
              label: AppStrings.medicineDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            PrescriptionPickerField(
              recordId: _prescriptionId,
              onChanged: (id) => setState(() => _prescriptionId = id),
            ),
            StockPriceSection(
              unitPrice: _unitPrice,
              stock: _stock,
              refillAt: _refillAt,
            ),
            PickerField(
              label: AppStrings.medicineStartDate,
              value: AppDateFormat.date(_startDate),
              icon: Icons.event_rounded,
              onTap: () async {
                final d = await AppPickers.date(context, initial: _startDate);
                if (d != null) setState(() => _startDate = d);
              },
            ),
            PickerField(
              label: AppStrings.medicineEndDate,
              value: _endDate == null ? null : AppDateFormat.date(_endDate!),
              placeholder: AppStrings.ongoing,
              icon: Icons.event_busy_rounded,
              onClear: () => setState(() => _endDate = null),
              onTap: () async {
                final d = await AppPickers.date(context, initial: _endDate);
                if (d != null) setState(() => _endDate = d);
              },
            ),
          ],
        ),
      ),
    );
  }
}
