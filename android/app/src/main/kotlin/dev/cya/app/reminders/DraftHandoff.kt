package dev.cya.app.reminders

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log

/**
 * Opens the conversation a promise came from with the reply already written (ADR-015).
 *
 * **Cya! never sends anything.** Android has no public API to send a message in a third-party app,
 * and each workaround is disqualified on its own terms: `SEND_SMS` is restricted to default SMS
 * handlers and would undermine the core-function claim that justifies `USE_EXACT_ALARM`;
 * `NotificationListenerService` + `RemoteInput` only works while an unread notification is still
 * live and is exactly the private-app scraping PRD §3.5 forbids; `AccessibilityService` automation
 * is a Play policy violation that breaks on every target-app update.
 *
 * What is left is also the better product. Under a trusted-utility framing "your promise was never
 * lost" fails safely and "we sent something as you" does not, so the handoff stops one tap short on
 * purpose — the draft is ready, the send is the user's.
 */
internal object DraftHandoff {

    private const val TAG = "CyaDraft"

    /**
     * Tries, in order: share the draft directly into [packageName]; open [link] (the saved
     * conversation) so the user can paste; share the draft to whatever the user picks.
     *
     * Ordered by how close each lands the user to the actual reply, and every step is resolved
     * before it is launched — a share target that does not exist must fall through rather than
     * throw, because the app it came from may since have been uninstalled.
     */
    fun open(
        context: Context,
        draft: String,
        packageName: String?,
        link: String?,
    ): Boolean {
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, draft)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        // Best case: straight into the app the promise came from, compose box filled.
        if (!packageName.isNullOrBlank()) {
            val direct = Intent(send).setPackage(packageName)
            if (start(context, direct)) return true
        }

        // Next best: back to the exact conversation, with the draft on the clipboard-free path —
        // the user still has the text on screen in Cya! behind them.
        if (!link.isNullOrBlank() && openLink(context, link)) return true

        // Last: let the user pick where this goes.
        return start(context, Intent.createChooser(send, "Reply with").apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        })
    }

    private fun openLink(context: Context, link: String): Boolean = start(
        context,
        Intent(Intent.ACTION_VIEW, Uri.parse(link)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
    )

    private fun start(context: Context, intent: Intent): Boolean = runCatching {
        if (intent.resolveActivity(context.packageManager) == null) return false
        context.startActivity(intent)
        true
    }.getOrElse {
        Log.w(TAG, "draft_handoff_failed", it)
        false
    }
}
