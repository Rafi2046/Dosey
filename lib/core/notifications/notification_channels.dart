import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/painting.dart' show Color;

import '../constants/constants.dart';
import '../database/enums.dart';

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

  static final List<NotificationChannelGroup> groups = [
    NotificationChannelGroup(
      channelGroupKey: AppConstants.channelGroupKey,
      channelGroupName: AppStrings.channelGroupName,
    ),
  ];

  /// (key, name, description, color) of each critical alarm channel.
  static const List<(String, String, String, Color)> _alarmSpecs = [
    (
      AppConstants.channelMedicine,
      AppStrings.channelMedicineName,
      AppStrings.channelMedicineDesc,
      AppColors.medicine,
    ),
    (
      AppConstants.channelAppointment,
      AppStrings.channelAppointmentName,
      AppStrings.channelAppointmentDesc,
      AppColors.appointment,
    ),
    (
      AppConstants.channelVaccine,
      AppStrings.channelVaccineName,
      AppStrings.channelVaccineDesc,
      AppColors.vaccine,
    ),
    (
      AppConstants.channelMedicalTest,
      AppStrings.channelTestName,
      AppStrings.channelTestDesc,
      AppColors.medicalTest,
    ),
  ];

  static List<NotificationChannel> get all => [
    for (final (key, name, description, color) in _alarmSpecs)
      _alarm(key, name, description, color),
    NotificationChannel(
      channelGroupKey: AppConstants.channelGroupKey,
      channelKey: AppConstants.channelGentle,
      channelName: AppStrings.channelGentleName,
      channelDescription: AppStrings.channelGentleDesc,
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
    'groupName': AppStrings.channelGroupName,
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
