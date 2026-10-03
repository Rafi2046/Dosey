import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/scanned_medicine.dart';
import '../providers/medicines_providers.dart';
import 'bulk/bulk_add_screen.dart';

/// Pick a prescription photo and read it. Returns the medicines found, or
/// null when the user cancelled or nothing could be read (they've been told
/// why).
///
/// Takes the [container] rather than a widget's `ref` because callers like
/// the "+" sheet are gone before the scan finishes. [onBusy] lets a screen
/// show its own progress; otherwise a "Reading prescription…" dialog shows.
Future<List<ScannedMedicine>?> scanPrescription(
  BuildContext context,
  ProviderContainer container, {
  ValueChanged<bool>? onBusy,
}) async {
  final path = await container.read(prescriptionImagePickerProvider)(context);
  if (path == null || !context.mounted) return null;

  final navigator = Navigator.of(context);
  final l10n = context.l10n;
  if (onBusy != null) {
    onBusy(true);
  } else {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ReadingDialog(message: l10n.scanReading),
      ),
    );
  }

  List<ScannedMedicine>? found;
  try {
    found = await container.read(prescriptionScannerProvider).scan(path);
  } on Exception {
    found = null;
  }

  if (onBusy != null) {
    onBusy(false);
  } else {
    navigator.pop();
  }
  if (!context.mounted) return null;
  if (found == null) {
    showAppSnack(context, l10n.scanFailed);
    return null;
  }
  if (found.isEmpty) {
    showAppSnack(context, l10n.scanNothingFound);
    return null;
  }
  return found;
}

/// "+" › Scan prescription: read it, then review and save every medicine on
/// it at once (one card per medicine, even if there's only one).
Future<void> scanPrescriptionToBulkAdd(
  BuildContext context,
  ProviderContainer container,
) async {
  final found = await scanPrescription(context, container);
  if (found == null || !context.mounted) return;
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => BulkAddScreen(scanned: found)),
  );
}

class _ReadingDialog extends StatelessWidget {
  const _ReadingDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox.square(
              dimension: AppSpacing.iconLg,
              child: CircularProgressIndicator(),
            ),
            AppSpacing.gapLg,
            Expanded(child: Text(message, style: AppTextStyles.bodyOnLight)),
          ],
        ),
      ),
    );
  }
}
