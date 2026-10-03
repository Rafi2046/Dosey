import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/choice_pills.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/picker_field.dart';
import '../widgets/reminder_times_editor.dart';
import 'medicine_draft.dart';
import '../../../../core/localization/l10n.dart';

/// Everything about one medicine on the review screen, in an outlined card:
/// name, strength, form, unit, times with amounts, meal and last day.
/// Mutates [draft] and calls [onChanged] so the screen rebuilds.
class MedicineDraftCard extends StatelessWidget {
  const MedicineDraftCard({
    super.key,
    required this.draft,
    required this.number,
    required this.onChanged,
    required this.onRemove,
  });

  final MedicineDraft draft;
  final int number;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: AppSpacing.cardPaddingLg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.sand, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.iconMd / 2 + AppSpacing.xs,
                backgroundColor: AppColors.mint,
                child: Text('$number', style: AppTextStyles.chip),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: draft.name,
                      builder: (_, _) => Text(
                        draft.name.text.trim().isEmpty
                            ? context.l10n.addMedicine
                            : draft.name.text.trim(),
                        style: AppTextStyles.cardTitleOnLight,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (draft.dosePattern case final p?)
                      Text(
                        context.l10n.bulkAsWritten(p),
                        style: AppTextStyles.captionOnLight,
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.l10n.bulkRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                onPressed: onRemove,
              ),
            ],
          ),
          AppSpacing.gapMd,
          AppTextField(
            label: context.l10n.medicineName,
            controller: draft.name,
            textCapitalization: TextCapitalization.words,
            validator: AppTextField.required,
          ),
          AppTextField(
            label: context.l10n.medicineStrength,
            controller: draft.strength,
            hint: context.l10n.optional,
          ),
          LabeledField(
            label: context.l10n.medicineForm,
            child: ChoicePills<MedicineForm>(
              columns: 4,
              options: MedicineForm.values,
              selected: {draft.form},
              labelOf: (f) => f.label(context.l10n),
              onChanged: (s) {
                draft.changeForm(s.single);
                onChanged();
              },
            ),
          ),
          AppTextField(
            label: context.l10n.medicineDoseUnit,
            controller: draft.unit,
            validator: AppTextField.required,
            textCapitalization: TextCapitalization.none,
          ),
          ListenableBuilder(
            listenable: draft.unit,
            builder: (context, _) => ReminderTimesEditor(
              doses: draft.doses,
              unit: draft.unit.text.trim(),
              onChanged: (d) {
                draft.doses = d;
                onChanged();
              },
            ),
          ),
          if (draft.doses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                context.l10n.bulkNoTimes,
                style: AppTextStyles.captionOnLight.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          LabeledField(
            label: context.l10n.medicineMeal,
            child: ChoicePills<MealRelation>(
              columns: 2,
              options: MealRelation.values,
              selected: {draft.meal},
              labelOf: (m) => m.label(context.l10n),
              onChanged: (s) {
                draft.meal = s.single;
                onChanged();
              },
            ),
          ),
          PickerField(
            label: context.l10n.medicineEndDate,
            value: switch (draft.endDate) {
              final d? => AppDateFormat.date(d),
              null => null,
            },
            placeholder: context.l10n.ongoing,
            icon: Icons.event_busy_rounded,
            onClear: () {
              draft.endDate = null;
              onChanged();
            },
            onTap: () async {
              final d = await AppPickers.date(context, initial: draft.endDate);
              if (d == null) return;
              draft.endDate = d;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
