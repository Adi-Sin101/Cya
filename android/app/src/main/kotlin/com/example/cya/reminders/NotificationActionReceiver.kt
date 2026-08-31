package com.example.cya.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.cya.capture.CyaStore
import com.example.cya.widget.CyaWidgetProvider

/**
 * One-tap resolution and snooze straight from the notification (PRD §3.4, §8.4).
 *
 * Writes to the shared store the same native-thin way capture does — closing the loop must never
 * require booting the app. The reactive UI sees the change the next time it runs, because the store
 * is the single source of truth (§3.3).
 */
class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getLongExtra(ReminderReceiver.EXTRA_INTENTION_ID, -1L)
        if (id <= 0) return
        val store = CyaStore(context)
        val now = System.currentTimeMillis()

        when (intent.action) {
            ACTION_DONE -> {
                val resolved = store.resolve(id, now)
                ReminderNotifications.dismiss(context, id)
                ReminderScheduler.cancel(context, id)
                CyaWidgetProvider.refresh(context)
                Log.i(TAG, "notification_done id=$id resolved=$resolved")
            }

            ACTION_SNOOZE -> {
                val until = now + DEFAULT_SNOOZE_MILLIS
                val snoozed = store.snooze(id, until, now)
                ReminderNotifications.dismiss(context, id)
                if (snoozed) {
                    ReminderScheduler.schedule(context, id, until)
                } else {
                    // The domain refuses a fourth snooze (PRD §5.6). Say so plainly instead of
                    // silently doing nothing — and say it quietly: past the limit Cya! stops
                    // interrupting and starts asking to close the loop.
                    store.findById(id)?.let {
                        ReminderNotifications.show(
                            context,
                            it,
                            ReminderNotifications.Tier.QUIET,
                            "You've pushed this back ${it.snoozeCount} times. " +
                                "Finish it, or let it go.",
                        )
                    }
                }
                CyaWidgetProvider.refresh(context)
                Log.i(TAG, "notification_snooze id=$id granted=$snoozed")
            }
        }
    }

    companion object {
        const val ACTION_DONE = "com.example.cya.action.DONE"
        const val ACTION_SNOOZE = "com.example.cya.action.SNOOZE"

        /** Mirrors `SnoozePolicy.defaultSnooze`. */
        private const val DEFAULT_SNOOZE_MILLIS = 3L * 60 * 60 * 1000
        private const val TAG = "CyaReminders"
    }
}
