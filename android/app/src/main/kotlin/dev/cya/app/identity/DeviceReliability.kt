package dev.cya.app.identity

import android.app.AlarmManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log

/**
 * The OEM settings that decide whether a reminder ever fires (PRD §12, defect D-4).
 *
 * Android's guarantees stop at the OEM. On MIUI/HyperOS, Autostart is **off by default for
 * sideloaded apps**, so `BOOT_COMPLETED` is never delivered and one reboot silently drops every
 * pending alarm. Samsung's "put unused apps to sleep" does the same job under another name. Neither
 * is readable and neither is settable — the only thing an app can do is open the right screen and
 * be honest about the rest, which is what the onboarding checklist does.
 */
internal object DeviceReliability {

    private const val TAG = "CyaReliability"

    /** The snapshot handed to Dart. Keys match `DeviceReliabilityPort`. */
    fun snapshot(context: Context): Map<String, Any?> = mapOf(
        "oem" to oemKey(),
        "manufacturer" to Build.MANUFACTURER.replaceFirstChar(Char::uppercase),
        "osLabel" to osLabel(),
        "batteryUnrestricted" to isIgnoringBatteryOptimizations(context),
        "exactAlarms" to canScheduleExactAlarms(context),
        "notifications" to hasNotificationPermission(context),
    )

    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val manager = context.getSystemService(PowerManager::class.java) ?: return true
        return manager.isIgnoringBatteryOptimizations(context.packageName)
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val manager = context.getSystemService(AlarmManager::class.java) ?: return false
        return manager.canScheduleExactAlarms()
    }

    fun hasNotificationPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
    }

    /**
     * Opens the OEM's autostart list, trying each known component in turn.
     *
     * These activities are undocumented and get renamed between skin versions, so every candidate
     * is resolved before it is launched and a miss is reported rather than thrown — the UI then
     * tells the user where to look by hand.
     */
    fun openAutostart(context: Context): Boolean {
        for (component in autostartComponents()) {
            val intent = Intent().setComponent(component).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (resolves(context, intent) && start(context, intent)) return true
        }
        Log.w(TAG, "no_autostart_screen manufacturer=${Build.MANUFACTURER}")
        return false
    }

    /**
     * Asks to be exempt from battery optimisation.
     *
     * The direct request dialog needs REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, which Play restricts to
     * apps whose core function genuinely requires it. Reminders are exactly that (PRD §3.4), but
     * the safer route is the system list — it needs no permission and cannot get the listing
     * flagged, at the cost of two extra taps.
     */
    fun openBatterySettings(context: Context): Boolean {
        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (resolves(context, intent) && start(context, intent)) return true
        return openAppSettings(context)
    }

    /** This app's own settings page — the fallback that exists on every device. */
    fun openAppSettings(context: Context): Boolean {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", context.packageName, null),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return start(context, intent)
    }

    private fun oemKey(): String = when (Build.MANUFACTURER.lowercase()) {
        // Poco and Redmi are Xiaomi sub-brands and report themselves as such,
        // but a device that names itself directly must match too.
        "xiaomi", "poco", "redmi" -> "xiaomi"
        "samsung" -> "samsung"
        "oppo", "realme" -> "oppo"
        "vivo" -> "vivo"
        "huawei", "honor" -> "huawei"
        "oneplus" -> "oneplus"
        else -> "other"
    }

    /** The skin's marketing name, where it can be told apart from stock Android. */
    private fun osLabel(): String = when (oemKey()) {
        // MIUI became HyperOS at Android 14; both hide Autostart in the same place.
        "xiaomi" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            "HyperOS"
        } else {
            "MIUI"
        }
        "samsung" -> "One UI"
        "oppo" -> "ColorOS"
        "vivo" -> "Funtouch"
        "huawei" -> "EMUI"
        "oneplus" -> "OxygenOS"
        else -> ""
    }

    private fun autostartComponents(): List<ComponentName> = when (oemKey()) {
        "xiaomi" -> listOf(
            ComponentName(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity",
            ),
        )
        "samsung" -> listOf(
            ComponentName(
                "com.samsung.android.lool",
                "com.samsung.android.sm.battery.ui.BatteryActivity",
            ),
            ComponentName(
                "com.samsung.android.lool",
                "com.samsung.android.sm.ui.battery.BatteryActivity",
            ),
        )
        "oppo" -> listOf(
            ComponentName(
                "com.coloros.safecenter",
                "com.coloros.safecenter.permission.startup.StartupAppListActivity",
            ),
            ComponentName(
                "com.coloros.safecenter",
                "com.coloros.safecenter.startupapp.StartupAppListActivity",
            ),
        )
        "vivo" -> listOf(
            ComponentName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
            ),
        )
        "huawei" -> listOf(
            ComponentName(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
            ),
        )
        "oneplus" -> listOf(
            ComponentName(
                "com.oneplus.security",
                "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity",
            ),
        )
        else -> emptyList()
    }

    private fun resolves(context: Context, intent: Intent): Boolean =
        intent.resolveActivity(context.packageManager) != null

    private fun start(context: Context, intent: Intent): Boolean = runCatching {
        context.startActivity(intent)
        true
    }.getOrElse {
        // A component can resolve and still refuse to launch — several OEMs guard these
        // activities with a permission they never granted to third-party apps.
        Log.w(TAG, "settings_launch_failed intent=${intent.component}", it)
        false
    }
}
