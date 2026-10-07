<p align="center">
  <img src="assets/branding/app_icon.png" width="120" alt="Dosey app icon: a capsule with a clock">
</p>

<h1 align="center">Dosey: Medicine Reminder</h1>

<p align="center">
  A medicine reminder and pill tracker app in English and Bangla (বাংলা),<br>
  with alarms that really ring, prescription scanning, and family sharing.
</p>

---

Dosey reminds you to take your medicines on time and keeps your health records in one place. It works fully offline: your data stays on your phone. Family Sharing, which lets a family member follow your doses, is the only part that uses the internet.

## Features

- **Medicine reminders with real alarms.** Full-screen alarms that ring even when the app is closed, with snooze, and one screen for medicines due together.
- **Prescription scanning.** Take a photo of a prescription and Dosey fills in the medicines and the doctor.
- **Bangladesh medicine list.** Medicine name suggestions from a built-in Bangladeshi medicine database.
- **Stock and cost tracking.** Know when a medicine is running low and how much you spend.
- **Health tracking.** Blood pressure and blood sugar logs, doctors, appointments and medical records.
- **Health report.** A summary to show your doctor.
- **Family Sharing (caregiver mode).** A family member can see whether you took your doses and send you a gentle reminder.
- **Multiple profiles.** Manage medicines for parents or children from one phone.
- **Private by design.** Offline-first, app lock with fingerprint, face or PIN, and backup and restore to a file.
- **English and Bangla.** The whole app switches language, including numbers and dates.

## Built with

Flutter, Riverpod, Drift (SQLite), awesome_notifications and android_alarm_manager_plus. Family Sharing uses Firebase Authentication and Supabase (Postgres with row-level security, Realtime and Edge Functions).

## Development

```bash
flutter pub get
flutter run
```

Family Sharing needs Supabase credentials passed with `--dart-define` (see `lib/core/cloud/cloud_config.dart`). Without them the app runs in offline mode.

Database changes for Family Sharing live in `supabase/migrations/` and are applied with `supabase db push`.

The app icon, splash and illustrations are drawn in code: `python3 tool/illustrations/render.py`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
