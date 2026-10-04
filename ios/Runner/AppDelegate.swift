import Flutter
import UIKit
import Vision
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Taken / Snooze / Skip buttons run Dart in a headless engine while the
    // app is closed; give that engine the same plugins as the main one.
    // Notification permission and the UNUserNotificationCenter delegate are
    // handled by awesome_notifications from Dart — don't set them here.
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TextScanner") {
      TextScanner.register(with: registrar)
    }
  }
}

/// On-device OCR for prescription scans with Apple's Vision framework (no
/// network, nothing to download). Returns the text line by line in reading
/// order, like the Android (ML Kit) side in TextScanner.kt.
final class TextScanner: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "dosey/ocr", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(TextScanner(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognizeText", let path = call.arguments as? String else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let image = UIImage(contentsOfFile: path), let cgImage = image.cgImage else {
      result(FlutterError(code: "ocr", message: "Could not open the image", details: nil))
      return
    }
    let request = VNRecognizeTextRequest { request, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "ocr", message: error.localizedDescription, details: nil))
        }
        return
      }
      let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
      // Top to bottom (Vision's y grows upwards), then left to right.
      let ordered = observations.sorted { a, b in
        let dy = a.boundingBox.midY - b.boundingBox.midY
        return abs(dy) > 0.01 ? dy > 0 : a.boundingBox.minX < b.boundingBox.minX
      }
      let lines = ordered.compactMap { $0.topCandidates(1).first?.string }
      DispatchQueue.main.async { result(lines) }
    }
    request.recognitionLevel = .accurate
    // Medicine names aren't dictionary words: don't "correct" them.
    request.usesLanguageCorrection = false
    let handler = VNImageRequestHandler(
      cgImage: cgImage, orientation: Self.orientation(image.imageOrientation), options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "ocr", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private static func orientation(_ o: UIImage.Orientation) -> CGImagePropertyOrientation {
    switch o {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}
