import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/prescription_parser.dart';
import '../domain/scanned_medicine.dart';

/// On-device OCR (ML Kit, Latin script, no network) + [PrescriptionParser].
class PrescriptionScannerService {
  Future<List<ScannedMedicine>> scan(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return PrescriptionParser.parse([
        for (final block in text.blocks)
          for (final line in block.lines) line.text,
      ]);
    } finally {
      await recognizer.close();
    }
  }
}
