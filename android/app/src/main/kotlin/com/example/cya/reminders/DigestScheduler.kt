package com.example.cya.reminders

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import java.util.Calendar

/**
 * The weekly review (PRD §5.6).
 *
 * Escalation's third rung sends a much-postponed promise "to the digest" instead of interrupting
 * again — this is that digest. It is deliberately the *quiet* end of the ladder: a Sunday-evening
 * review moment, not a guilt list (§12).
 *
 * Scheduled one week at a time rather than as a repeating alarm: the receiver arms the next one
 * when it fires, so the schedule survives reboots and time changes without drifting.
 */
internal object DigestScheduler {

    private const val TAG = "CyaReminders"
    private const val REQUEST_CODE = 90_000

    /** Sunday evening — late enough to look back on the week, early enough to act. */
    private const val DIGEST_HOUR = 18

    fun scheduleNext(context: Context, fromMillis: Long = System.currentTimeMillis()) {
        val manager = context.getSystemService(AlarmManager::class.java) ?: return
        val at = nextDigestAt(fromMillis)
        // Inexact on purpose: a weekly review does not need to interrupt to the minute, and an
        // inexact alarm is far kinder to the battery.
        manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pendingIntent(context))
        Log.i(TAG, "digest_scheduled at=$at")
    }

    /** The next Sunday at [DIGEST_HOUR]:00, or today if it is Sunday and still earlier than that. */
    fun nextDigestAt(fromMillis: Long): Long {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = fromMillis
            set(Calendar.HOUR_OF_DAY, DIGEST_HOUR)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val todayAtHour = calendar.timeInMillis
        val isSunday = calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY
        if (isSunday && fromMillis < todayAtHour) return todayAtHour

        var days = (Calendar.SUNDAY - calendar.get(Calendar.DAY_OF_WEEK) + 7) % 7
        if (days == 0) days = 7
        calendar.add(Calendar.DAY_OF_YEAR, days)
        return calendar.timeInMillis
    }

    private fun pendingIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
        context,
        REQUEST_CODE,
        Intent(context, DigestReceiver::class.java).apply {
            action = DigestReceiver.ACTION_DIGEST
            data = Uri.parse("cya://digest")
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
}
