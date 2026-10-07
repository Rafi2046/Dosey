import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/doctors_providers.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/suggest_field.dart';
import '../data/health_facilities.dart';
import '../domain/specialty.dart';

class DoctorFormScreen extends ConsumerStatefulWidget {
  const DoctorFormScreen({super.key, this.existing});

  final Doctor? existing;

  @override
  ConsumerState<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends ConsumerState<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Doctor? get _d => widget.existing;

  late final _name = TextEditingController(text: _d?.name);
  // Lazy, so it can show a saved specialty in the current language.
  late final _specialty = TextEditingController(
    text: switch (_d?.specialty) {
      final s? => Specialty.display(s, context.l10n),
      null => null,
    },
  );
  late final _phone = TextEditingController(text: _d?.phone);
  late final _email = TextEditingController(text: _d?.email);
  late final _clinic = TextEditingController(text: _d?.clinic);
  late final _address = TextEditingController(text: _d?.address);
  late final _fee = TextEditingController(
    text: _d?.consultationFeeMinor == null
        ? null
        : Money.formatPlain(_d!.consultationFeeMinor!),
  );
  late final _notes = TextEditingController(text: _d?.notes);
  bool _saving = false;

  List<TextEditingController> get _all => [
    _name,
    _specialty,
    _phone,
    _email,
    _clinic,
    _address,
    _fee,
    _notes,
  ];

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  static Value<String?> _opt(TextEditingController c) =>
      Value(c.text.trim().isEmpty ? null : c.text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final companion = DoctorsCompanion(
      name: Value(_name.text.trim()),
      specialty: Value(Specialty.toStored(_specialty.text)),
      phone: _opt(_phone),
      email: _opt(_email),
      clinic: _opt(_clinic),
      address: _opt(_address),
      consultationFeeMinor: Value(Money.parse(_fee.text)),
      notes: _opt(_notes),
    );
    final repo = ref.read(doctorsRepositoryProvider);
    _d == null
        ? await repo.create(companion)
        : await repo.update(_d!.id, companion);
    if (!mounted) return;
    showAppSnack(context, context.l10n.saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Start loading the offline hospital list before the user gets there.
    ref.watch(healthFacilitiesProvider);
    return CreamScaffold(
      title: _d == null ? context.l10n.addDoctor : context.l10n.editDoctor,
      bottomBar: PillButton(
        label: _d == null ? context.l10n.save : context.l10n.saveChanges,
        showForwardArrow: true,
        loading: _saving,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            AppTextField(
              label: context.l10n.doctorName,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: AppTextField.required,
            ),
            SuggestField<Specialty>(
              label: context.l10n.doctorSpecialty,
              controller: _specialty,
              hint: context.l10n.doctorSpecialtyHint,
              icon: Icons.expand_more_rounded,
              suggestions: (text) => Specialty.suggest(text, context.l10n),
              labelOf: (s) => s.label(context.l10n),
            ),
            AppTextField(
              label: context.l10n.doctorPhone,
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            AppTextField(
              label: context.l10n.doctorEmail,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            SuggestField<HealthFacility>(
              label: context.l10n.doctorClinic,
              controller: _clinic,
              hint: context.l10n.doctorClinicHint,
              icon: Icons.local_hospital_rounded,
              suggestions: (text) =>
                  ref.read(healthFacilitiesProvider).value?.search(text) ??
                  const [],
              labelOf: (f) => f.name,
              subtitleOf: (f) => f.address.isEmpty ? f.otherName : f.address,
              onSelected: (f) {
                // Don't overwrite an address the user already typed.
                if (_address.text.trim().isEmpty && f.address.isNotEmpty) {
                  _address.text = f.address;
                }
              },
            ),
            AppTextField(
              label: context.l10n.doctorAddress,
              controller: _address,
              maxLines: 2,
            ),
            AppTextField.decimal(
              label: context.l10n.doctorFee,
              controller: _fee,
              prefixText: AppConstants.currencySymbol,
              validator: (v) =>
                  (v == null || v.trim().isEmpty || Money.parse(v) != null)
                  ? null
                  : context.l10n.invalidAmount,
            ),
            AppTextField(
              label: context.l10n.doctorNotes,
              controller: _notes,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
