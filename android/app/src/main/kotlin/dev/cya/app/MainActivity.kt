package dev.cya.app

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import dev.cya.app.reminders.ReminderNotifications
import dev.cya.app.reminders.ReminderScheduler
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

                    // Hands a captured promise's deep link back to the OS, so
                    // "Open in <app>" returns the user where they saved it
                    // (PRD 3.4). Reports whether anything could handle it, so
                    // Dart can say so rather than appearing to do nothing.
                    "openLink" -> {
                        val link = call.argument<String>("link")
                        result.success(link != null && openExternal(link))
                    }

                    // The launcher icon of the app a promise was shared from, as PNG bytes.
                    // Dart caches these; see AppIconCache.
                    "appIcon" -> {
                        val packageName = call.argument<String>("package")
                        result.success(packageName?.let(::launcherIconPng))
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

    /**
     * Opens a captured link in whatever app owns it.
     *
     * NEW_TASK so the target app gets its own entry in recents rather than being stacked inside
     * Cya! — the user is leaving to do the thing, not browsing inside a promise manager.
     */
    private fun openExternal(link: String): Boolean = runCatching {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent.resolveActivity(packageManager) == null) return false
        startActivity(intent)
        true
    }.getOrDefault(false)

    /**
     * Renders [packageName]'s launcher icon to PNG bytes, or null if the app is not installed.
     *
     * Rasterised here rather than shipped as a drawable because adaptive icons are layered
     * `Drawable`s with no file to read, and because the size is fixed at the call site: a promise
     * row shows a 46dp badge, so a 144px bitmap covers every density we care about without sending
     * a full-resolution icon over the channel for every row.
     */
    private fun launcherIconPng(packageName: String): ByteArray? = runCatching {
        val drawable: Drawable = packageManager.getApplicationIcon(packageName)
        val bitmap = (drawable as? BitmapDrawable)?.bitmap?.takeIf { !it.isRecycled }
            ?: Bitmap.createBitmap(ICON_PX, ICON_PX, Bitmap.Config.ARGB_8888).also { output ->
                val canvas = Canvas(output)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
            }
        java.io.ByteArrayOutputStream().use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        }
    }.getOrNull()

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

        /** Comfortably above the 46dp badge on an xxhdpi screen. */
        const val ICON_PX = 144
    }
}
