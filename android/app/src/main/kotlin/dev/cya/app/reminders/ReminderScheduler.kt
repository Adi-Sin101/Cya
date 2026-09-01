package dev.cya.app.reminders

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import dev.cya.app.capture.CyaStore

/**
 * Exact, Doze-resilient reminder scheduling (PRD §5.6).
 *
 * Native on purpose: an alarm must survive the app never being opened, and the capture path
 * schedules the default reminder without ever starting Flutter (§5.4).
 *
 * Alarms carry **only the intention id**. Everything shown to the user is read from the store when
 * the alarm fires, so a reminder can never surface stale content.
 */
internal object ReminderScheduler {

    private const val TAG = "CyaReminders"

    fun schedule(context: Context, intentionId: Long, atMillis: Long) {
        val manager = context.getSystemService(AlarmManager::class.java) ?: return
        val pending = requireNotNull(
            pendingIntent(context, intentionId, PendingIntent.FLAG_UPDATE_CURRENT),
        ) { "FLAG_UPDATE_CURRENT always creates a PendingIntent" }

        // Reminders are this app's core function, so it qualifies for exact alarms — but the
        // permission can still be absent or revoked (Android 12+), and a late reminder beats none.
        val canBeExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            manager.canScheduleExactAlarms()
        try {
            if (canBeExact) {
                manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
            } else {
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
                Log.w(TAG, "inexact_alarm id=$intentionId (exact alarms not permitted)")
            }
        } catch (error: SecurityException) {
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
            Log.w(TAG, "exact_alarm_denied id=$intentionId", error)
        }
        Log.i(TAG, "scheduled id=$intentionId at=$atMillis exact=$canBeExact")
    }

    fun cancel(context: Context, intentionId: Long) {
        val manager = context.getSystemService(AlarmManager::class.java) ?: return
        val pending = pendingIntent(context, intentionId, PendingIntent.FLAG_NO_CREATE)
        if (pending != null) {
            manager.cancel(pending)
            pending.cancel()
            Log.i(TAG, "cancelled id=$intentionId")
        }
    }

    /**
     * Re-arms every pending reminder from the store. Used after a reboot (alarms do not survive
     * one) and whenever the app wants to be sure the OS agrees with the database.
     *
     * A reminder whose time already passed is fired immediately rather than dropped — a late
     * reminder is a bug worth showing; a silently lost one is fatal for a memory product (§12).
     */
    fun rescheduleAll(context: Context): Int {
        val now = System.currentTimeMillis()
        val pending = CyaStore(context).pendingReminders()
        // A promise past the snooze limit belongs to the digest, and ReminderReceiver deliberately
        // shows nothing for it. Re-arming it anyway meant every app resume queued an alarm that
        // fired silently and wrote a `resurfaced` event — an endless loop polluting the very log
        // that gamification and metrics are projected from (ADR-013, defect D-2).
        val armable = pending.filter { it.snoozeCount < CyaStore.MAX_SNOOZES }
        for (promise in armable) {
            val at = promise.reminderAtMillis ?: continue
            schedule(context, promise.id, if (at < now) now + CATCH_UP_DELAY_MILLIS else at)
        }
        // The weekly review rides along: one place that guarantees both kinds of alarm exist.
        DigestScheduler.scheduleNext(context, now)
        Log.i(TAG, "rescheduled count=${armable.size} skipped=${pending.size - armable.size}")
        return armable.size
    }

    private fun pendingIntent(context: Context, intentionId: Long, flags: Int): PendingIntent? {
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ReminderReceiver.ACTION_REMIND
            // A distinct data URI per promise keeps PendingIntents from being deduplicated.
            data = android.net.Uri.parse("cya://reminder/$intentionId")
            putExtra(ReminderReceiver.EXTRA_INTENTION_ID, intentionId)
        }
        return PendingIntent.getBroadcast(
            context,
            intentionId.toInt(),
            intent,
            flags or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** Small delay so a catch-up burst after boot does not all land in the same instant. */
    private const val CATCH_UP_DELAY_MILLIS = 15_000L
}
