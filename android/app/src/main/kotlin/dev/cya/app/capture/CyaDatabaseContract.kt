package dev.cya.app.capture

/**
 * The native half of the Drift schema contract (PRD §7.2, docs/native_db_contract.md).
 *
 * Either runtime can be the first to open `cya.db` — a share can arrive before the app has ever
 * been launched — so this file carries the same DDL Drift's `onCreate` runs, and stamps the same
 * `user_version`. Drift then sees a version-1 database and skips its own creation.
 *
 * **Every constant here has a Dart twin.** Changing one without the other silently loses captures.
 */
internal object CyaDatabaseContract {

    /** Must match `CyaDatabase.databaseFileName`. */
    const val DATABASE_NAME = "cya.db"

    /** Must match `CyaDatabase.schemaVersion`. */
    const val SCHEMA_VERSION = 2

    const val TABLE_INTENTIONS = "intentions"
    const val TABLE_EVENTS = "intention_events"

    // Columns — pinned in Dart with .named(...) for exactly this reason.
    const val COL_ID = "id"
    const val COL_SOURCE_APP = "source_app"
    const val COL_SOURCE_PACKAGE = "source_package"
    const val COL_RAW_CONTENT = "raw_content"
    const val COL_SNIPPET = "snippet"
    const val COL_DEEP_LINK = "deep_link"
    const val COL_CAPTURED_AT = "captured_at"
    const val COL_REMINDER_AT = "reminder_at"
    const val COL_CATEGORY = "category"
    const val COL_STATUS = "status"
    const val COL_SNOOZE_COUNT = "snooze_count"
    const val COL_EXTRACTED_DEADLINE = "extracted_deadline"
    const val COL_UPDATED_AT = "updated_at"

    const val COL_EVENT_INTENTION_ID = "intention_id"
    const val COL_EVENT_TYPE = "type"
    const val COL_EVENT_OCCURRED_AT = "occurred_at"
    const val COL_EVENT_METADATA = "metadata"

    // Wire vocabularies — mirror IntentionStatus.wire / IntentionEventType.wire.
    const val STATUS_OPEN = "open"
    const val STATUS_SNOOZED = "snoozed"
    const val STATUS_RESOLVED = "resolved"
    const val STATUS_ARCHIVED = "archived"

    const val EVENT_CAPTURED = "captured"
    const val EVENT_RESOLVED = "resolved"
    const val EVENT_SNOOZED = "snoozed"
    const val EVENT_RESURFACED = "resurfaced"
    const val EVENT_ARCHIVED = "archived"

    /**
     * DDL for the tables both runtimes share. Executed only when the file does not exist yet;
     * after this runs, `PRAGMA user_version` is set to [SCHEMA_VERSION].
     *
     * **No FTS5 here on purpose.** Android's system SQLite ships without the fts5 module (verified
     * on API 34), so the search index is created and maintained entirely on the Dart side, which
     * bundles its own SQLite build (ADR-005). The capture path must never depend on it.
     */
    val CREATE_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS "intentions" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "source_app" TEXT NOT NULL,
          "source_package" TEXT NULL,
          "raw_content" TEXT NOT NULL,
          "snippet" TEXT NULL,
          "deep_link" TEXT NULL,
          "captured_at" INTEGER NOT NULL,
          "reminder_at" INTEGER NULL,
          "category" TEXT NULL,
          "status" TEXT NOT NULL DEFAULT 'open',
          "snooze_count" INTEGER NOT NULL DEFAULT 0,
          "extracted_deadline" INTEGER NULL,
          "updated_at" INTEGER NOT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS "intention_events" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "intention_id" INTEGER NOT NULL REFERENCES intentions (id),
          "type" TEXT NOT NULL,
          "occurred_at" INTEGER NOT NULL,
          "metadata" TEXT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS "preferences" (
          "key" TEXT NOT NULL,
          "value" TEXT NOT NULL,
          PRIMARY KEY ("key")
        )
        """.trimIndent(),
        "CREATE INDEX IF NOT EXISTS idx_intentions_status ON intentions(status)",
        "CREATE INDEX IF NOT EXISTS idx_intentions_reminder_at ON intentions(reminder_at)",
        "CREATE INDEX IF NOT EXISTS idx_intention_events_occurred_at " +
            "ON intention_events(occurred_at)",
        "CREATE INDEX IF NOT EXISTS idx_intention_events_intention " +
            "ON intention_events(intention_id)",
    )

    /**
     * Schema upgrades, applied by whichever runtime opens the file first.
     *
     * Must stay in lockstep with `CyaDatabase.migration.onUpgrade` — the two runtimes share one
     * file, and a column that exists on only one side loses captures (docs/native_db_contract.md).
     * Every statement here has to be safe to run against a file the other runtime already upgraded,
     * which is why callers ignore "duplicate column" failures.
     */
    fun upgradeStatements(from: Int): List<String> = buildList {
        if (from < 2) {
            add("ALTER TABLE intentions ADD COLUMN source_package TEXT NULL")
        }
    }
}
