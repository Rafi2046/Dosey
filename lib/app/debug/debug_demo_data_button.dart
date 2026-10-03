import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/widgets/pill_button.dart';
import '../../features/records/providers/records_providers.dart';
import '../../features/reminders/providers/reminders_providers.dart';
import 'demo_data_seeder.dart';
import '../../core/localization/l10n.dart';

/// Debug-only: fills the app with realistic sample data.
class DebugDemoDataButton extends ConsumerWidget {
  const DebugDemoDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillButton(
      label: context.l10n.debugLoadDemo,
      tone: PillButtonTone.cream,
      trailingIcon: Icons.dataset_rounded,
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final loaded = context.l10n.debugDemoLoaded;
        Navigator.of(context).pop();
        await DemoDataSeeder.seed(
          ref.read(appDatabaseProvider),
          ref.read(remindersRepositoryProvider),
          ref.read(recordsRepositoryProvider),
        );
        messenger.showSnackBar(SnackBar(content: Text(loaded)));
      },
    );
  }
}
