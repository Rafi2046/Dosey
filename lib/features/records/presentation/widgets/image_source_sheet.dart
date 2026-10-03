import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';

/// Lets the user photograph a document or pick pages from the gallery.
/// Returns the picked file paths (empty if cancelled).
Future<List<String>> pickRecordImages(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              iconColor: AppColors.ink,
              title: Text(
                RecordStrings.takePhoto,
                style: AppTextStyles.inputOnLight,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              iconColor: AppColors.ink,
              title: Text(
                RecordStrings.chooseFromGallery,
                style: AppTextStyles.inputOnLight,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null) return const [];

  final picker = ImagePicker();
  if (source == ImageSource.camera) {
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: AppConstants.imageQuality,
      maxWidth: AppConstants.imageMaxDimension,
      maxHeight: AppConstants.imageMaxDimension,
    );
    return [?file?.path];
  }
  final files = await picker.pickMultiImage(
    imageQuality: AppConstants.imageQuality,
    maxWidth: AppConstants.imageMaxDimension,
    maxHeight: AppConstants.imageMaxDimension,
  );
  return [for (final f in files) f.path];
}
