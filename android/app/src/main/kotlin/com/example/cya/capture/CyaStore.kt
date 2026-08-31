package com.example.cya.capture

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.os.SystemClock
import java.io.File

/**
 * Native access to the shared SQLite store (PRD §3.3, §5.4).
 *
 * Everything the app can do without Flutter goes through here: capture from the Share Sheet,
 * resolve or snooze straight from a notification, record that a reminder was shown, and read the
 * pending reminders that need alarms after a reboot.
 *
 * The invariant is the same one the Dart DAO holds: **no row changes without its event, in the same
 * transaction** (PRD §7.1).
 */
internal class CyaStore(private val context: Context) {

    data class Capture(
        val sourceApp: String,
        val rawContent: String,
        val snippet: String? = null,
        val deepLink: String? = null,
        val capturedAtMillis: Long,
        val reminderAtMillis: Long?,
    )

    data class CaptureResult(val intentionId: Long, val elapsedMillis: Long)

    /** The fields a notification needs — deliberately not the whole row. */
    data class Promise(
        val id: Long,
        val sourceApp: String,
        val rawContent: String,
        val snippet: String?,
        val deepLink: String?,
        val status: String,
        val snoozeCount: Int,
        val reminderAtMillis: Long?,
    ) {
        val title: String get() = rawContent.trim().lineSequence().first().trim()

        val isPending: Boolean
            get() = status == CyaDatabaseContract.STATUS_OPEN ||
                status == CyaDatabaseContract.STATUS_SNOOZED
    }

    /**
     * The capture write: one row + one `captured` event and nothing else (PRD §3.2). `capture_ms`
     * lands in the event metadata so capture speed is measurable from the log itself (§9.2, §11).
     */
    fun capture(capture: Capture, startedAtElapsedMillis: Long): CaptureResult {
        // NOTE: never `return` from inside `transaction { }` — it is an inline function, so a
        // non-local return unwinds past `setTransactionSuccessful()` and silently ROLLS BACK a
        // write that otherwise looks like it succeeded. See PRD §13.4 [L-002].
        return open().use { db ->
            db.transaction {
                val row = ContentValues().apply {
                    put(CyaDatabaseContract.COL_SOURCE_APP, capture.sourceApp)
                    put(CyaDatabaseContract.COL_RAW_CONTENT, capture.rawContent)
                    put(CyaDatabaseContract.COL_SNIPPET, capture.snippet)
                    put(CyaDatabaseContract.COL_DEEP_LINK, capture.deepLink)
                    put(CyaDatabaseContract.COL_CAPTURED_AT, capture.capturedAtMillis.seconds())
                    put(CyaDatabaseContract.COL_REMINDER_AT, capture.reminderAtMillis?.seconds())
                    put(CyaDatabaseContract.COL_STATUS, CyaDatabaseContract.STATUS_OPEN)
                    put(CyaDatabaseContract.COL_SNOOZE_COUNT, 0)
                    put(CyaDatabaseContract.COL_UPDATED_AT, capture.capturedAtMillis.seconds())
                }
                val id = db.insertOrThrow(CyaDatabaseContract.TABLE_INTENTIONS, null, row)
                val elapsed = SystemClock.elapsedRealtime() - startedAtElapsedMillis
                db.logEvent(
                    intentionId = id,
                    type = CyaDatabaseContract.EVENT_CAPTURED,
                    atMillis = capture.capturedAtMillis,
                    metadata = """{"source":"${capture.sourceApp.escapeJson()}",""" +
                        """"surface":"share_sheet","capture_ms":$elapsed}""",
                )
                CaptureResult(id, SystemClock.elapsedRealtime() - startedAtElapsedMillis)
            }
        }
    }

    fun findById(id: Long): Promise? = open().use { db -> db.readPromise(id) }

    /**
     * One-tap resolution from the notification (PRD §3.4/§8.4) — no Flutter engine involved. The
     * reactive UI picks it up from the store next time it runs.
     */
    fun resolve(id: Long, atMillis: Long): Boolean = open().use { db ->
        db.transaction {
            val promise = db.readPromise(id)
            if (promise == null || !promise.isPending) {
                false
            } else {
                db.setStatus(id, CyaDatabaseContract.STATUS_RESOLVED, atMillis)
                db.logEvent(
                    id,
                    CyaDatabaseContract.EVENT_RESOLVED,
                    atMillis,
                    """{"surface":"notification"}""",
                )
                true
            }
        }
    }

    /**
     * Push a promise back. The snooze *limit* is domain policy (PRD §5.6); this mirrors it so the
     * notification cannot quietly grant a fourth snooze the app would refuse.
     */
    fun snooze(id: Long, untilMillis: Long, atMillis: Long): Boolean = open().use { db ->
        db.transaction {
            val promise = db.readPromise(id)
            if (promise == null || !promise.isPending ||
                promise.snoozeCount >= MAX_SNOOZES
            ) {
                return@transaction false
            }
            val next = promise.snoozeCount + 1
            db.update(
                CyaDatabaseContract.TABLE_INTENTIONS,
                ContentValues().apply {
                    put(CyaDatabaseContract.COL_STATUS, CyaDatabaseContract.STATUS_SNOOZED)
                    put(CyaDatabaseContract.COL_REMINDER_AT, untilMillis.seconds())
                    put(CyaDatabaseContract.COL_SNOOZE_COUNT, next)
                    put(CyaDatabaseContract.COL_UPDATED_AT, atMillis.seconds())
                },
                "${CyaDatabaseContract.COL_ID} = ?",
                arrayOf(id.toString()),
            )
            db.logEvent(
                id,
                CyaDatabaseContract.EVENT_SNOOZED,
                atMillis,
                """{"surface":"notification","count":$next}""",
            )
            true
        }
    }

    /**
     * Records that a reminder actually reached the user — the input to reminder-reliability
     * measurement (PRD §9.2) and to detecting alarms an OEM dropped (§12).
     */
    fun markResurfaced(id: Long, atMillis: Long, tier: String) {
        open().use { db ->
            db.transaction {
                db.update(
                    CyaDatabaseContract.TABLE_INTENTIONS,
                    ContentValues().apply {
                        put(CyaDatabaseContract.COL_UPDATED_AT, atMillis.seconds())
                    },
                    "${CyaDatabaseContract.COL_ID} = ?",
                    arrayOf(id.toString()),
                )
                db.logEvent(
                    id,
                    CyaDatabaseContract.EVENT_RESURFACED,
                    atMillis,
                    """{"tier":"$tier"}""",
                )
            }
        }
    }

    /** Every pending promise with a reminder — what the boot receiver reschedules. */
    fun pendingReminders(): List<Promise> = open().use { db ->
        db.rawQuery(
            "SELECT * FROM ${CyaDatabaseContract.TABLE_INTENTIONS} " +
                "WHERE ${CyaDatabaseContract.COL_STATUS} IN (?, ?) " +
                "AND ${CyaDatabaseContract.COL_REMINDER_AT} IS NOT NULL " +
                "ORDER BY ${CyaDatabaseContract.COL_REMINDER_AT}",
            arrayOf(CyaDatabaseContract.STATUS_OPEN, CyaDatabaseContract.STATUS_SNOOZED),
        ).use { cursor ->
            buildList {
                while (cursor.moveToNext()) add(cursor.toPromise())
            }
        }
    }

    /** How many promises were kept since Monday — what the weekly digest leads with. */
    fun resolvedSinceStartOfWeek(nowMillis: Long = System.currentTimeMillis()): Int {
        val weekStart = java.util.Calendar.getInstance().apply {
            timeInMillis = nowMillis
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
            // Calendar weeks start on Sunday; the app's week starts on Monday, matching
            // WeekProjection.startOfWeek.
            val daysSinceMonday = (get(java.util.Calendar.DAY_OF_WEEK) +
                5) % 7
            add(java.util.Calendar.DAY_OF_YEAR, -daysSinceMonday)
        }.timeInMillis / 1000

        return open().use { db ->
            db.rawQuery(
                "SELECT COUNT(*) FROM ${CyaDatabaseContract.TABLE_EVENTS} " +
                    "WHERE ${CyaDatabaseContract.COL_EVENT_TYPE} = ? " +
                    "AND ${CyaDatabaseContract.COL_EVENT_OCCURRED_AT} >= ?",
                arrayOf(CyaDatabaseContract.EVENT_RESOLVED, weekStart.toString()),
            ).use { cursor -> if (cursor.moveToFirst()) cursor.getInt(0) else 0 }
        }
    }

    /**
     * Opens the shared database, creating the schema when this is the first ever write — a share can
     * arrive before the app has been launched once. Whoever creates it stamps `user_version`, so the
     * other runtime opens it without migrating.
     */
    private fun open(): SQLiteDatabase {
        val file = databaseFile(context)
        file.parentFile?.mkdirs()
        val db = SQLiteDatabase.openOrCreateDatabase(file, null)
        db.execSQL("PRAGMA foreign_keys = ON")
        if (db.version == 0) {
            db.transaction { CyaDatabaseContract.CREATE_STATEMENTS.forEach(db::execSQL) }
            db.version = CyaDatabaseContract.SCHEMA_VERSION
        }
        return db
    }

    internal companion object {
        /** Mirrors `SnoozePolicy.maxSnoozes`. */
        const val MAX_SNOOZES = 3

        /**
         * The same path Drift resolves through `getApplicationSupportDirectory()`, which
         * path_provider maps to `context.getFilesDir()` on Android.
         */
        fun databaseFile(context: Context): File =
            File(context.filesDir, CyaDatabaseContract.DATABASE_NAME)
    }
}

/**
 * Runs [body] in a transaction and commits it.
 *
 * **Do not `return` out of [body] to the enclosing function.** This is an inline function, so a
 * non-local return unwinds straight to the `finally` below, skipping `setTransactionSuccessful()` —
 * the write is rolled back while the caller believes it succeeded (PRD §13.4 [L-002]). A labelled
 * `return@transaction` is fine.
 */
private inline fun <T> SQLiteDatabase.transaction(body: () -> T): T {
    beginTransaction()
    try {
        val result = body()
        setTransactionSuccessful()
        return result
    } finally {
        endTransaction()
    }
}

private fun SQLiteDatabase.readPromise(id: Long): CyaStore.Promise? = rawQuery(
    "SELECT * FROM ${CyaDatabaseContract.TABLE_INTENTIONS} " +
        "WHERE ${CyaDatabaseContract.COL_ID} = ?",
    arrayOf(id.toString()),
).use { cursor -> if (cursor.moveToFirst()) cursor.toPromise() else null }

private fun SQLiteDatabase.setStatus(id: Long, status: String, atMillis: Long) {
    update(
        CyaDatabaseContract.TABLE_INTENTIONS,
        ContentValues().apply {
            put(CyaDatabaseContract.COL_STATUS, status)
            put(CyaDatabaseContract.COL_UPDATED_AT, atMillis.seconds())
        },
        "${CyaDatabaseContract.COL_ID} = ?",
        arrayOf(id.toString()),
    )
}

private fun SQLiteDatabase.logEvent(
    intentionId: Long,
    type: String,
    atMillis: Long,
    metadata: String?,
) {
    insertOrThrow(
        CyaDatabaseContract.TABLE_EVENTS,
        null,
        ContentValues().apply {
            put(CyaDatabaseContract.COL_EVENT_INTENTION_ID, intentionId)
            put(CyaDatabaseContract.COL_EVENT_TYPE, type)
            put(CyaDatabaseContract.COL_EVENT_OCCURRED_AT, atMillis.seconds())
            put(CyaDatabaseContract.COL_EVENT_METADATA, metadata)
        },
    )
}

private fun android.database.Cursor.toPromise(): CyaStore.Promise {
    fun stringOrNull(column: String): String? {
        val index = getColumnIndexOrThrow(column)
        return if (isNull(index)) null else getString(index)
    }
    val reminderIndex = getColumnIndexOrThrow(CyaDatabaseContract.COL_REMINDER_AT)
    return CyaStore.Promise(
        id = getLong(getColumnIndexOrThrow(CyaDatabaseContract.COL_ID)),
        sourceApp = getString(getColumnIndexOrThrow(CyaDatabaseContract.COL_SOURCE_APP)),
        rawContent = getString(getColumnIndexOrThrow(CyaDatabaseContract.COL_RAW_CONTENT)),
        snippet = stringOrNull(CyaDatabaseContract.COL_SNIPPET),
        deepLink = stringOrNull(CyaDatabaseContract.COL_DEEP_LINK),
        status = getString(getColumnIndexOrThrow(CyaDatabaseContract.COL_STATUS)),
        snoozeCount = getInt(getColumnIndexOrThrow(CyaDatabaseContract.COL_SNOOZE_COUNT)),
        reminderAtMillis = if (isNull(reminderIndex)) null else getLong(reminderIndex) * 1000,
    )
}

/** Drift stores `DateTime` as INTEGER **seconds** since the epoch — not millis. */
private fun Long.seconds(): Long = this / 1000

private fun String.escapeJson(): String =
    replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ")
