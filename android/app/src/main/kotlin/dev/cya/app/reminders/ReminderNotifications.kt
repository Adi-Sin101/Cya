package dev.cya.app.reminders

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import dev.cya.app.MainActivity
import dev.cya.app.R
import dev.cya.app.capture.CyaStore

/**
 * How a promise comes back (PRD §5.6 escalation, §8.4 one-tap resolution).
 *
 * The escalation ladder mirrors `SnoozePolicy.tierFor`: the more often a promise has been pushed
 * away, the more prominent it becomes — until it passes the snooze limit, at which point Cya! stops
 * interrupting altogether and the promise belongs to the digest. The third rung is *quieter*, not
 * louder: nagging is how a memory product becomes a second backlog (§12).
 */
internal object ReminderNotifications {

    const val CHANNEL_QUIET = "cya_reminders_quiet"
    const val CHANNEL_BANNER = "cya_reminders_banner"

    /** Every due-promise notification joins this group so the shade shows one card, not N. */
    private const val GROUP_REMINDERS = "dev.cya.app.reminders"

    /** Distinct from any promise id (they are row ids) and from the digest's 80_000. */
    private const val SUMMARY_ID = 70_000

    enum class Tier(val wire: String) { QUIET("quiet"), BANNER("banner"), DIGEST("digest") }

    /** Mirrors `SnoozePolicy.tierFor` exactly. */
    fun tierFor(promise: CyaStore.Promise): Tier = when {
        promise.snoozeCount == 0 -> Tier.QUIET
        promise.snoozeCount < CyaStore.MAX_SNOOZES -> Tier.BANNER
        else -> Tier.DIGEST
    }

    fun ensureChannels(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_QUIET,
                "Reminders",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "The first time a promise comes back."
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_BANNER,
                "Promises you keep pushing back",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "A promise you have already snoozed at least once."
            },
        )
    }

    fun show(
        context: Context,
        promise: CyaStore.Promise,
        tier: Tier,
        message: String? = null,
    ) {
        ensureChannels(context)
        val manager = context.getSystemService(NotificationManager::class.java) ?: return

        val channel = if (tier == Tier.BANNER) CHANNEL_BANNER else CHANNEL_QUIET
        // The status-bar icon is rendered as an alpha mask, so it must be a white silhouette —
        // the launcher icon shows up as a hollow blob.
        val body = message
            ?: promise.snippet
            ?: "Saved from ${promise.sourceApp}"
        val notification = Notification.Builder(context, channel)
            .setSmallIcon(R.drawable.ic_stat_cya)
            .setContentTitle(promise.title)
            .setContentText(body)
            .apply {
                // Only worth expanding when there is more than the title to read.
                if (promise.rawContent.trim() != promise.title) {
                    setStyle(Notification.BigTextStyle().bigText(promise.rawContent))
                }
            }
            .setContentIntent(openPromiseIntent(context, promise.id))
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_REMINDER)
            // Capture is frictionless by design, so a good day produces several promises due at
            // the same preset time. Grouping keeps that from becoming a wall of separate
            // interruptions, while each child keeps its own one-tap actions (ADR-012).
            .setGroup(GROUP_REMINDERS)
            .setGroupAlertBehavior(Notification.GROUP_ALERT_CHILDREN)
            // One tap to close the loop, without opening the app (PRD §3.4/§8.4).
            .addAction(
                action(context, promise.id, NotificationActionReceiver.ACTION_DONE, "Done"),
            )
            .apply {
                if (promise.snoozeCount < CyaStore.MAX_SNOOZES) {
                    addAction(
                        action(
                            context,
                            promise.id,
                            NotificationActionReceiver.ACTION_SNOOZE,
                            "Snooze",
                        ),
                    )
                } else {
                    // Past the limit the copy asks the user to "finish it, or let it go" — so the
                    // notification has to actually offer letting go (ADR-013). Without this the
                    // only exit is opening the app and hunting for archive.
                    addAction(
                        action(
                            context,
                            promise.id,
                            NotificationActionReceiver.ACTION_LET_GO,
                            "Let it go",
                        ),
                    )
                }
            }
            .build()

        manager.notify(promise.id.toInt(), notification)
        refreshSummary(context, manager)
    }

    fun dismiss(context: Context, intentionId: Long) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.cancel(intentionId.toInt())
        // The summary counts what is still in the shade, so it has to be recomputed whenever a
        // child leaves — otherwise it keeps claiming promises the user already dealt with.
        refreshSummary(context, manager)
    }

    /**
     * Keeps one summary card over the reminder group (ADR-012).
     *
     * Below two children there is nothing to summarise and a lone promise reads better on its own,
     * so the summary is cancelled rather than shown over a single card. The summary never alerts —
     * `GROUP_ALERT_CHILDREN` on the children means the buzz already happened.
     */
    private fun refreshSummary(context: Context, manager: NotificationManager) {
        val children = runCatching {
            manager.activeNotifications.count { posted ->
                posted.id != SUMMARY_ID && posted.notification.group == GROUP_REMINDERS
            }
        }.getOrDefault(0)

        if (children < 2) {
            manager.cancel(SUMMARY_ID)
            return
        }

        manager.notify(
            SUMMARY_ID,
            Notification.Builder(context, CHANNEL_QUIET)
                .setSmallIcon(R.drawable.ic_stat_cya)
                .setContentTitle("$children promises are waiting")
                .setContentText("Whenever you're ready.")
                .setGroup(GROUP_REMINDERS)
                .setGroupSummary(true)
                .setGroupAlertBehavior(Notification.GROUP_ALERT_CHILDREN)
                .setContentIntent(openAppIntent(context))
                .setAutoCancel(true)
                .build(),
        )
    }

    /** Tapping the body deep-links straight to the promise (PRD §8.2 resurface screen). */
    private fun openPromiseIntent(context: Context, intentionId: Long): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("cya://promise/$intentionId")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            intentionId.toInt(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** The summary card opens the app rather than any one promise. */
    private fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            SUMMARY_ID,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun action(
        context: Context,
        intentionId: Long,
        actionName: String,
        label: String,
    ): Notification.Action {
        val intent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = actionName
            data = Uri.parse("cya://$actionName/$intentionId")
            putExtra(ReminderReceiver.EXTRA_INTENTION_ID, intentionId)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            intentionId.toInt(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Action.Builder(null, label, pending).build()
    }
}
