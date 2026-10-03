/// Doctors list, detail and form text.
abstract final class DoctorStrings {
  static const String doctors = 'Doctors';
  static const String addDoctor = 'Add doctor';
  static const String editDoctor = 'Edit doctor';
  static const String doctorName = 'Name';
  static const String doctorSpecialty = 'Specialty';
  static const String doctorPhone = 'Phone';
  static const String doctorEmail = 'Email';
  static const String doctorClinic = 'Clinic / hospital';
  static const String doctorAddress = 'Address';
  static const String doctorFee = 'Consultation fee';
  static const String doctorNotes = 'Notes';
  static const String noDoctors = 'No doctors added';
  static const String doctorsTitle = 'Your\nDoctors';
  static const String prescribedMedicines = 'Prescribed medicines';
  static const String doctorRecords = 'Records';
  static const String doctorAppointments = 'Appointments';
  static const String unarchive = 'Restore';
  static const String addAppointment = 'Add appointment';
  static const String deleteDoctorBody =
      'Medicines and records stay, but will no longer be linked to this doctor.';
  static String activeMedicines(int n) =>
      n == 1 ? '1 active medicine' : '$n active medicines';
}
