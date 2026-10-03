import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../onboarding/presentation/pages/permissions_page.dart';
import '../../../core/widgets/back_arrow_button.dart';

/// Settings › Alarm permissions: the onboarding permissions page on its
/// own, to check or fix permissions any time (e.g. after a battery saver or
/// system update turned one off).
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.md),
              child: const BackArrowButton(),
            ),
            const Expanded(child: PermissionsPage()),
          ],
        ),
      ),
    );
  }
}
