package com.example.cya

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.example.cya.reminders.ReminderNotifications
import com.example.cya.reminders.ReminderScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The Flutter host.
 *
 * It owns exactly two bridges, both of which exist so the app and the native surfaces agree:
 * scheduling (the app must use the *same* AlarmManager the capture path uses) and deep links from a
 * reminder notification into the promise it is about.
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null
    private var pendingDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ReminderNotifications.ensureChannels(this)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedule" -> {
                        val id = call.argument<Number>("id")?.toLong()
                        val at = call.argument<Number>("atMillis")?.toLong()
                        if (id == null || at == null) {
                            result.error("bad_args", "id and atMillis are required", null)
                        } else {
                            ReminderScheduler.schedule(this, id, at)
                            result.success(null)
                        }
                    }

                    "cancel" -> {
                        val id = call.argument<Number>("id")?.toLong()
                        if (id == null) {
                            result.error("bad_args", "id is required", null)
                        } else {
                            ReminderScheduler.cancel(this, id)
                            result.success(null)
                        }
                    }

                    // Re-arms every pending reminder from the store: cheap insurance against an
                    // OEM that dropped alarms while the app was away (PRD §12).
                    "rescheduleAll" -> result.success(ReminderScheduler.rescheduleAll(this))

                    "canScheduleExact" -> result.success(canScheduleExactAlarms())

                    "ensureNotificationPermission" ->
                        result.success(ensureNotificationPermission())

                    "openExactAlarmSettings" -> {
                        openExactAlarmSettings()
                        result.success(null)
                    }

                    "consumeInitialDeepLink" -> {
                        result.success(pendingDeepLink)
                        pendingDeepLink = null
                    }

                    else -> result.notImplemented()
                }
            }
        }

        pendingDeepLink = deepLinkFrom(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val link = deepLinkFrom(intent) ?: return
        // If Dart is already running it routes immediately; otherwise it asks on startup.
        channel?.invokeMethod("onDeepLink", link) ?: run { pendingDeepLink = link }
    }

    /** `cya://promise/<id>` — sent by a reminder notification. */
    private fun deepLinkFrom(intent: Intent?): String? {
        val data = intent?.data ?: return null
        return if (data.scheme == "cya") data.toString() else null
    }

    /**
     * Asks for POST_NOTIFICATIONS the first time it matters — the app calls this right after a
     * capture, when the reason ("I'll bring this back tonight") is on screen (PRD §3.5).
     */
    private fun ensureNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        val permission = android.Manifest.permission.POST_NOTIFICATIONS
        val granted = checkSelfPermission(permission) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED
        if (!granted) requestPermissions(arrayOf(permission), NOTIFICATION_PERMISSION_REQUEST)
        return granted
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val manager = getSystemService(android.app.AlarmManager::class.java)
        return manager?.canScheduleExactAlarms() ?: false
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        runCatching {
            startActivity(
                Intent(
                    Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                    Uri.parse("package:$packageName"),
                ),
            )
        }
    }

    private companion object {
        const val CHANNEL = "cya/reminders"
        const val NOTIFICATION_PERMISSION_REQUEST = 1001
    }
}
