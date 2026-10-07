import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/pickers.dart';
import '../../../core/widgets/amount_stepper.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/switch_row.dart';
import '../../doctors/presentation/widgets/doctor_picker_field.dart';
import '../../medicines/presentation/widgets/medicine_picker_field.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../providers/reminders_providers.dart';
import 'widgets/repeat_section.dart';
import 'widgets/reminder_type_selector.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/dose_unit.dart';

/// Create or edit any reminder (medicine, appointment, vaccine, test).
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({
    super.key,
    this.existing,
    this.initialType = ReminderType.medicine,
    this.initialMedicineId,
    this.initialDoctorId,
  });

  final Reminder? existing;
  final ReminderType initialType;
  final int? initialMedicineId;
  final int? initialDoctorId;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _notes = TextEditingController(text: widget.existing?.description);
  late final _location = TextEditingController(text: widget.existing?.location);

  late ReminderType _type = widget.existing?.type ?? widget.initialType;
  late int? _medicineId =
      widget.existing?.medicineId ?? widget.initialMedicineId;
  late int? _doctorId = widget.existing?.doctorId ?? widget.initialDoctorId;
  late DateTime _startAt = widget.existing?.startAt ?? _defaultStart();
  late RepeatRule _repeat =
      widget.existing?.repeatRule ??
      (_type == ReminderType.medicine ? RepeatRule.daily : RepeatRule.once);
  late Set<int> _weekdays = _maskToSet(widget.existing?.weekdaysMask);
  late int _interval = widget.existing?.repeatInterval ?? 1;
  late DateTime? _endAt = widget.existing?.endAt;
  late bool _critical = widget.existing?.isCritical ?? true;
  late double _doseAmount = widget.existing?.doseAmount ?? 1;
  late int _snooze =
      widget.existing?.snoozeMinutes ?? AppConstants.defaultSnoozeMinutes;

  /// Heads-up lead time in minutes, 0 = none. New appointments default to
  /// a day before, which is what most people want.
  late int _headsUp = _isEdit
      ? widget.existing!.remindBeforeMinutes ?? 0
      : AppConstants.headsUpOptions.last.inMinutes;

  bool _saving = false;
  bool _submitted = false;

  bool get _isEdit => widget.existing != null;

  static DateTime _defaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  static Set<int> _maskToSet(int? mask) => {
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      if ((mask ?? 0) & (1 << i) != 0) i,
  };

  int get _mask => _weekdays.fold(0, (m, i) => m | (1 << i));

  String? get _medicineError =>
      _submitted && _type == ReminderType.medicine && _medicineId == null
      ? context.l10n.selectMedicineError
      : null;

  String? get _weekdayError =>
      _submitted && _repeat == RepeatRule.weekly && _weekdays.isEmpty
      ? context.l10n.selectWeekdaysError
      : null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _location.dispose();
    super.dispose();
  }

  /// Unit of the chosen medicine ("tablet", "ml"), for the amount stepper.
  String? get _selectedUnit =>
      switch ((ref.watch(medicinesProvider).value ?? const [])
          .where((m) => m.medicine.id == _medicineId)
          .firstOrNull) {
        final m? => DoseUnit.display(
          m.medicine.doseUnit,
          context.l10n,
          amount: _doseAmount,
        ),
        null => null,
      };

  void _onMedicineChanged(int? id) {
    setState(() => _medicineId = id);
    // Default the title to the medicine's name.
    final medicines = ref.read(medicinesProvider).value ?? const [];
    final match = medicines.where((m) => m.medicine.id == id).firstOrNull;
    if (match != null && _title.text.trim().isEmpty) {
      _title.text = match.medicine.name;
    }
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final valid = _formKey.currentState!.validate();
    if (!valid || _medicineError != null || _weekdayError != null) return;

    setState(() => _saving = true);
    final companion = RemindersCompanion(
      type: Value(_type),
      title: Value(_title.text.trim()),
      description: Value(_textOrNull(_notes)),
      location: Value(
        _type == ReminderType.medicine ? null : _textOrNull(_location),
      ),
      medicineId: Value(_type == ReminderType.medicine ? _medicineId : null),
      doseAmount: Value(_type == ReminderType.medicine ? _doseAmount : null),
      doctorId: Value(_doctorId),
      startAt: Value(_startAt),
      repeatRule: Value(_repeat),
      weekdaysMask: Value(_repeat == RepeatRule.weekly ? _mask : null),
      repeatInterval: Value(
        _repeat == RepeatRule.everyNDays ? _interval : null,
      ),
      endAt: Value(_repeat == RepeatRule.once ? null : _endAt),
      isCritical: Value(_critical),
      snoozeMinutes: Value(_snooze),
      remindBeforeMinutes: Value(
        _type == ReminderType.medicine || _headsUp == 0 ? null : _headsUp,
      ),
    );

    final repo = ref.read(remindersRepositoryProvider);
    if (_isEdit) {
      await repo.update(widget.existing!.id, companion);
    } else {
      await repo.create(companion);
    }
    if (!mounted) return;
    showAppSnack(context, context.l10n.saved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context, body: context.l10n.deleteReminderBody)) {
      return;
    }
    await ref.read(remindersRepositoryProvider).delete(widget.existing!.id);
    if (mounted) Navigator.pop(context);
  }

  static String? _textOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final isMedicine = _type == ReminderType.medicine;
    return CreamScaffold(
      title: _isEdit ? context.l10n.editReminder : context.l10n.addReminder,
      actions: [
        if (_isEdit)
          IconButton(
            tooltip: context.l10n.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.inkMuted,
            onPressed: _delete,
          ),
      ],
      bottomBar: PillButton(
        label: _isEdit ? context.l10n.saveChanges : context.l10n.save,
        trailingIcon: Icons.check_rounded,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            ReminderTypeSelector(
              value: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            if (isMedicine)
              MedicinePickerField(
                label: context.l10n.reminderMedicine,
                medicineId: _medicineId,
                allowNone: false,
                errorText: _medicineError,
                onChanged: _onMedicineChanged,
              ),
            if (isMedicine)
              LabeledField(
                label: context.l10n.doseHowMany,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AmountStepper(
                    value: _doseAmount,
                    suffix: _selectedUnit,
                    onChanged: (v) => setState(() => _doseAmount = v),
                  ),
                ),
              ),
            AppTextField(
              label: context.l10n.reminderTitle,
              controller: _title,
              hint: context.l10n.reminderTitleHint,
              validator: AppTextField.required,
            ),
            PickerField(
              label: context.l10n.reminderWhen,
              value: AppDateFormat.dateTime(_startAt),
              icon: Icons.schedule_rounded,
              onTap: () async {
                final picked = await AppPickers.dateTime(
                  context,
                  initial: _startAt,
                );
                if (picked != null) setState(() => _startAt = picked);
              },
            ),
            if (!isMedicine)
              LabeledField(
                label: context.l10n.headsUpLabel,
                child: ChoicePills<int>(
                  columns: 2,
                  options: [
                    0,
                    for (final d in AppConstants.headsUpOptions) d.inMinutes,
                  ],
                  selected: {_headsUp},
                  labelOf: (m) => m == 0
                      ? context.l10n.headsUpNone
                      : context.l10n.headsUpBefore(
                          m % Duration.minutesPerDay == 0
                              ? context.l10n.daysCount(
                                  m ~/ Duration.minutesPerDay,
                                )
                              : context.l10n.inHoursMinutes(
                                  m ~/ Duration.minutesPerHour,
                                  m % Duration.minutesPerHour,
                                ),
                        ),
                  onChanged: (s) => setState(() => _headsUp = s.single),
                ),
              ),
            RepeatSection(
              rule: _repeat,
              weekdays: _weekdays,
              interval: _interval,
              endAt: _endAt,
              weekdaysError: _weekdayError,
              onRuleChanged: (r) => setState(() => _repeat = r),
              onWeekdaysChanged: (w) => setState(() => _weekdays = w),
              onIntervalChanged: (n) => setState(() => _interval = n),
              onEndChanged: (d) => setState(() => _endAt = d),
            ),
            DoctorPickerField(
              label: context.l10n.reminderDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            if (!isMedicine)
              AppTextField(
                label: context.l10n.reminderLocation,
                controller: _location,
              ),
            AppTextField(
              label: context.l10n.reminderNotes,
              controller: _notes,
              maxLines: 3,
            ),
            SwitchRow(
              title: context.l10n.reminderCritical,
              subtitle: context.l10n.reminderCriticalHint,
              value: _critical,
              onChanged: (v) => setState(() => _critical = v),
            ),
            LabeledField(
              label: context.l10n.reminderSnooze,
              child: ChoicePills<int>(
                columns: 4,
                options: AppConstants.snoozeOptions,
                selected: {_snooze},
                labelOf: (m) =>
                    '${AppNumber.format(m)} ${context.l10n.minutesShort}',
                onChanged: (s) => setState(() => _snooze = s.single),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
