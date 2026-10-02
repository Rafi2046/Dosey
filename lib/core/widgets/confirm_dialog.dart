import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Destructive-action confirmation. Resolves to true only on "Delete".
Future<bool> confirmDelete(BuildContext context, {required String body}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.deleteConfirmTitle),
      content: Text(body),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(AppStrings.delete),
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
