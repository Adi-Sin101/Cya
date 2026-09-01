package dev.cya.app

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import dev.cya.app.identity.BiometricGate
import dev.cya.app.identity.DatabaseKey
import dev.cya.app.identity.DeviceReliability
import dev.cya.app.privacy.DocumentShare
import dev.cya.app.reminders.DraftHandoff
import dev.cya.app.reminders.ReminderNotifications
import dev.cya.app.reminders.ReminderScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The Flutter host.
 *
 * Every bridge here exists because the app and the native surfaces have to agree about something:
 * scheduling (the app must use the *same* AlarmManager the capture path uses), deep links from a
 * reminder notification into the promise it is about, whether this device will let an alarm fire at
 * all (PRD §12), and the biometric prompt behind the app lock (ADR-010).
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null
    private var pendingDeepLink: String? = null

    /**
     * The in-flight notification permission request.
     *
     * Held because the system answer arrives on a different callback than the one that asked, and
     * onboarding shows a permission screen that has to reflect the real outcome — replying
     * "denied" the moment the dialog opens, as the first version did, made every first grant look
     * like a refusal.
     */
    private var pendingPermissionResult: MethodChannel.Result? = null

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
                        ensureNotificationPermission(result)

                    // --- Local identity + device reliability (ADR-010, PRD §12) ---

                    "deviceReliability" ->
                        result.success(DeviceReliability.snapshot(this))

                    "openAutostartSettings" ->
                        result.success(DeviceReliability.openAutostart(this))

                    "openBatterySettings" ->
                        result.success(DeviceReliability.openBatterySettings(this))

                    "openAppSettings" ->
                        result.success(DeviceReliability.openAppSettings(this))

                    // The raw SQLCipher key for the shared store (ADR-010). Kotlin owns it
                    // because Kotlin owns the Android Keystore; Dart needs the same bytes to
                    // open the same file. It never leaves the process — there is no network
                    // permission for it to leave through.
                    "databaseKey" -> result.success(DatabaseKey.rawKey(this))

                    "biometricAvailability" ->
                        result.success(BiometricGate.availability(this))

                    "biometricAuthenticate" -> BiometricGate.authenticate(
                        activity = this,
                        title = call.argument<String>("title") ?: "Unlock Cya!",
                        subtitle = call.argument<String>("subtitle") ?: "",
                        negativeLabel = call.argument<String>("negative") ?: "Use PIN",
                        onResult = result::success,
                    )

                    // --- Data export (PRD 9.3) ---

                    "shareDocument" -> result.success(
                        DocumentShare.share(
                            activity = this,
                            fileName = call.argument<String>("fileName")
                                ?: "cya-export.json",
                            content = call.argument<String>("content").orEmpty(),
                            mimeType = call.argument<String>("mimeType")
                                ?: "application/json",
                            title = call.argument<String>("title") ?: "Your Cya! data",
                        ),
                    )

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

                    // Opens the source app with the reply already written (ADR-015).
                    // Cya! never sends it — see DraftHandoff for why that is a
                    // product decision, not a platform limitation we regret.
                    "openDraft" -> result.success(
                        DraftHandoff.open(
                            context = this,
                            draft = call.argument<String>("draft").orEmpty(),
                            packageName = call.argument<String>("package"),
                            link = call.argument<String>("link"),
                        ),
                    )

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
     * Asks for POST_NOTIFICATIONS at a moment when the reason for it is on screen — after a
     * capture, or on the onboarding step that shows the reminder it would post (PRD §3.5).
     *
     * Replies only once the user has answered. A second request while one is in flight resolves
     * the first as denied rather than leaking it, so no caller is left awaiting forever.
     */
    private fun ensureNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        val permission = android.Manifest.permission.POST_NOTIFICATIONS
        if (checkSelfPermission(permission) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        pendingPermissionResult?.success(false)
        pendingPermissionResult = result
        requestPermissions(arrayOf(permission), NOTIFICATION_PERMISSION_REQUEST)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    private fun canScheduleExactAlarms(): Boolean =
        DeviceReliability.canScheduleExactAlarms(this)

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
