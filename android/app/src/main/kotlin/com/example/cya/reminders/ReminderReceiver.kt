package com.example.cya.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.cya.capture.CyaStore

/**
 * Fires when a promise comes due (PRD §5.6).
 *
 * Reads current state from the shared store rather than trusting the alarm's payload, so a promise
 * resolved on another surface never resurfaces, and the escalation tier is always computed from
 * what the user actually did.
 */
class ReminderReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getLongExtra(EXTRA_INTENTION_ID, -1L)
        if (id <= 0) return

        val store = CyaStore(context)
        val promise = store.findById(id)
        if (promise == null || !promise.isPending) {
            // Already resolved, archived or deleted — dropping this silently is correct.
            Log.i(TAG, "skipped id=$id (no longer pending)")
            return
        }

        val tier = ReminderNotifications.tierFor(promise)
        // Past the snooze limit Cya! stops interrupting: the promise belongs to the digest.
        if (tier != ReminderNotifications.Tier.DIGEST) {
            ReminderNotifications.show(context, promise, tier)
        }
        // Logged either way — a resurfacing that was deliberately quiet still happened, and
        // reminder reliability (§9.2) is measured from these events.
        store.markResurfaced(id, System.currentTimeMillis(), tier.wire)
        Log.i(TAG, "resurfaced id=$id tier=${tier.wire}")
    }

    companion object {
        const val ACTION_REMIND = "com.example.cya.action.REMIND"
        const val EXTRA_INTENTION_ID = "intention_id"
        private const val TAG = "CyaReminders"
    }
}
