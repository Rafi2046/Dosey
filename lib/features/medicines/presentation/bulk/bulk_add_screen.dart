import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/cream_scaffold.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../doctors/presentation/widgets/doctor_picker_field.dart';
import '../../../doctors/providers/doctors_providers.dart';
import '../../domain/scanned_doctor.dart';
import '../../domain/scanned_medicine.dart';
import '../../providers/medicines_providers.dart';
import '../scan_prescription_flow.dart';
import 'medicine_draft.dart';
import 'medicine_draft_card.dart';
import 'scanned_doctor_card.dart';

/// Review every medicine read off a prescription, fix mistakes, remove
/// extras, add missed ones, then save them all in one transaction.
/// Pops `true` once saved.
class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({
    super.key,
    required this.scanned,
    this.doctor,
    this.initialDoctorId,
  });

  final List<ScannedMedicine> scanned;

  /// The doctor printed on the prescription, if one was read.
  final ScannedDoctor? doctor;
  final int? initialDoctorId;

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateUtils.dateOnly(DateTime.now());
  late int? _doctorId = widget.initialDoctorId;

  /// The user chose "Prescribed by" themselves (or the form had a doctor),
  /// so a saved match doesn't override it.
  late bool _picked = widget.initialDoctorId != null;
  late final List<MedicineDraft> _drafts = [
    for (final s in widget.scanned)
      MedicineDraft.fromScan(context.l10n, s, _startDate),
  ];
  bool _saving = false;

  /// Create the scanned doctor on save (when it isn't already saved and no
  /// other doctor was picked).
  bool _saveScannedDoctor = true;

  Doctor? get _savedMatch => switch (widget.doctor) {
    final d? => matchSavedDoctor(
      ref.watch(doctorsProvider).value ?? const [],
      d,
    ),
    null => null,
  };

  /// Who the medicines are linked to: the picked doctor, else a saved match.
  int? get _linkedDoctorId => _picked ? _doctorId : _savedMatch?.id;

  DoctorsCompanion? get _newDoctor {
    final d = widget.doctor;
    if (d == null || !_saveScannedDoctor || _linkedDoctorId != null) {
      return null;
    }
    return DoctorsCompanion.insert(
      name: d.name,
      specialty: Value(d.specialty?.stored),
      phone: Value(d.phone),
      clinic: Value(d.clinic),
      notes: Value(d.degrees),
    );
  }

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _remove(MedicineDraft d) {
    setState(() => _drafts.remove(d));
    // Dispose after the card holding its controllers is gone.
    WidgetsBinding.instance.addPostFrameCallback((_) => d.dispose());
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    final firstBad = _drafts.indexWhere((d) => !d.isValid);
    if (!valid || firstBad >= 0) {
      return showAppSnack(
        context,
        context.l10n.bulkFixMedicine(firstBad < 0 ? 1 : firstBad + 1),
      );
    }
    setState(() => _saving = true);
    final count = _drafts.length;
    try {
      await ref.read(medicineScheduleServiceProvider).createMany([
        for (final d in _drafts)
          d.toNewMedicine(startDate: _startDate, doctorId: _linkedDoctorId),
      ], newDoctor: _newDoctor);
    } on Exception {
      // One transaction, so nothing was saved; let the user retry.
      if (!mounted) return;
      setState(() => _saving = false);
      return showAppSnack(context, context.l10n.genericError);
    }
    if (!mounted) return;
    showAppSnack(context, context.l10n.bulkSaved(count));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scannedDoctor = widget.doctor;
    final savedMatch = _savedMatch;
    final linkedId = _linkedDoctorId;
    return CreamScaffold(
      title: context.l10n.bulkTitle,
      bottomBar: PillButton(
        label: context.l10n.bulkSaveAll(_drafts.length),
        showForwardArrow: true,
        loading: _saving,
        onPressed: _drafts.isEmpty ? null : _save,
      ),
      body: Form(
        key: _formKey,
        // Not a lazy ListView: every card must be built so the Form can
        // validate (and show errors on) all of them, even off-screen ones.
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.bulkHint, style: AppTextStyles.bodyOnLight),
              AppSpacing.gapLg,
              if (scannedDoctor != null)
                ScannedDoctorCard(
                  doctor: scannedDoctor,
                  matchesSaved: savedMatch != null && linkedId == savedMatch.id,
                  // Hidden once another doctor is picked: nothing to save.
                  save: linkedId == null ? _saveScannedDoctor : null,
                  onSaveChanged: (v) => setState(() => _saveScannedDoctor = v),
                ),
              // Shared by every medicine on one prescription.
              DoctorPickerField(
                label: context.l10n.medicineDoctor,
                doctorId: linkedId,
                onChanged: (id) => setState(() {
                  _picked = true;
                  _doctorId = id;
                }),
              ),
              PickerField(
                label: context.l10n.medicineStartDate,
                value: AppDateFormat.date(_startDate),
                icon: Icons.event_rounded,
                onTap: () async {
                  final d = await AppPickers.date(context, initial: _startDate);
                  if (d != null) setState(() => _startDate = d);
                },
              ),
              AppSpacing.gapMd,
              for (final (i, d) in _drafts.indexed)
                MedicineDraftCard(
                  key: d.key,
                  draft: d,
                  number: i + 1,
                  onChanged: () => setState(() {}),
                  onRemove: () => _remove(d),
                ),
              if (_drafts.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    context.l10n.bulkEmpty,
                    style: AppTextStyles.bodyOnLight,
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: context.l10n.bulkAddAnother,
                  icon: Icons.add_rounded,
                  onTap: () =>
                      setState(() => _drafts.add(MedicineDraft(context.l10n))),
                ),
              ),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}
