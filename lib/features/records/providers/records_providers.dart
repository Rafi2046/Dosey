import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/records_repository.dart';
import '../domain/record_summary.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>(
  (ref) => RecordsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(fileStorageProvider),
  ),
);

/// Type filter selected on the records screen (null = all).
final recordTypeFilterProvider =
    NotifierProvider<RecordTypeFilter, RecordType?>(RecordTypeFilter.new);

class RecordTypeFilter extends Notifier<RecordType?> {
  @override
  RecordType? build() => null;

  void select(RecordType? type) => state = type;
}

final recordSummariesProvider = StreamProvider<List<RecordSummary>>(
  (ref) => ref
      .watch(recordsRepositoryProvider)
      .watchSummaries(type: ref.watch(recordTypeFilterProvider)),
);

final recordsByDoctorProvider = StreamProvider.autoDispose
    .family<List<RecordSummary>, int>(
      (ref, doctorId) => ref
          .watch(recordsRepositoryProvider)
          .watchSummaries(doctorId: doctorId),
    );

final recordByIdProvider = StreamProvider.autoDispose
    .family<MedicalRecord?, int>(
      (ref, id) => ref.watch(recordsRepositoryProvider).watchById(id),
    );

final recordAttachmentsProvider = StreamProvider.autoDispose
    .family<List<RecordAttachment>, int>(
      (ref, recordId) =>
          ref.watch(recordsRepositoryProvider).watchAttachments(recordId),
    );
