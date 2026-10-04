import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
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
import '../../../core/widgets/switch_row.dart';
import '../../doctors/presentation/widgets/doctor_picker_field.dart';
import '../../doctors/providers/doctors_providers.dart';
import '../../records/presentation/widgets/prescription_picker_field.dart';
import '../../reminders/domain/reminder_text.dart';
import '../domain/course_progress.dart';
import '../domain/dose_time.dart';
import '../domain/scanned_medicine.dart';
import '../providers/medicines_providers.dart';
import 'bulk/bulk_add_screen.dart';
import 'scan_prescription_flow.dart';
import 'widgets/dose_section.dart';
import 'widgets/reminder_times_editor.dart';
import 'widgets/scan_prescription_card.dart';
import 'widgets/stock_price_section.dart';
import '../../../core/utils/dose_unit.dart';

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
  late final _doseUnit = TextEditingController(
    text: switch (_m) {
      final m? => DoseUnit.display(m.doseUnit, context.l10n),
      null => _form.defaultUnit(context.l10n),
    },
  );
  late final _unitPrice = TextEditingController(
    text: (_m?.unitPriceMinor ?? 0) > 0
        ? Money.formatPlain(_m!.unitPriceMinor)
        : null,
  );
  late final _stock = TextEditingController(
    text: _formatOptional(_m?.stockQuantity),
  );
  late final _unitsPerStrip = TextEditingController(
    text: _m?.unitsPerStrip?.toString(),
  );
  late final _stripsPerBox = TextEditingController(
    text: _m?.stripsPerBox?.toString(),
  );
  late int _alertDays =
      _m?.refillAlertDays ?? AppConstants.defaultRefillAlertDays;

  late MealRelation _meal = _m?.mealRelation ?? MealRelation.afterMeal;
  late int? _doctorId = _m?.doctorId ?? widget.initialDoctorId;
  late int? _prescriptionId = _m?.prescriptionId;
  late DateTime _startDate = _m?.startDate ?? DateTime.now();
  late DateTime? _endDate = _m?.endDate;
  List<DoseTime> _doses = const [];
  bool _saving = false;
  bool _scanning = false;
  bool _ringAsAlarm = true;

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
      _doseUnit,
      _unitPrice,
      _stock,
      _unitsPerStrip,
      _stripsPerBox,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFormChanged(MedicineForm form) {
    // Keep the unit in sync unless the user typed a custom one.
    final l10n = context.l10n;
    if (_doseUnit.text == _form.defaultUnit(l10n)) {
      _doseUnit.text = form.defaultUnit(l10n);
    }
    setState(() => _form = form);
  }

  /// Photo → OCR → suggestions. The chosen one only pre-fills the fields;
  /// nothing is saved until the user reviews and taps Save.
  Future<void> _scan() async {
    final found = await scanPrescription(
      context,
      ProviderScope.containerOf(context),
      onBusy: (busy) {
        if (mounted) setState(() => _scanning = busy);
      },
    );
    if (found == null || !mounted) return;
    final doctor = found.doctor;
    final savedDoctor = doctor == null
        ? null
        : matchSavedDoctor(
            await ref.read(doctorsRepositoryProvider).all(),
            doctor,
          );
    if (!mounted) return;
    // One medicine and no new doctor to save: fill this form directly.
    if (found.medicines.length == 1 &&
        (doctor == null || savedDoctor != null)) {
      _applyScan(found.medicines.single);
      if (savedDoctor != null) setState(() => _doctorId = savedDoctor.id);
      return showAppSnack(context, context.l10n.scanFilled);
    }
    // Several medicines (or a new doctor): review and save them together.
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BulkAddScreen(
          scanned: found.medicines,
          doctor: doctor,
          initialDoctorId: _doctorId,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.pop(context, true);
  }

  void _applyScan(ScannedMedicine s) {
    if (s.form case final form?) _onFormChanged(form);
    _name.text = s.name;
    if (s.strength case final v?) _strength.text = v;
    setState(() {
      if (s.meal case final m?) _meal = m;
      if (s.doses.isNotEmpty) _doses = s.doses;
      // An N-day course ends on its Nth day.
      if (s.durationDays case final d?) {
        _endDate = CourseLength.endDate(_startDate, d);
      }
    });
  }

  /// The course-duration pill matching the current dates.
  int get _courseOption {
    final end = _endDate;
    if (end == null) return CourseLength.ongoing;
    final days = CourseLength.days(_startDate, end);
    return CourseLength.presets.contains(days) ? days : CourseLength.custom;
  }

  String _courseLabel(int option) => switch (option) {
    CourseLength.ongoing => context.l10n.ongoing,
    CourseLength.custom => context.l10n.courseCustom,
    CourseLength.month => context.l10n.courseMonth,
    final days => context.l10n.daysCount(days),
  };

  /// A preset sets the end date from the start date; Custom asks for one.
  Future<void> _onCourseChanged(int option) async {
    if (option == CourseLength.custom) return _pickEndDate();
    setState(
      () => _endDate = option == CourseLength.ongoing
          ? null
          : CourseLength.endDate(_startDate, option),
    );
  }

  Future<void> _pickEndDate() async {
    final d = await AppPickers.date(context, initial: _endDate ?? _startDate);
    if (d != null) setState(() => _endDate = d);
  }

  /// Moving the start keeps the course length (a 7-day course stays 7 days).
  Future<void> _pickStartDate() async {
    final d = await AppPickers.date(context, initial: _startDate);
    if (d == null) return;
    setState(() {
      if (_endDate case final end?) {
        _endDate = CourseLength.endDate(d, CourseLength.days(_startDate, end));
      }
      _startDate = d;
    });
  }

  MedicinesCompanion _companion() => MedicinesCompanion(
    name: Value(_name.text.trim()),
    strength: Value(
      _strength.text.trim().isEmpty ? null : _strength.text.trim(),
    ),
    notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    form: Value(_form),
    doseUnit: Value(DoseUnit.toStored(_doseUnit.text)),
    mealRelation: Value(_meal),
    doctorId: Value(_doctorId),
    prescriptionId: Value(_prescriptionId),
    unitPriceMinor: Value(Money.parse(_unitPrice.text) ?? 0),
    stockQuantity: Value(_parseOptional(_stock)),
    unitsPerStrip: Value(int.tryParse(_unitsPerStrip.text.trim())),
    stripsPerBox: Value(int.tryParse(_stripsPerBox.text.trim())),
    // Days-based alert replaces the old unit threshold once saved.
    refillAlertDays: Value(_parseOptional(_stock) == null ? null : _alertDays),
    refillThreshold: const Value(null),
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
            _doses,
            startDate: _startDate,
            endDate: _endDate,
            critical: _ringAsAlarm,
          );
    }
    if (!mounted) return;
    showAppSnack(context, context.l10n.saved);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      title: _isEdit ? context.l10n.editMedicine : context.l10n.addMedicine,
      bottomBar: PillButton(
        label: _isEdit ? context.l10n.saveChanges : context.l10n.save,
        showRingChevron: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            if (!_isEdit)
              ScanPrescriptionCard(scanning: _scanning, onTap: _scan),
            LabeledField(
              label: context.l10n.medicineForm,
              child: ChoicePills<MedicineForm>(
                columns: 4,
                options: MedicineForm.values,
                selected: {_form},
                labelOf: (f) => f.label(context.l10n),
                onChanged: (s) => _onFormChanged(s.single),
              ),
            ),
            AppTextField(
              label: context.l10n.medicineName,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: AppTextField.required,
            ),
            AppTextField(
              label: context.l10n.medicineStrength,
              controller: _strength,
              hint: context.l10n.optional,
            ),
            DoseSection(
              unit: _doseUnit,
              meal: _meal,
              onMealChanged: (m) => setState(() => _meal = m),
            ),
            if (!_isEdit)
              // Rebuild on unit edits so chips read "2 tablet" → "2 ml".
              ListenableBuilder(
                listenable: _doseUnit,
                builder: (context, _) => ReminderTimesEditor(
                  doses: _doses,
                  unit: _doseUnit.text.trim(),
                  onChanged: (d) => setState(() => _doses = d),
                ),
              ),
            if (!_isEdit)
              SwitchRow(
                title: context.l10n.ringAsAlarm,
                subtitle: context.l10n.ringAsAlarmHint,
                value: _ringAsAlarm,
                onChanged: (v) => setState(() => _ringAsAlarm = v),
              ),
            AppTextField(
              label: context.l10n.medicineDescription,
              controller: _notes,
              hint: context.l10n.medicineDescriptionHint,
              maxLines: 3,
            ),
            DoctorPickerField(
              label: context.l10n.medicineDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            PrescriptionPickerField(
              recordId: _prescriptionId,
              onChanged: (id) => setState(() => _prescriptionId = id),
            ),
            ListenableBuilder(
              listenable: _doseUnit,
              builder: (context, _) => StockPriceSection(
                unitPrice: _unitPrice,
                stock: _stock,
                unitsPerStrip: _unitsPerStrip,
                stripsPerBox: _stripsPerBox,
                alertDays: _alertDays,
                onAlertDaysChanged: (d) => setState(() => _alertDays = d),
                unit: _doseUnit.text.trim(),
                unitsPerDay: _isEdit
                    ? ref.watch(unitsPerDayProvider)[_m!.id] ?? 0
                    : _doses.fold(0.0, (sum, d) => sum + d.amount),
                showPacks:
                    _form == MedicineForm.tablet ||
                    _form == MedicineForm.capsule,
              ),
            ),
            PickerField(
              label: context.l10n.medicineStartDate,
              value: AppDateFormat.date(_startDate),
              icon: Icons.event_rounded,
              onTap: _pickStartDate,
            ),
            LabeledField(
              label: context.l10n.courseDuration,
              child: ChoicePills<int>(
                columns: 4,
                options: const [
                  ...CourseLength.presets,
                  CourseLength.ongoing,
                  CourseLength.custom,
                ],
                selected: {_courseOption},
                labelOf: _courseLabel,
                onChanged: (s) => _onCourseChanged(s.single),
              ),
            ),
            // Follows the duration above; picking a date here is "Custom".
            PickerField(
              label: context.l10n.medicineEndDate,
              value: _endDate == null ? null : AppDateFormat.date(_endDate!),
              placeholder: context.l10n.ongoing,
              icon: Icons.event_busy_rounded,
              onClear: () => setState(() => _endDate = null),
              onTap: _pickEndDate,
            ),
          ],
        ),
      ),
    );
  }
}
