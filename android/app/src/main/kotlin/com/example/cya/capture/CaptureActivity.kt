package com.example.cya.capture

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.widget.Toast
import com.example.cya.reminders.ReminderScheduler

/**
 * The Share Sheet capture surface (PRD §6.1) and the strictest expression of the native-thin
 * capture path (PRD §5.4).
 *
 * It does exactly four things: read the shared text, write one row plus its event to the shared
 * SQLite file, confirm, and finish. It never inflates a layout, never starts the Flutter engine,
 * never touches the network, and never runs inference. Anything added here is measured directly
 * against the < 2s promise (PRD §3.1) — so nothing should be.
 */
class CaptureActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handle(intent)
    }

    /**
     * A second share arriving while this instance is still finishing is delivered here rather than
     * to a new instance. Without this it would be silently dropped — and a lost capture is the one
     * failure this product cannot have (PRD §13.4 [L-003]).
     */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handle(intent)
    }

    private fun handle(intent: Intent?) {
        val startedAt = SystemClock.elapsedRealtime()

        val text = extractSharedText(intent)
        if (text.isNullOrBlank()) {
            toast("Nothing to save")
            finishFast()
            return
        }

        val now = System.currentTimeMillis()
        try {
            val reminderAt = ReminderDefaults.tonight(now)
            val result = CyaStore(this).capture(
                CyaStore.Capture(
                    sourceApp = resolveSourceApp(),
                    rawContent = text.trim(),
                    snippet = intent
                        ?.getStringExtra(Intent.EXTRA_SUBJECT)
                        ?.takeIf(String::isNotBlank),
                    deepLink = text.firstUrlOrNull(),
                    capturedAtMillis = now,
                    // Zero-tap default: a capture completes with no extra taps (PRD §6.1).
                    reminderAtMillis = reminderAt,
                ),
                startedAtElapsedMillis = startedAt,
            )
            // The second and last thing the capture path does (PRD §5.4): one insert, one alarm.
            ReminderScheduler.schedule(this, result.intentionId, reminderAt)
            // Single tagged line so an adb run can assert the §9.2 budget.
            Log.i(TAG, "capture_ok id=${result.intentionId} capture_ms=${result.elapsedMillis}")
            toast("Saved. I'll remember for you.")
        } catch (error: RuntimeException) {
            // Never fail silently — a lost capture is the one thing this product cannot do.
            Log.e(TAG, "capture_failed", error)
            toast("Couldn't save that. Please try again.")
        }
        finishFast()
    }

    /** Accepts a plain share and Android's "process text" selection action. */
    private fun extractSharedText(intent: Intent?): String? = when (intent?.action) {
        Intent.ACTION_SEND -> intent.getStringExtra(Intent.EXTRA_TEXT)
        Intent.ACTION_PROCESS_TEXT ->
            intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        else -> null
    }

    /**
     * Best-effort attribution of where the promise came from — the `source_app` the UI shows and a
     * future deep link keys off. Unknown senders are labelled rather than guessed at.
     */
    private fun resolveSourceApp(): String {
        val packageName = callingPackage ?: referrer?.host ?: return UNKNOWN_SOURCE
        return try {
            val manager = packageManager
            manager.getApplicationLabel(manager.getApplicationInfo(packageName, 0)).toString()
        } catch (_: Exception) {
            UNKNOWN_SOURCE
        }
    }

    private fun toast(message: String) =
        Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()

    /** Dismiss with no transition so the sharing app is back instantly. */
    private fun finishFast() {
        finish()
        overridePendingTransition(0, 0)
    }

    private companion object {
        const val TAG = "CyaCapture"
        const val UNKNOWN_SOURCE = "Shared"
    }
}

private val URL_PATTERN = Regex("""https?://\S+""")

/** The first URL in the shared text, kept as the return-to-source link (PRD §6.3). */
private fun String.firstUrlOrNull(): String? = URL_PATTERN.find(this)?.value
