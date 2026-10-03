import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';

/// Lets the user photograph a document or pick pages from the gallery.
/// Returns the picked file paths (empty if cancelled).
Future<List<String>> pickRecordImages(BuildContext context) async {
  final source = await _chooseSource(context);
  if (source == null) return const [];
  if (source == ImageSource.camera) return [?await _pickOne(source)];
  final files = await ImagePicker().pickMultiImage(
    imageQuality: AppConstants.imageQuality,
    maxWidth: AppConstants.imageMaxDimension,
    maxHeight: AppConstants.imageMaxDimension,
  );
  return [for (final f in files) f.path];
}

/// Camera or gallery, one image. Null if cancelled.
Future<String?> pickSingleImage(BuildContext context) async {
  final source = await _chooseSource(context);
  return source == null ? null : _pickOne(source);
}

Future<String?> _pickOne(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    imageQuality: AppConstants.imageQuality,
    maxWidth: AppConstants.imageMaxDimension,
    maxHeight: AppConstants.imageMaxDimension,
  );
  return file?.path;
}

Future<ImageSource?> _chooseSource(BuildContext context) =>
    showModalBottomSheet<ImageSource>(
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
