import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../providers/permissions_provider.dart';

/// iOS: what the user will actually hear. Notification sounds on/off (with
/// a way to fix it), and whether reminders ring through silent mode and
/// Focus. Hidden on Android, where alarm channels handle both.
class IosSoundCard extends ConsumerWidget {
  const IosSoundCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(iosSoundStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    final l10n = context.l10n;

    Widget row(IconData icon, bool ok, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : icon,
          color: ok ? AppColors.tileMint : AppColors.accent,
        ),
        AppSpacing.gapMd,
        Expanded(child: Text(text, style: AppTextStyles.bodyOnLight)),
      ],
    );

    return SurfaceCard(
      color: AppColors.cream,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.iosSoundTitle, style: AppTextStyles.cardTitleOnLight),
          AppSpacing.gapMd,
          row(
            Icons.volume_off_rounded,
            status.sound,
            status.sound ? l10n.iosSoundOn : l10n.iosSoundOff,
          ),
          if (!status.sound) ...[
            AppSpacing.gapMd,
            PillButton(
              label: l10n.openSettings,
              tone: PillButtonTone.moss,
              onPressed: () => ref
                  .read(permissionServiceProvider)
                  .openNotificationSettings(),
            ),
          ],
          AppSpacing.gapMd,
          row(
            Icons.notifications_off_rounded,
            status.critical,
            status.critical ? l10n.iosCriticalOn : l10n.iosCriticalOff,
          ),
        ],
      ),
    );
  }
}
