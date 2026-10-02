package com.example.dosey

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings
import android.util.Log

/**
 * awesome_notifications hard-codes USAGE_NOTIFICATION for channel sounds, which
 * is muted by silent mode / notification volume. Alarm channels are therefore
 * created here first with USAGE_ALARM: Android freezes a channel's sound and
 * audio attributes after creation, so awesome's later create/update calls keep
 * ours. Specs come from Dart (NotificationChannels) so there's one source of truth.
 */
object AlarmChannels {
    private const val TAG = "DoseyChannels"
    private const val OWN_PREFIX = "dosey_"

    @Suppress("UNCHECKED_CAST")
    fun ensure(context: Context, args: Map<String, Any?>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(NotificationManager::class.java)

        val groupKey = args["groupKey"] as String
        nm.createNotificationChannelGroup(
            NotificationChannelGroup(groupKey, args["groupName"] as String),
        )

        // Remove superseded channels (e.g. *_v1 created with notification audio).
        val keep = (args["keep"] as List<String>).toSet()
        nm.notificationChannels
            .filter { it.id.startsWith(OWN_PREFIX) && it.id !in keep }
            .forEach {
                Log.i(TAG, "Deleting stale channel ${it.id}")
                nm.deleteNotificationChannel(it.id)
            }

        val alarmAudio = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        // Honored only with Do Not Disturb access; re-sent on every launch so
        // granting access later upgrades existing channels.
        val canBypassDnd = nm.isNotificationPolicyAccessGranted

        for (spec in args["channels"] as List<Map<String, Any?>>) {
            val channel = NotificationChannel(
                spec["id"] as String,
                spec["name"] as String,
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = spec["description"] as String
                group = groupKey
                setSound(Settings.System.DEFAULT_ALARM_ALERT_URI, alarmAudio)
                enableVibration(true)
                vibrationPattern = (spec["vibration"] as List<Number>)
                    .map { it.toLong() }.toLongArray()
                enableLights(true)
                lightColor = (spec["color"] as Number).toInt()
                lockscreenVisibility = Notification.VISIBILITY_PRIVATE
                setBypassDnd(canBypassDnd)
            }
            nm.createNotificationChannel(channel)
        }
        Log.i(TAG, "Alarm channels ensured (bypassDnd=$canBypassDnd)")
    }
}
