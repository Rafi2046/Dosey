import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_storage_service.dart';

/// App documents directory, resolved once in `main.dart` and injected via
/// `ProviderScope(overrides: [...])` so paths can be built synchronously.
final documentsDirectoryProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('Override at startup'),
);

final fileStorageProvider = Provider<FileStorageService>(
  (ref) => FileStorageService(ref.watch(documentsDirectoryProvider)),
);
