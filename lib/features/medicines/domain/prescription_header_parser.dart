import '../../doctors/domain/specialty.dart';
import 'scanned_doctor.dart';

/// Reads the doctor block printed above "Rx" on a prescription:
///
///     Dr. Farhana Rahman
///     MBBS, FCPS (Medicine)
///     Medicine Specialist
///     Square Hospital, Dhaka | Phone: 01711-000000
abstract final class PrescriptionHeaderParser {
  /// Lines considered when there's no "Rx" marker.
  static const int _maxHeaderLines = 10;

  static final _rx = RegExp(r'^\s*(rx|℞)\b', caseSensitive: false);
  static final _title = RegExp(
    r'^\s*(dr|prof|professor|assoc\.? prof|asst\.? prof)\b\.?|^\s*ডা[ঃ.]?',
    caseSensitive: false,
    unicode: true,
  );
  static final _degree = RegExp(
    r'\b(MBBS|BDS|FCPS|FRCS|FRCP|MRCP|MCPS|MD|MS|MPH|DCH|DGO|DDV|DMRD|DTCD|'
    r'D-?Ortho|PhD|BCS|FACC|FICS|MRCOG|DLO)\b',
  );

  /// Bangladeshi mobile: optional +88 / 88, then 01[3-9] + 8 digits, allowing
  /// spaces or dashes.
  static final _phone = RegExp(r'(?:\+?88)?0\s*1[3-9](?:[\s-]?\d){8}');
  static final _clinicWord = RegExp(
    r'hospital|clinic|diagnostic|medical|cent(?:re|er)|chamber|healthcare|'
    r'হাসপাতাল|ক্লিনিক|চেম্বার',
    caseSensitive: false,
    unicode: true,
  );
  static final _patient = RegExp(
    r'\b(patient|name\s*:|age|sex|date|weight|bp)\b',
    caseSensitive: false,
  );
  static final _label = RegExp(
    r'^\s*(chamber|address|clinic|hospital)\s*[:\-]\s*',
    caseSensitive: false,
  );

  static ScannedDoctor? parse(List<String> rawLines) {
    final lines = [
      for (final l in rawLines) l.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ]..removeWhere((l) => l.isEmpty);
    final rxAt = lines.indexWhere(_rx.hasMatch);
    final header = (rxAt >= 0 ? lines.take(rxAt) : lines.take(_maxHeaderLines))
        .where((l) => !_patient.hasMatch(l))
        .toList();

    final nameLine = header.where(_title.hasMatch).firstOrNull;
    if (nameLine == null) return null;
    // "Dr. Rahman MBBS, FCPS" → name before the first degree.
    final firstDegree = _degree.firstMatch(nameLine);
    final name =
        (firstDegree == null
                ? nameLine
                : nameLine.substring(0, firstDegree.start))
            .replaceAll(RegExp(r'[,;|]+\s*$'), '')
            .trim();
    if (name.replaceAll(_title, '').trim().length < 2) return null;

    final degreeLines = [
      for (final l in header)
        if (_degree.hasMatch(l)) l.substring(_degree.firstMatch(l)!.start),
    ];

    String? phone;
    String? clinic;
    Specialty? specialty;
    for (final line in header) {
      phone ??= _phone
          .firstMatch(line)
          ?.group(0)
          ?.replaceAll(RegExp(r'\D'), '')
          .replaceFirst(RegExp(r'^88'), '');
      if (line == nameLine) continue;
      specialty ??= _specialtyIn(line);
      if (clinic == null && _clinicWord.hasMatch(line)) {
        // "Square Hospital, Dhaka | Phone: 017…" → the part without a phone.
        final part = line
            .split(RegExp(r'\s*[|•]\s*'))
            .firstWhere(_clinicWord.hasMatch, orElse: () => line);
        final cleaned = part
            .replaceAll(_phone, '')
            .replaceAll(
              RegExp(r'(phone|mobile|cell|tel)\s*[:.]?', caseSensitive: false),
              '',
            )
            .replaceFirst(_label, '')
            .replaceAll(RegExp(r'[,;:|\s]+$'), '')
            .trim();
        if (cleaned.isNotEmpty) clinic = cleaned;
      }
    }
    return ScannedDoctor(
      name: name,
      degrees: degreeLines.isEmpty ? null : degreeLines.join(', '),
      specialty: specialty,
      phone: phone,
      clinic: clinic,
    );
  }

  /// Specialty from a line like "Medicine Specialist" or "MBBS, FCPS
  /// (Medicine)", ignoring clinic/address lines ("…Medical College").
  static Specialty? _specialtyIn(String line) {
    if (_clinicWord.hasMatch(line) &&
        !RegExp(
          r'specialist|consultant',
          caseSensitive: false,
        ).hasMatch(line)) {
      return null;
    }
    final inBrackets = RegExp(r'\(([^)]+)\)').firstMatch(line)?.group(1);
    return Specialty.match(inBrackets ?? line.replaceAll(_degree, ''));
  }
}
