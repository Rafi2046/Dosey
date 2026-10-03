import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../providers/medicines_providers.dart';
import '../../../../core/localization/l10n.dart';

/// Records a purchase: adds stock and logs the cost as an expense.
Future<void> showRefillSheet(BuildContext context, Medicine medicine) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RefillSheet(medicine: medicine),
    );

class _RefillSheet extends ConsumerStatefulWidget {
  const _RefillSheet({required this.medicine});

  final Medicine medicine;

  @override
  ConsumerState<_RefillSheet> createState() => _RefillSheetState();
}

class _RefillSheetState extends ConsumerState<_RefillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _total = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the total from the unit price as the user types a quantity.
    _quantity.addListener(() {
      final qty = double.tryParse(_quantity.text);
      final price = widget.medicine.unitPriceMinor;
      if (qty != null && price > 0) {
        _total.text = Money.formatPlain((qty * price).round());
      }
    });
  }

  @override
  void dispose() {
    _quantity.dispose();
    _total.dispose();
    super.dispose();
  }

  /// "+1 box" / "+1 strip": add a pack's worth of units to the quantity.
  void _addUnits(int units) {
    final current = double.tryParse(_quantity.text.trim()) ?? 0;
    _quantity.text = ReminderText.formatAmount(current + units);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref
        .read(medicinesRepositoryProvider)
        .refill(
          medicine: widget.medicine,
          quantity: double.parse(_quantity.text.trim()),
          totalMinor: Money.parse(_total.text)!,
        );
    if (!mounted) return;
    Navigator.pop(context);
    showAppSnack(context, context.l10n.refillSaved);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding.copyWith(
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.refillTitle, style: AppTextStyles.titleOnLight),
            Text(widget.medicine.name, style: AppTextStyles.bodyOnLight),
            AppSpacing.gapXl,
            AppTextField.decimal(
              label: context.l10n.refillQuantity,
              controller: _quantity,
              hint: widget.medicine.doseUnit,
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                  ? null
                  : context.l10n.invalidNumber,
            ),
            if (widget.medicine.unitsPerStrip case final perStrip?) ...[
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (widget.medicine.stripsPerBox case final perBox?)
                    StatusChip(
                      label: context.l10n.addOneBox,
                      icon: Icons.inventory_2_rounded,
                      onTap: () => _addUnits(perStrip * perBox),
                    ),
                  StatusChip(
                    label: context.l10n.addOneStrip,
                    icon: Icons.view_agenda_rounded,
                    onTap: () => _addUnits(perStrip),
                  ),
                ],
              ),
              AppSpacing.gapLg,
            ],
            AppTextField.decimal(
              label: context.l10n.refillTotal,
              controller: _total,
              prefixText: AppConstants.currencySymbol,
              validator: (v) => Money.parse(v ?? '') == null
                  ? context.l10n.invalidAmount
                  : null,
            ),
            PillButton(
              label: context.l10n.save,
              showRingChevron: true,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
