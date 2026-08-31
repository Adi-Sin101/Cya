package com.example.cya.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.cya.MainActivity
import com.example.cya.R
import com.example.cya.capture.CyaStore
import com.example.cya.tile.QuickCaptureActivity

/**
 * The home-screen widget (PRD §6.1): two tap targets — capture, and view today.
 *
 * Like every other surface outside the main app, it reads the shared SQLite store directly and
 * never starts the Flutter engine. A widget that needed an engine to render a count would be a
 * battery cost the user never asked for.
 */
class CyaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val today = CyaStore(context).todayCounts()
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, render(context, today))
        }
    }

    private fun render(context: Context, today: CyaStore.TodayCounts): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_today)

        val headline = when {
            today.total == 0 -> "Nothing due today"
            today.remaining == 0 -> "All done today"
            today.remaining == 1 -> "1 promise today"
            else -> "${today.remaining} promises today"
        }
        val subtitle = when {
            today.total == 0 -> "Tap + to save something for later."
            today.completed == 0 -> "I'll bring them back on time."
            else -> "${today.completed} of ${today.total} kept."
        }
        views.setTextViewText(R.id.widget_headline, headline)
        views.setTextViewText(R.id.widget_subtitle, subtitle)

        // Body opens today's promises; the + opens the fast native capture.
        views.setOnClickPendingIntent(
            R.id.widget_root,
            activity(context, REQUEST_OPEN, Intent(context, MainActivity::class.java)),
        )
        views.setOnClickPendingIntent(
            R.id.widget_capture,
            activity(
                context,
                REQUEST_CAPTURE,
                Intent(context, QuickCaptureActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                },
            ),
        )
        return views
    }

    private fun activity(context: Context, requestCode: Int, intent: Intent): PendingIntent =
        PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    companion object {
        private const val REQUEST_OPEN = 70_001
        private const val REQUEST_CAPTURE = 70_002

        /**
         * Redraws every placed widget. Called from the paths that change what it shows — a capture,
         * and a resolution from a notification — so the widget is never stale by more than the
         * write that changed it.
         */
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context) ?: return
            val ids = manager.getAppWidgetIds(
                ComponentName(context, CyaWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            context.sendBroadcast(
                Intent(context, CyaWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                },
            )
        }
    }
}
