import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';

/// Copies picked images into app storage and resolves the relative paths
/// stored in the database back to files.
class FileStorageService {
  FileStorageService(this.root);

  /// App documents directory (a temp directory in tests).
  final Directory root;

  /// Copies [sourcePath] into the records folder and returns its relative path.
  Future<String> saveRecordImage(String sourcePath) async {
    final relative = p.join(
      AppConstants.recordsFolder,
      '${DateTime.now().microsecondsSinceEpoch}${_extensionOf(sourcePath)}',
    );
    final target = File(p.join(root.path, relative));
    await target.parent.create(recursive: true);
    await File(sourcePath).copy(target.path);
    return relative;
  }

  File resolve(String relativePath) => File(p.join(root.path, relativePath));

  Future<void> delete(String relativePath) async {
    final file = resolve(relativePath);
    if (await file.exists()) await file.delete();
  }

  Future<void> deleteAll(Iterable<String> relativePaths) =>
      Future.wait(relativePaths.map(delete));

  /// Removes every saved record image, including any orphaned files.
  Future<void> deleteRecordsFolder() async {
    final folder = Directory(p.join(root.path, AppConstants.recordsFolder));
    if (await folder.exists()) await folder.delete(recursive: true);
  }

  /// Upgrades any legacy first-aid kit demo images to the new high-resolution
  /// prescription and lab report images.
  Future<void> upgradeLegacyDemoImages(List<int> newImageBytes) async {
    try {
      final folder = Directory(p.join(root.path, AppConstants.recordsFolder));
      if (!await folder.exists()) return;
      final files = await folder.list().toList();
      for (final entity in files) {
        if (entity is File) {
          final len = await entity.length();
          if (len == 25239 || len < 30000) {
            await entity.writeAsBytes(newImageBytes, flush: true);
          }
        }
      }
    } catch (_) {}
  }

  static String _extensionOf(String path) {
    final ext = p.extension(path);
    return ext.isEmpty ? AppConstants.imageExtension : ext.toLowerCase();
  }
}
