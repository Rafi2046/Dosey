package com.example.dosey

import android.app.KeyguardManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Shows over the lock screen ONLY when launched by a Dosey notification while
 * the device is locked (i.e. a ringing alarm's full-screen intent). Flutter
 * turns this off again as soon as no alarm is ringing, so the rest of the app
 * (medical data) is never reachable without unlocking.
 */
class MainActivity : FlutterActivity() {
    private var launchedOverLockScreen = false

    override fun onCreate(savedInstanceState: Bundle?) {
        applyLockScreenPolicy(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        applyLockScreenPolicy(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setShowOverLockScreen" -> {
                        setShowOverLockScreen(call.arguments as Boolean)
                        result.success(null)
                    }
                    "wasLaunchedOverLockScreen" -> result.success(launchedOverLockScreen)
                    "ensureAlarmChannels" -> {
                        @Suppress("UNCHECKED_CAST")
                        AlarmChannels.ensure(this, call.arguments as Map<String, Any?>)
                        result.success(null)
                    }
                    "registerResyncHandle" -> {
                        BootReceiver.saveResyncHandle(this, (call.arguments as Number).toLong())
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun applyLockScreenPolicy(intent: Intent?) {
        val keyguard = getSystemService(KeyguardManager::class.java)
        val fromNotification = intent?.action in NOTIFICATION_ACTIONS
        launchedOverLockScreen = fromNotification && keyguard?.isKeyguardLocked == true
        Log.d(TAG, "launch action=${intent?.action} overLock=$launchedOverLockScreen")
        if (launchedOverLockScreen) setShowOverLockScreen(true)
    }

    private fun setShowOverLockScreen(show: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(flags) else window.clearFlags(flags)
        }
        if (!show) launchedOverLockScreen = false
    }

    companion object {
        private const val TAG = "DoseyMain"
        private const val CHANNEL = "dosey/native"

        /** Intent actions awesome_notifications uses to open the app. */
        private val NOTIFICATION_ACTIONS = setOf("SELECT_NOTIFICATION", "ACTION_NOTIFICATION")
    }
}
