import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/pill_button.dart';
import 'medicine_form_screen.dart';
import 'widgets/medicine_type_grid.dart';

/// Step 1 of "Add Medicine": the design's "Choose Medicine Type" screen.
class MedicineTypeScreen extends StatefulWidget {
  const MedicineTypeScreen({super.key, this.initialDoctorId});

  final int? initialDoctorId;

  @override
  State<MedicineTypeScreen> createState() => _MedicineTypeScreenState();
}

class _MedicineTypeScreenState extends State<MedicineTypeScreen> {
  MedicineForm _form = MedicineForm.tablet;

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
                      const Text(
                        AppStrings.addMedicine,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  AppSpacing.gapXl,
                  const Text(
                    AppStrings.chooseMedicineType,
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
                label: AppStrings.next,
                showRingChevron: true,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => MedicineFormScreen(
                      initialForm: _form,
                      initialDoctorId: widget.initialDoctorId,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
