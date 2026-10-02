package com.example.dosey

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

/**
 * Special-access permissions that are granted on a Settings page rather than
 * via a runtime dialog. awesome_notifications tries to request these as
 * runtime permissions (a no-op that never completes), so they're handled here.
 * Keys must match AppPermission names in Dart.
 */
object SpecialPermissions {
    private const val EXACT_ALARMS = "exactAlarms"
    private const val FULL_SCREEN = "fullScreen"
    private const val DND = "dnd"

    fun status(activity: Activity): Map<String, Boolean> {
        val alarms = activity.getSystemService(AlarmManager::class.java)
        val nm = activity.getSystemService(NotificationManager::class.java)
        return mapOf(
            EXACT_ALARMS to (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                alarms.canScheduleExactAlarms()),
            FULL_SCREEN to (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
                nm.canUseFullScreenIntent()),
            DND to nm.isNotificationPolicyAccessGranted,
        )
    }

    /** Opens the most specific Settings page available for [key]. */
    fun openSettings(activity: Activity, key: String) {
        val packageUri = Uri.parse("package:${activity.packageName}")
        val intent = when {
            key == EXACT_ALARMS && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, packageUri)
            key == FULL_SCREEN && Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE ->
                Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, packageUri)
            key == DND -> Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            else -> Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri)
        }
        try {
            activity.startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            // Some OEMs strip the specific pages; fall back to app details.
            activity.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri))
        }
    }
}
