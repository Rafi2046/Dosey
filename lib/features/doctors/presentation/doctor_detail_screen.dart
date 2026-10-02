import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/info_block.dart';
import '../../../core/widgets/pill_button.dart';
import '../../reminders/presentation/reminder_form_screen.dart';
import '../providers/doctors_providers.dart';
import 'doctor_form_screen.dart';
import 'widgets/doctor_linked_sections.dart';
import 'widgets/doctor_profile_header.dart';

enum _MenuAction { archive, delete }

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final int doctorId;

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    Doctor doctor,
    _MenuAction action,
  ) async {
    final repo = ref.read(doctorsRepositoryProvider);
    switch (action) {
      case _MenuAction.archive:
        await repo.setArchived(doctor.id, archived: !doctor.isArchived);
      case _MenuAction.delete:
        if (!await confirmDelete(context, body: AppStrings.deleteDoctorBody)) {
          return;
        }
        if (context.mounted) Navigator.pop(context);
        await repo.delete(doctor.id);
    }
  }

  void _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(doctorByIdProvider(doctorId));
    final doctor = value.value;

    return CreamScaffold(
      title: AppStrings.details,
      actions: [
        if (doctor != null)
          PopupMenuButton<_MenuAction>(
            iconColor: AppColors.ink,
            onSelected: (a) => _onMenu(context, ref, doctor, a),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.archive,
                child: Text(
                  doctor.isArchived ? AppStrings.unarchive : AppStrings.archive,
                ),
              ),
              const PopupMenuItem(
                value: _MenuAction.delete,
                child: Text(AppStrings.delete),
              ),
            ],
          ),
      ],
      bottomBar: doctor == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PillButton(
                  label: AppStrings.addAppointment,
                  tone: PillButtonTone.moss,
                  trailingIcon: Icons.event_available_rounded,
                  onPressed: () => _push(
                    context,
                    ReminderFormScreen(
                      initialType: ReminderType.appointment,
                      initialDoctorId: doctor.id,
                    ),
                  ),
                ),
                AppSpacing.gapMd,
                PillButton(
                  label: AppStrings.changeSetting,
                  trailingIcon: Icons.settings_rounded,
                  onPressed: () =>
                      _push(context, DoctorFormScreen(existing: doctor)),
                ),
              ],
            ),
      body: AsyncValueView(
        value: value,
        data: (doctor) => doctor == null
            ? const SizedBox.shrink()
            : ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  DoctorProfileHeader(doctor: doctor),
                  if (doctor.clinic != null)
                    InfoBlock(
                      label: AppStrings.doctorClinic,
                      value: doctor.clinic!,
                    ),
                  if (doctor.address != null)
                    InfoBlock(
                      label: AppStrings.doctorAddress,
                      value: doctor.address!,
                    ),
                  if (doctor.phone != null)
                    InfoBlock(
                      label: AppStrings.doctorPhone,
                      value: doctor.phone!,
                    ),
                  if (doctor.consultationFeeMinor != null)
                    InfoBlock(
                      label: AppStrings.doctorFee,
                      value: Money.format(doctor.consultationFeeMinor!),
                    ),
                  if (doctor.notes != null)
                    InfoBlock(
                      label: AppStrings.doctorNotes,
                      value: doctor.notes!,
                    ),
                  DoctorLinkedSections(doctorId: doctor.id),
                ],
              ),
      ),
    );
  }
}
