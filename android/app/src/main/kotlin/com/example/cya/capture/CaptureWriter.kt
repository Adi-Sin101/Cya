package com.example.cya.capture

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import java.io.File

/**
 * Writes captures straight into the shared SQLite file — the native-thin capture path
 * (PRD §3.2, §5.4).
 *
 * This class is the whole reason the two-second promise is keepable: no Flutter engine, no plugin,
 * no coroutine dispatcher, no network. Open, one transaction, close.
 */
internal class CaptureWriter(private val context: Context) {

    data class Capture(
        val sourceApp: String,
        val rawContent: String,
        val snippet: String? = null,
        val deepLink: String? = null,
        val capturedAtMillis: Long,
        val reminderAtMillis: Long?,
    )

    data class Result(val intentionId: Long, val elapsedMillis: Long)

    /**
     * Inserts the intention and its `captured` event in **one transaction** (PRD §7.1) and returns
     * how long the write took, which is stored in the event metadata so capture speed is a measured
     * fact in the event log itself (PRD §9.2, §11).
     */
    fun write(capture: Capture, startedAtElapsedMillis: Long): Result {
        openOrCreate().use { db ->
            db.beginTransaction()
            try {
                val row = ContentValues().apply {
                    put(CyaDatabaseContract.COL_SOURCE_APP, capture.sourceApp)
                    put(CyaDatabaseContract.COL_RAW_CONTENT, capture.rawContent)
                    put(CyaDatabaseContract.COL_SNIPPET, capture.snippet)
                    put(CyaDatabaseContract.COL_DEEP_LINK, capture.deepLink)
                    put(CyaDatabaseContract.COL_CAPTURED_AT, capture.capturedAtMillis.toSeconds())
                    put(
                        CyaDatabaseContract.COL_REMINDER_AT,
                        capture.reminderAtMillis?.toSeconds(),
                    )
                    put(CyaDatabaseContract.COL_STATUS, CyaDatabaseContract.STATUS_OPEN)
                    put(CyaDatabaseContract.COL_SNOOZE_COUNT, 0)
                    put(CyaDatabaseContract.COL_UPDATED_AT, capture.capturedAtMillis.toSeconds())
                }
                val id = db.insertOrThrow(CyaDatabaseContract.TABLE_INTENTIONS, null, row)

                val elapsed = android.os.SystemClock.elapsedRealtime() - startedAtElapsedMillis
                val event = ContentValues().apply {
                    put(CyaDatabaseContract.COL_EVENT_INTENTION_ID, id)
                    put(CyaDatabaseContract.COL_EVENT_TYPE, CyaDatabaseContract.EVENT_CAPTURED)
                    put(
                        CyaDatabaseContract.COL_EVENT_OCCURRED_AT,
                        capture.capturedAtMillis.toSeconds(),
                    )
                    put(
                        CyaDatabaseContract.COL_EVENT_METADATA,
                        """{"source":"${capture.sourceApp.escapeJson()}",""" +
                            """"surface":"share_sheet","capture_ms":$elapsed}""",
                    )
                }
                db.insertOrThrow(CyaDatabaseContract.TABLE_EVENTS, null, event)

                db.setTransactionSuccessful()
                return Result(id, android.os.SystemClock.elapsedRealtime() - startedAtElapsedMillis)
            } finally {
                db.endTransaction()
            }
        }
    }

    /**
     * Opens the shared database, creating the schema when this is the first ever write — a share can
     * arrive before the app has been launched once. Whoever creates it stamps `user_version`, so the
     * other runtime opens it without migrating.
     */
    private fun openOrCreate(): SQLiteDatabase {
        val file = databaseFile(context)
        file.parentFile?.mkdirs()
        val db = SQLiteDatabase.openOrCreateDatabase(file, null)
        db.execSQL("PRAGMA foreign_keys = ON")
        if (db.version == 0) {
            db.beginTransaction()
            try {
                CyaDatabaseContract.CREATE_STATEMENTS.forEach(db::execSQL)
                db.setTransactionSuccessful()
            } finally {
                db.endTransaction()
            }
            db.version = CyaDatabaseContract.SCHEMA_VERSION
        }
        return db
    }

    internal companion object {
        /**
         * The same path Drift resolves through `getApplicationSupportDirectory()`, which
         * path_provider maps to `context.getFilesDir()` on Android.
         */
        fun databaseFile(context: Context): File =
            File(context.filesDir, CyaDatabaseContract.DATABASE_NAME)
    }
}

/** Drift stores `DateTime` as INTEGER **seconds** since the epoch — not millis. */
private fun Long.toSeconds(): Long = this / 1000

private fun String.escapeJson(): String =
    replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ")
