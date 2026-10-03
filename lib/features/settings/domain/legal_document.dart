import '../../../core/constants/app_constants.dart';
import '../../../core/localization/l10n.dart';

/// The in-app legal pages, each a short list of (heading, body) sections.
enum LegalDocument {
  privacy,
  terms,
  disclaimer;

  String title(AppLocalizations l) => switch (this) {
    privacy => l.privacyPolicy,
    terms => l.termsOfUse,
    disclaimer => l.medicalDisclaimer,
  };

  List<(String, String)> sections(AppLocalizations l) => switch (this) {
    privacy => [
      (l.privacyShortTitle, l.privacyShortBody),
      (l.privacyStoredTitle, l.privacyStoredBody),
      (l.privacyScanTitle, l.privacyScanBody),
      (l.privacyPermissionsTitle, l.privacyPermissionsBody),
      (l.privacySharingTitle, l.privacySharingBody),
      (l.privacyDeleteTitle, l.privacyDeleteBody),
      (l.privacyChildrenTitle, l.privacyChildrenBody),
      (l.privacyContactTitle, l.privacyContactBody(AppConstants.supportEmail)),
    ],
    terms => [
      (l.termsUseTitle, l.termsUseBody),
      (l.termsRemindersTitle, l.termsRemindersBody),
      (l.termsWarrantyTitle, l.termsWarrantyBody),
      (l.termsChangesTitle, l.termsChangesBody),
    ],
    disclaimer => [
      (l.disclaimerAdviceTitle, l.disclaimerAdviceBody),
      (l.disclaimerDoctorTitle, l.disclaimerDoctorBody),
      (l.disclaimerEmergencyTitle, l.disclaimerEmergencyBody),
    ],
  };
}
