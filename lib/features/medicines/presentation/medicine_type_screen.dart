import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/pill_button.dart';
import 'medicine_form_screen.dart';
import 'widgets/medicine_type_grid.dart';
import '../../../core/localization/l10n.dart';

/// Step 1 of "Add Medicine": the design's "Choose Medicine Type" screen.
class MedicineTypeScreen extends StatefulWidget {
  const MedicineTypeScreen({super.key, this.initialDoctorId});

  final int? initialDoctorId;

  @override
  State<MedicineTypeScreen> createState() => _MedicineTypeScreenState();
}

class _MedicineTypeScreenState extends State<MedicineTypeScreen> {
  MedicineForm _form = MedicineForm.tablet;

  /// Opens the form on top (back returns here to change the type). Once
  /// saved, this screen closes too and pops `true`, so whoever opened
  /// "Add medicine" knows a medicine now exists.
  Future<void> _openForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MedicineFormScreen(
          initialForm: _form,
          initialDoctorId: widget.initialDoctorId,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      CircleIconButton.back(context),
                      AppSpacing.gapMd,
                      Text(
                        context.l10n.addMedicine,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  AppSpacing.gapXl,
                  Text(
                    context.l10n.chooseMedicineType,
                    style: AppTextStyles.display,
                  ),
                  AppSpacing.gapXl,
                  MedicineTypeGrid(
                    value: _form,
                    onChanged: (f) => setState(() => _form = f),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.bottomBarPadding,
              child: PillButton(
                label: context.l10n.next,
                showRingChevron: true,
                onPressed: _openForm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
