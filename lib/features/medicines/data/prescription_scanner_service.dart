import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/prescription_parser.dart';
import '../domain/prescription_header_parser.dart';
import '../domain/scanned_doctor.dart';

/// On-device OCR (ML Kit, Latin script, no network), then the doctor from
/// the header ([PrescriptionHeaderParser]) and the medicines
/// ([PrescriptionParser]).
class PrescriptionScannerService {
  Future<ScannedPrescription> scan(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final lines = [
        for (final block in text.blocks)
          for (final line in block.lines) line.text,
      ];
      return ScannedPrescription(
        doctor: PrescriptionHeaderParser.parse(lines),
        medicines: PrescriptionParser.parse(lines),
      );
    } finally {
      await recognizer.close();
    }
  }
}
