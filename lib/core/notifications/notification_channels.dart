import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/painting.dart' show Color;

import '../constants/constants.dart';
import '../database/enums.dart';
import '../localization/l10n.dart';

/// Channel definitions. One critical alarm channel per reminder type (so users
/// can tune each in system settings) plus a gentle channel that respects DND.
abstract final class NotificationChannels {
  static String keyFor(ReminderType type, {required bool critical}) {
    if (!critical) return AppConstants.channelGentle;
    return switch (type) {
      ReminderType.medicine => AppConstants.channelMedicine,
      ReminderType.appointment => AppConstants.channelAppointment,
      ReminderType.vaccine => AppConstants.channelVaccine,
      ReminderType.medicalTest => AppConstants.channelMedicalTest,
    };
  }

  // Getters, not constants: names follow the app language (AppLocale) at the
  // time the channels are registered.
  static List<NotificationChannelGroup> get groups => [
    NotificationChannelGroup(
      channelGroupKey: AppConstants.channelGroupKey,
      channelGroupName: AppLocale.l10n.channelGroupName,
    ),
  ];

  /// (key, name, description, color) of each critical alarm channel.
  static List<(String, String, String, Color)> get _alarmSpecs => [
    (
      AppConstants.channelMedicine,
      AppLocale.l10n.channelMedicineName,
      AppLocale.l10n.channelMedicineDesc,
      AppColors.medicine,
    ),
    (
      AppConstants.channelAppointment,
      AppLocale.l10n.channelAppointmentName,
      AppLocale.l10n.channelAppointmentDesc,
      AppColors.appointment,
    ),
    (
      AppConstants.channelVaccine,
      AppLocale.l10n.channelVaccineName,
      AppLocale.l10n.channelVaccineDesc,
      AppColors.vaccine,
    ),
    (
      AppConstants.channelMedicalTest,
      AppLocale.l10n.channelTestName,
      AppLocale.l10n.channelTestDesc,
      AppColors.medicalTest,
    ),
  ];

  static List<NotificationChannel> get all => [
    for (final (key, name, description, color) in _alarmSpecs)
      _alarm(key, name, description, color),
    NotificationChannel(
      channelGroupKey: AppConstants.channelGroupKey,
      channelKey: AppConstants.channelGentle,
      channelName: AppLocale.l10n.channelGentleName,
      channelDescription: AppLocale.l10n.channelGentleDesc,
      importance: NotificationImportance.High,
      defaultRingtoneType: DefaultRingtoneType.Notification,
      defaultColor: AppColors.accent,
      ledColor: AppColors.accent,
      channelShowBadge: true,
    ),
  ];

  /// Arguments for the native pre-creation of alarm channels with
  /// USAGE_ALARM audio (see AlarmChannels.kt).
  static Map<String, Object> get nativeAlarmChannelArgs => {
    'groupKey': AppConstants.channelGroupKey,
    'groupName': AppLocale.l10n.channelGroupName,
    'keep': [for (final c in all) c.channelKey!],
    'channels': [
      for (final (key, name, description, color) in _alarmSpecs)
        {
          'id': key,
          'name': name,
          'description': description,
          'color': color.toARGB32(),
          'vibration': AppConstants.alarmVibrationPattern,
        },
    ],
  };

  /// Max importance + alarm ringtone + `criticalAlerts`, which lets the
  /// channel bypass DND once the user grants Do Not Disturb access.
  static NotificationChannel _alarm(
    String key,
    String name,
    String description,
    Color color,
  ) => NotificationChannel(
    channelGroupKey: AppConstants.channelGroupKey,
    channelKey: key,
    channelName: name,
    channelDescription: description,
    importance: NotificationImportance.Max,
    defaultRingtoneType: DefaultRingtoneType.Alarm,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList(AppConstants.alarmVibrationPattern),
    enableLights: true,
    ledColor: color,
    defaultColor: color,
    criticalAlerts: true,
    locked: true,
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Private,
  );
}
