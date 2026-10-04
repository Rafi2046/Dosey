import 'package:flutter/services.dart';

import '../domain/prescription_parser.dart';
import '../domain/prescription_header_parser.dart';
import '../domain/scanned_doctor.dart';

/// On-device OCR, no network: Google ML Kit on Android (TextScanner.kt),
/// Apple Vision on iOS (AppDelegate.swift). Then the doctor from the header
/// ([PrescriptionHeaderParser]) and the medicines ([PrescriptionParser]).
class PrescriptionScannerService {
  static const _channel = MethodChannel('dosey/ocr');

  /// The image's text, line by line in reading order.
  Future<List<String>> recognizeLines(String imagePath) async =>
      await _channel.invokeListMethod<String>('recognizeText', imagePath) ??
      const [];

  Future<ScannedPrescription> scan(String imagePath) async {
    final lines = await recognizeLines(imagePath);
    return ScannedPrescription(
      doctor: PrescriptionHeaderParser.parse(lines),
      medicines: PrescriptionParser.parse(lines),
    );
  }
}
