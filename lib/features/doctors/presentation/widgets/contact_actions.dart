import 'package:url_launcher/url_launcher.dart';

/// Opens the dialer / mail app for a doctor's contact details.
abstract final class ContactActions {
  static Future<void> call(String phone) =>
      launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  static Future<void> email(String address) =>
      launchUrl(Uri(scheme: 'mailto', path: address));
}
