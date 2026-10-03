import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
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
import '../../medicines/presentation/widgets/medicine_picker_field.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../providers/reminders_providers.dart';
import 'widgets/repeat_section.dart';
import 'widgets/reminder_type_selector.dart';

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
  late int _snooze =
      widget.existing?.snoozeMinutes ?? AppConstants.defaultSnoozeMinutes;

  bool _saving = false;
  bool _submitted = false;

  bool get _isEdit => widget.existing != null;

  static DateTime _defaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  static Set<int> _maskToSet(int? mask) => {
    for (var i = 0; i < ReminderStrings.weekdaysShort.length; i++)
      if ((mask ?? 0) & (1 << i) != 0) i,
  };

  int get _mask => _weekdays.fold(0, (m, i) => m | (1 << i));

  String? get _medicineError =>
      _submitted && _type == ReminderType.medicine && _medicineId == null
      ? ReminderStrings.selectMedicineError
      : null;

  String? get _weekdayError =>
      _submitted && _repeat == RepeatRule.weekly && _weekdays.isEmpty
      ? ReminderStrings.selectWeekdaysError
      : null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _location.dispose();
    super.dispose();
  }

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
    );

    final repo = ref.read(remindersRepositoryProvider);
    if (_isEdit) {
      await repo.update(widget.existing!.id, companion);
    } else {
      await repo.create(companion);
    }
    if (!mounted) return;
    showAppSnack(context, AppStrings.saved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!await confirmDelete(
      context,
      body: ReminderStrings.deleteReminderBody,
    )) {
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
      title: _isEdit
          ? ReminderStrings.editReminder
          : ReminderStrings.addReminder,
      actions: [
        if (_isEdit)
          IconButton(
            tooltip: AppStrings.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.inkMuted,
            onPressed: _delete,
          ),
      ],
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
            ReminderTypeSelector(
              value: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            if (isMedicine)
              MedicinePickerField(
                label: ReminderStrings.reminderMedicine,
                medicineId: _medicineId,
                allowNone: false,
                errorText: _medicineError,
                onChanged: _onMedicineChanged,
              ),
            AppTextField(
              label: ReminderStrings.reminderTitle,
              controller: _title,
              hint: ReminderStrings.reminderTitleHint,
              validator: AppTextField.required,
            ),
            PickerField(
              label: ReminderStrings.reminderWhen,
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
              label: ReminderStrings.reminderDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            if (!isMedicine)
              AppTextField(
                label: ReminderStrings.reminderLocation,
                controller: _location,
              ),
            AppTextField(
              label: ReminderStrings.reminderNotes,
              controller: _notes,
              maxLines: 3,
            ),
            SwitchRow(
              title: ReminderStrings.reminderCritical,
              subtitle: ReminderStrings.reminderCriticalHint,
              value: _critical,
              onChanged: (v) => setState(() => _critical = v),
            ),
            LabeledField(
              label: ReminderStrings.reminderSnooze,
              child: ChoicePills<int>(
                options: AppConstants.snoozeOptions,
                selected: {_snooze},
                labelOf: (m) => '$m ${AlarmStrings.minutesShort}',
                onChanged: (s) => setState(() => _snooze = s.single),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
