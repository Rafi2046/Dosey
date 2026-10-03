import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../localization/l10n.dart';

/// Destructive-action confirmation. Resolves to true only on the confirm
/// button ("Delete" unless [confirmLabel] is given).
Future<bool> confirmDelete(
  BuildContext context, {
  required String body,
  String? title,
  String? confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? context.l10n.deleteConfirmTitle),
      content: Text(body),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? context.l10n.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
