package com.example.dosey

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import dev.fluttercommunity.plus.androidalarmmanager.AlarmService

/**
 * AlarmManager forgets every alarm on reboot, and wall-clock alarms drift when
 * the timezone changes. On those events we run the Dart `onAlarmCallback` with
 * the reserved resync id; it recomputes every reminder's next trigger from the
 * Drift database and re-arms all alarms.
 *
 * The callback is executed through android_alarm_manager_plus' background
 * isolate (same extras contract as its AlarmBroadcastReceiver).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in TRIGGERS) return

        val handle = prefs(context).getLong(KEY_RESYNC_HANDLE, 0L)
        if (handle == 0L) {
            Log.w(TAG, "No resync handle yet (app never opened); skipping ${intent.action}")
            return
        }
        Log.i(TAG, "Resyncing alarms after ${intent.action}")
        val work = Intent()
            .putExtra("id", RESYNC_ALARM_ID)
            .putExtra("callbackHandle", handle)
            .putExtra("params", "{}")
        AlarmService.enqueueAlarmProcessing(context, work)
    }

    companion object {
        private const val TAG = "DoseyBoot"
        private const val PREFS = "dosey_native"
        private const val KEY_RESYNC_HANDLE = "resync_callback_handle"

        /** Must match AppConstants.resyncAlarmId. */
        private const val RESYNC_ALARM_ID = 2000000000

        private val TRIGGERS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            "android.intent.action.QUICKBOOT_POWERON",
        )

        private fun prefs(context: Context) =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        fun saveResyncHandle(context: Context, handle: Long) {
            prefs(context).edit().putLong(KEY_RESYNC_HANDLE, handle).apply()
        }
    }
}
