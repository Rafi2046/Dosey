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

  static List<NotificationChannel> get all => [
    _alarm(
      AppConstants.channelMedicine,
      AppStrings.channelMedicineName,
      AppStrings.channelMedicineDesc,
      AppColors.medicine,
    ),
    _alarm(
      AppConstants.channelAppointment,
      AppStrings.channelAppointmentName,
      AppStrings.channelAppointmentDesc,
      AppColors.appointment,
    ),
    _alarm(
      AppConstants.channelVaccine,
      AppStrings.channelVaccineName,
      AppStrings.channelVaccineDesc,
      AppColors.vaccine,
    ),
    _alarm(
      AppConstants.channelMedicalTest,
      AppStrings.channelTestName,
      AppStrings.channelTestDesc,
      AppColors.medicalTest,
    ),
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
