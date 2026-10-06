import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/storage/storage_providers.dart';

/// Shows a saved record page from its relative path. [cacheWidth] decodes
/// thumbnails at a small size to keep grids fast.
class RecordImage extends ConsumerWidget {
  const RecordImage({
    super.key,
    required this.relativePath,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final String? relativePath;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = relativePath;
    if (path == null) return const _Placeholder();
    return Image.file(
      ref.watch(fileStorageProvider).resolve(path),
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.sand,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.description_outlined,
          size: 32,
          color: AppColors.inkMuted.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 4),
        Text(
          'Document',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMuted.withValues(alpha: 0.7),
          ),
        ),
      ],
    ),
  );
}
