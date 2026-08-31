package dev.cya.app.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Alarms do not survive a reboot, so they are re-armed from the store (PRD §5.6, §9.2 reminder
 * reliability). Without this, every promise scheduled before a restart would be silently lost —
 * the one failure a memory product cannot have.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            -> ReminderScheduler.rescheduleAll(context)
        }
    }
}
