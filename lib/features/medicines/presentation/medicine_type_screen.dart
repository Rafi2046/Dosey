import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/enums.dart';
import '../../../core/widgets/pill_button.dart';
import 'medicine_form_screen.dart';
import 'widgets/medicine_type_grid.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/back_arrow_button.dart';

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
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600 || screenSize.width >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: isTablet
                        ? const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.lg,
                          )
                        : AppSpacing.screenPadding,
                    children: [
                      AppSpacing.gapMd,
                      Row(
                        children: [
                          const BackArrowButton(),
                          AppSpacing.gapSm,
                          Expanded(
                            child: Text(
                              context.l10n.addMedicine,
                              style: AppTextStyles.subtitle,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  padding: isTablet
                      ? const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.md,
                          AppSpacing.xxl,
                          AppSpacing.xl,
                        )
                      : AppSpacing.bottomBarPadding,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: PillButton(
                      label: context.l10n.next,
                      showCapsuleArrow: true,
                      onPressed: _openForm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
