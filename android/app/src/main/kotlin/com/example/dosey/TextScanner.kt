package com.example.dosey

import android.content.Context
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * On-device OCR for prescription scans (ML Kit, Latin script, no network).
 * Returns the text line by line in reading order, like the iOS (Vision)
 * side in AppDelegate.swift, so the Dart parsers see the same thing.
 */
object TextScanner {
    const val CHANNEL = "dosey/ocr"

    fun recognize(context: Context, path: String, result: MethodChannel.Result) {
        val image = try {
            InputImage.fromFilePath(context, Uri.fromFile(File(path)))
        } catch (e: Exception) {
            result.error("ocr", e.message, null)
            return
        }
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        recognizer.process(image)
            .addOnSuccessListener { text ->
                result.success(text.textBlocks.flatMap { block -> block.lines.map { it.text } })
            }
            .addOnFailureListener { e -> result.error("ocr", e.message, null) }
            .addOnCompleteListener { recognizer.close() }
    }
}
