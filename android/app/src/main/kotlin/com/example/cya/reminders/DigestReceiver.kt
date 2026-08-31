package com.example.cya.reminders

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.example.cya.MainActivity
import com.example.cya.R
import com.example.cya.capture.CyaStore

/**
 * Posts the weekly review and arms the next one (PRD §5.6).
 *
 * It leads with what the user *kept*, then what is still waiting. A digest that opens with a count
 * of failures is how a memory product turns into a backlog (§12).
 */
class DigestReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_DIGEST) return
        val store = CyaStore(context)
        val open = store.pendingReminders().size
        val kept = store.resolvedSinceStartOfWeek()

        // Nothing captured and nothing kept: say nothing. An empty week does not need a summary.
        if (open == 0 && kept == 0) {
            Log.i(TAG, "digest_skipped (nothing to review)")
        } else {
            show(context, kept = kept, open = open)
            Log.i(TAG, "digest_shown kept=$kept open=$open")
        }
        DigestScheduler.scheduleNext(context)
    }

    private fun show(context: Context, kept: Int, open: Int) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_DIGEST,
                "Weekly review",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "A Sunday look back at the week's promises."
            },
        )

        val title = when {
            kept == 0 -> "A quiet week"
            kept == 1 -> "You kept 1 promise this week"
            else -> "You kept $kept promises this week"
        }
        val body = when {
            open == 0 -> "Nothing left waiting. Enjoy that."
            open == 1 -> "1 promise is still waiting whenever you're ready."
            else -> "$open promises are still waiting whenever you're ready."
        }

        val open_ = PendingIntent.getActivity(
            context,
            REQUEST_CODE,
            Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse("cya://digest")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        manager.notify(
            NOTIFICATION_ID,
            Notification.Builder(context, CHANNEL_DIGEST)
                .setSmallIcon(R.drawable.ic_stat_cya)
                .setContentTitle(title)
                .setContentText(body)
                .setContentIntent(open_)
                .setAutoCancel(true)
                .build(),
        )
    }

    companion object {
        const val ACTION_DIGEST = "com.example.cya.action.DIGEST"
        const val CHANNEL_DIGEST = "cya_digest"
        private const val NOTIFICATION_ID = 80_000
        private const val REQUEST_CODE = 90_001
        private const val TAG = "CyaReminders"
    }
}
