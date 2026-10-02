import '../../../core/database/app_database.dart';

/// A record row for list views: its doctor, first page and page count.
class RecordSummary {
  const RecordSummary({
    required this.record,
    required this.pageCount,
    this.doctor,
    this.coverPath,
  });

  final MedicalRecord record;
  final Doctor? doctor;

  /// Relative path of the first page, for the thumbnail.
  final String? coverPath;
  final int pageCount;
}
