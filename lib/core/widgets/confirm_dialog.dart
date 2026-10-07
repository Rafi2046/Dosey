import 'package:flutter/material.dart';

import '../cloud/connectivity.dart';
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

/// "Exit Dosey?" on back from Home. True only on "Exit".
Future<bool> confirmExit(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.exitTitle),
      content: Text(context.l10n.exitBody),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.exitStay),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.exitConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// "Discard changes?" on leaving a form with unsaved edits. True only on
/// "Discard".
Future<bool> confirmDiscard(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.discardTitle),
      content: Text(context.l10n.discardBody),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.discardKeep),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.discardConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Gate for actions that need the cloud (Family Sharing). True when online;
/// otherwise explains why the action can't run, and "Try again" carries on
/// with the action as soon as the connection is back.
Future<bool> ensureOnline(BuildContext context) async {
  while (true) {
    if (await hasInternet()) return true;
    if (!context.mounted) return false;
    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.wifi_off_rounded, color: AppColors.inkMuted),
        title: Text(context.l10n.offlineTitle),
        content: Text(context.l10n.offlineBody),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.offlineDismiss),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.offlineRetry),
          ),
        ],
      ),
    );
    if (retry != true) return false;
  }
}

void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
