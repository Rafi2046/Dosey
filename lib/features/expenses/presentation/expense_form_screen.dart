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
import '../../medicines/presentation/widgets/medicine_picker_field.dart';
import '../../reminders/domain/reminder_text.dart';
import '../providers/expenses_providers.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/guarded_form.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.existing});

  final Expense? existing;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Expense? get _e => widget.existing;

  late final _amount = TextEditingController(
    text: _e == null ? null : Money.formatPlain(_e!.amountMinor),
  );
  late final _title = TextEditingController(text: _e?.title);
  late final _quantity = TextEditingController(
    text: _e?.quantity == null
        ? null
        : ReminderText.formatAmount(_e!.quantity!),
  );
  late final _notes = TextEditingController(text: _e?.notes);
  late ExpenseCategory _category = _e?.category ?? ExpenseCategory.medicine;
  late DateTime _date = _e?.spentOn ?? DateTime.now();
  late int? _medicineId = _e?.medicineId;
  late int? _doctorId = _e?.doctorId;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_amount, _title, _quantity, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final isMedicine = _category == ExpenseCategory.medicine;
    final companion = ExpensesCompanion(
      category: Value(_category),
      title: Value(_title.text.trim()),
      amountMinor: Value(Money.parse(_amount.text)!),
      quantity: Value(double.tryParse(_quantity.text.trim())),
      medicineId: Value(isMedicine ? _medicineId : null),
      doctorId: Value(_doctorId),
      spentOn: Value(_date),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    );
    final repo = ref.read(expensesRepositoryProvider);
    _e == null
        ? await repo.create(companion)
        : await repo.update(_e!.id, companion);
    if (!mounted) return;
    showAppSnack(context, context.l10n.saved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context, body: context.l10n.deleteExpenseBody)) {
      return;
    }
    await ref.read(expensesRepositoryProvider).delete(_e!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      title: _e == null ? context.l10n.addExpense : context.l10n.edit,
      actions: [
        if (_e != null)
          IconButton(
            tooltip: context.l10n.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.inkMuted,
            onPressed: _delete,
          ),
      ],
      bottomBar: PillButton(
        label: _e == null ? context.l10n.save : context.l10n.saveChanges,
        trailingIcon: Icons.check_rounded,
        loading: _saving,
        onPressed: _save,
      ),
      body: GuardedForm(
        formKey: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            AppTextField.decimal(
              label: context.l10n.expenseAmount,
              controller: _amount,
              prefixText: AppConstants.currencySymbol,
              validator: (v) => (Money.parse(v ?? '') ?? 0) > 0
                  ? null
                  : context.l10n.invalidAmount,
            ),
            AppTextField(
              label: context.l10n.expenseTitle,
              controller: _title,
              hint: context.l10n.expenseTitleHint,
              validator: AppTextField.required,
            ),
            LabeledField(
              label: context.l10n.expenseCategory,
              child: ChoicePills<ExpenseCategory>(
                columns: 3,
                options: ExpenseCategory.values,
                selected: {_category},
                labelOf: (c) => c.label(context.l10n),
                iconOf: (c) => c.icon,
                onChanged: (s) => setState(() => _category = s.single),
              ),
            ),
            PickerField(
              label: context.l10n.expenseDate,
              value: AppDateFormat.date(_date),
              icon: Icons.event_rounded,
              onTap: () async {
                final d = await AppPickers.date(context, initial: _date);
                if (d != null) setState(() => _date = d);
              },
            ),
            if (_category == ExpenseCategory.medicine)
              MedicinePickerField(
                label: context.l10n.expenseMedicine,
                medicineId: _medicineId,
                onChanged: (id) => setState(() => _medicineId = id),
              ),
            DoctorPickerField(
              label: context.l10n.expenseDoctor,
              doctorId: _doctorId,
              onChanged: (id) => setState(() => _doctorId = id),
            ),
            AppTextField.decimal(
              label: context.l10n.expenseQuantity,
              controller: _quantity,
              hint: context.l10n.optional,
            ),
            AppTextField(
              label: context.l10n.expenseNotes,
              controller: _notes,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
