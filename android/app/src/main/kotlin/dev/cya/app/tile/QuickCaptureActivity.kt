package dev.cya.app.tile

import android.app.Activity
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup.LayoutParams
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import dev.cya.app.capture.CyaStore
import dev.cya.app.capture.ReminderDefaults
import dev.cya.app.reminders.ReminderScheduler
import dev.cya.app.widget.CyaWidgetProvider

/**
 * The Quick Settings Tile's capture screen (PRD §6.1).
 *
 * A tile cannot read what the user was looking at, so this is the one capture surface that needs a
 * text field. It is still **native**: a programmatically built dialog, no Flutter engine, no layout
 * inflation from XML, pre-filled from the clipboard so the common case ("I copied this, save it")
 * is one tap. Saving does exactly what every other surface does — one insert plus one alarm (§3.2).
 */
class QuickCaptureActivity : Activity() {

    private lateinit var input: EditText

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setFinishOnTouchOutside(true)
        setContentView(buildView())
        window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE)
        input.requestFocus()
    }

    private fun buildView(): View {
        val density = resources.displayMetrics.density
        fun dp(value: Int) = (value * density).toInt()

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(16))
            background = GradientDrawable().apply {
                cornerRadius = dp(20).toFloat()
                setColor(Color.WHITE)
            }
        }

        root.addView(
            TextView(this).apply {
                text = "What do you want to save for later?"
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
                setTextColor(INK)
            },
        )

        input = EditText(this).apply {
            hint = "Paste, write, or dictate it"
            setTextColor(INK)
            setHintTextColor(Color.parseColor("#94A3B8"))
            setLines(3)
            gravity = Gravity.TOP or Gravity.START
            // The common case for a tile capture is "I just copied something".
            setText(clipboardText().orEmpty())
            setSelection(text.length)
            layoutParams = LinearLayout.LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(12) }
        }
        root.addView(input)

        root.addView(
            TextView(this).apply {
                text = "I'll bring it back tonight."
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setTextColor(Color.parseColor("#64748B"))
                layoutParams = LinearLayout.LayoutParams(
                    LayoutParams.WRAP_CONTENT,
                    LayoutParams.WRAP_CONTENT,
                ).apply { topMargin = dp(10) }
            },
        )

        root.addView(
            Button(this).apply {
                text = "Save to Cya!"
                setTextColor(Color.WHITE)
                background = GradientDrawable().apply {
                    cornerRadius = dp(14).toFloat()
                    setColor(SAGE)
                }
                setOnClickListener { save() }
                layoutParams = LinearLayout.LayoutParams(
                    LayoutParams.MATCH_PARENT,
                    dp(48),
                ).apply { topMargin = dp(16) }
            },
        )
        return root
    }

    private fun save() {
        val text = input.text?.toString()?.trim().orEmpty()
        if (text.isEmpty()) {
            Toast.makeText(this, "Write something to save", Toast.LENGTH_SHORT).show()
            return
        }
        val startedAt = SystemClock.elapsedRealtime()
        val now = System.currentTimeMillis()
        try {
            val reminderAt = ReminderDefaults.tonight(now)
            val result = CyaStore(this).capture(
                CyaStore.Capture(
                    sourceApp = SOURCE,
                    // A tile capture came from Cya! itself, not from another app.
                    sourcePackage = null,
                    rawContent = text,
                    capturedAtMillis = now,
                    reminderAtMillis = reminderAt,
                ),
                startedAtElapsedMillis = startedAt,
            )
            ReminderScheduler.schedule(this, result.intentionId, reminderAt)
            CyaWidgetProvider.refresh(this)
            Log.i(TAG, "tile_capture_ok id=${result.intentionId} capture_ms=${result.elapsedMillis}")
            Toast.makeText(this, "Saved. I'll remember for you.", Toast.LENGTH_SHORT).show()
        } catch (error: RuntimeException) {
            Log.e(TAG, "tile_capture_failed", error)
            Toast.makeText(this, "Couldn't save that. Please try again.", Toast.LENGTH_SHORT).show()
        }
        finish()
    }

    private fun clipboardText(): String? =
        getSystemService(Context.CLIPBOARD_SERVICE)
            .let { it as? ClipboardManager }
            ?.primaryClip
            ?.takeIf { it.itemCount > 0 }
            ?.getItemAt(0)
            ?.coerceToText(this)
            ?.toString()
            ?.takeIf { it.isNotBlank() }

    private companion object {
        const val TAG = "CyaCapture"
        const val SOURCE = "Quick Tile"
        val INK = Color.parseColor("#1F2937")
        val SAGE = Color.parseColor("#2E705B")
    }
}
