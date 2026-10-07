import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/localization/l10n.dart';
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
import '../../auth/providers/auth_providers.dart';
import '../domain/family_share.dart';
import '../domain/remote_prescription.dart';
import '../domain/remote_prescription_sync_service.dart';
import '../../../core/widgets/guarded_form.dart';

class RemoteMedicineFormScreen extends ConsumerStatefulWidget {
  const RemoteMedicineFormScreen({
    super.key,
    required this.share,
    this.existing,
  });

  final FamilyShare share;
  final RemotePrescription? existing;

  @override
  ConsumerState<RemoteMedicineFormScreen> createState() =>
      _RemoteMedicineFormScreenState();
}

class _RemoteMedicineFormScreenState
    extends ConsumerState<RemoteMedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  RemotePrescription? get _existing => widget.existing;
  bool get _isEdit => _existing != null;

  late final _nameController =
      TextEditingController(text: _existing?.name ?? '');
  late final _doseAmountController = TextEditingController(
    text: _existing != null ? _existing!.doseAmount.toStringAsFixed(0) : '1',
  );
  late final _stockController = TextEditingController(
    text: _existing?.stockQuantity != null
        ? _existing!.stockQuantity!.toStringAsFixed(0)
        : '',
  );
  late final _notesController =
      TextEditingController(text: _existing?.notes ?? '');

  late MedicineForm _selectedForm = _parseForm(_existing?.form);
  late MealRelation _selectedMeal = _parseMeal(_existing?.mealRelation);
  late DateTime _startDate = _existing?.startDate ?? DateTime.now();
  late final DateTime? _endDate = _existing?.endDate;

  late final List<TimeOfDay> _times = _existing != null
      ? _existing!.times.map((t) {
          final parts = t.split(':');
          return TimeOfDay(
            hour: int.tryParse(parts.first) ?? 9,
            minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
          );
        }).toList()
      : [const TimeOfDay(hour: 9, minute: 0)];

  bool _isSaving = false;

  MedicineForm _parseForm(String? str) {
    if (str == null) return MedicineForm.tablet;
    for (final f in MedicineForm.values) {
      if (f.name.toLowerCase() == str.toLowerCase()) return f;
    }
    return MedicineForm.tablet;
  }

  MealRelation _parseMeal(String? str) {
    if (str == null) return MealRelation.afterMeal;
    for (final m in MealRelation.values) {
      if (m.name.toLowerCase() == str.toLowerCase()) return m;
    }
    return MealRelation.afterMeal;
  }

  Future<void> _pickTime(int index) async {
    final picked = await AppPickers.time(
      context,
      initial: _times[index],
    );
    if (picked != null) {
      setState(() {
        _times[index] = picked;
      });
    }
  }

  void _addTime() async {
    final picked = await AppPickers.time(
      context,
      initial: const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _times.add(picked);
      });
    }
  }

  void _removeTime(int index) {
    if (_times.length <= 1) return;
    setState(() {
      _times.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one dose time.')),
      );
      return;
    }
    if (!await ensureOnline(context) || !mounted) return;

    final user = ref.read(currentUserProvider);
    final caregiverName = user?.displayName ?? user?.email?.split('@').first;

    setState(() => _isSaving = true);
    try {
      final formattedTimes = _times.map((t) {
        final h = t.hour.toString().padLeft(2, '0');
        final m = t.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }).toList();

      final prescription = RemotePrescription(
        id: _existing?.id ?? '',
        patientUid: widget.share.patientUid,
        name: _nameController.text.trim(),
        form: _selectedForm.name,
        mealRelation: _selectedMeal.name,
        doseAmount: double.tryParse(_doseAmountController.text.trim()) ?? 1.0,
        doseUnit: _selectedForm.name,
        times: formattedTimes,
        startDate: _startDate,
        endDate: _endDate,
        stockQuantity: double.tryParse(_stockController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedBy: caregiverName,
        updatedAt: DateTime.now().toUtc(),
        isActive: true,
      );

      final repo = ref.read(remotePrescriptionRepositoryProvider);
      await repo.upsertRemotePrescription(prescription);

      if (mounted) {
        final patientName = widget.share.patientName ?? 'Family Member';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚡ Saved and synced to $patientName\'s phone!',
            ),
            backgroundColor: AppColors.moss,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.share.patientName ?? 'Family Member';
    final l10n = context.l10n;

    return CreamScaffold(
      title: _isEdit
          ? 'Edit Medicine for $patientName'
          : 'Add Medicine for $patientName',
      bottomBar: PillButton(
        label: _isSaving
            ? 'Syncing to $patientName\'s phone...'
            : (_isEdit ? 'Update & Sync' : 'Save & Sync to $patientName'),
        trailingIcon: Icons.cloud_sync_rounded,
        loading: _isSaving,
        onPressed: _handleSave,
      ),
      body: GuardedForm(
        formKey: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xs,
            bottom: AppSpacing.xxl,
          ),
          children: [
            // Medicine Name
            AppTextField(
              label: 'MEDICINE NAME',
              controller: _nameController,
              hint: 'e.g. Napa Extra, Metformin, Insulin',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            AppSpacing.gapLg,

            // Medicine Form (Visual Selection Cards)
            LabeledField(
              label: 'MEDICINE FORM',
              child: SizedBox(
                height: 98,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: MedicineForm.values.map((form) {
                    final isSelected = _selectedForm == form;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: InkWell(
                        onTap: () => setState(() => _selectedForm = form),
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 86,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sand
                                : AppColors.creamLight,
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                            border: Border.all(
                              color: isSelected
                                  ? (AppColors.isDark
                                      ? AppColors.selected
                                      : AppColors.moss)
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                form.image,
                                width: 38,
                                height: 38,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                form.label(l10n),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: AppSpacing.fontSm,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? (AppColors.isDark
                                          ? AppColors.selected
                                          : AppColors.moss)
                                      : AppColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            AppSpacing.gapLg,

            // Meal Relation (Symmetric 2x2 Grid)
            LabeledField(
              label: 'TAKE RELATION',
              child: ChoicePills<MealRelation>(
                columns: 2,
                options: MealRelation.values,
                selected: {_selectedMeal},
                labelOf: (m) => m.label(l10n),
                onChanged: (selectedSet) {
                  if (selectedSet.isNotEmpty) {
                    setState(() => _selectedMeal = selectedSet.first);
                  }
                },
              ),
            ),
            AppSpacing.gapLg,

            // Dose Times Builder
            LabeledField(
              label: 'SCHEDULED DOSING TIMES (${_times.length} TIMES/DAY)',
              child: Column(
                children: [
                  ..._times.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    final timeStr = AppDateFormat.timeOfDay(time);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamLight,
                          borderRadius: BorderRadius.circular(AppSpacing.lg),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 18,
                                color: AppColors.accent,
                              ),
                            ),
                            AppSpacing.gapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dose ${index + 1}',
                                    style: AppTextStyles.captionOnLight.copyWith(
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontFamily: 'NDot',
                                      fontSize: AppSpacing.fontLg,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 20),
                              color: AppColors.isDark
                                  ? AppColors.selected
                                  : AppColors.moss,
                              onPressed: () => _pickTime(index),
                            ),
                            if (_times.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 20,
                                ),
                                color: AppColors.error,
                                onPressed: () => _removeTime(index),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xs),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addTime,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sand.withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(
                            color: AppColors.isDark
                                ? AppColors.selected.withValues(alpha: 0.35)
                                : AppColors.moss.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                              color: AppColors.isDark
                                  ? AppColors.selected
                                  : AppColors.moss,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Add Another Intake Time',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: AppSpacing.fontSm,
                                fontWeight: FontWeight.w700,
                                color: AppColors.isDark
                                    ? AppColors.selected
                                    : AppColors.moss,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Dose Amount & Stock Row
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'DOSE AMOUNT',
                    controller: _doseAmountController,
                    hint: '1',
                    keyboardType: TextInputType.number,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: AppTextField(
                    label: 'INITIAL STOCK',
                    controller: _stockController,
                    hint: 'e.g. 30',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            AppSpacing.gapLg,

            // Start Date Picker
            PickerField(
              label: 'START DATE',
              value: AppDateFormat.date(_startDate),
              icon: Icons.calendar_today_rounded,
              onTap: () async {
                final picked = await AppPickers.date(
                  context,
                  initial: _startDate,
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),
            AppSpacing.gapLg,

            // Notes
            AppTextField(
              label: 'DOCTOR NOTES / INSTRUCTIONS',
              controller: _notesController,
              hint: 'e.g. Take with a glass of water',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
