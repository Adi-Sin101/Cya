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
    const val SCHEMA_VERSION = 8

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
    val MEMORY_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS memories (
          id TEXT NOT NULL PRIMARY KEY,
          kind TEXT NOT NULL DEFAULT 'text',
          source TEXT NOT NULL DEFAULT 'Cya!',
          captured_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          archived_at INTEGER NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_revisions (
          id TEXT NOT NULL PRIMARY KEY,
          memory_id TEXT NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
          revision INTEGER NOT NULL,
          body TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE(memory_id, revision)
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          memory_id TEXT NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
          type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL,
          revision_id TEXT NULL REFERENCES memory_revisions(id) ON DELETE CASCADE,
          metadata TEXT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_jobs (
          revision_id TEXT NOT NULL PRIMARY KEY REFERENCES memory_revisions(id) ON DELETE CASCADE,
          state TEXT NOT NULL DEFAULT 'pending',
          attempts INTEGER NOT NULL DEFAULT 0,
          retry_at INTEGER NULL,
          last_error TEXT NULL,
          next_segment INTEGER NOT NULL DEFAULT 0,
          model_version TEXT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_vectors (
          revision_id TEXT NOT NULL REFERENCES memory_revisions(id) ON DELETE CASCADE,
          segment INTEGER NOT NULL,
          model_version TEXT NOT NULL,
          dimensions INTEGER NOT NULL,
          vector BLOB NOT NULL,
          PRIMARY KEY(revision_id, segment)
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_links (
          id TEXT NOT NULL PRIMARY KEY,
          from_revision TEXT NOT NULL REFERENCES memory_revisions(id) ON DELETE CASCADE,
          to_revision TEXT NOT NULL REFERENCES memory_revisions(id) ON DELETE CASCADE,
          kind TEXT NOT NULL,
          provenance TEXT NOT NULL,
          state TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE(from_revision, to_revision, kind)
        )
        """.trimIndent(),
    )

    val MEMORY_COLUMNS = mapOf(
        "memories" to "id,kind,source,captured_at,updated_at,archived_at",
        "memory_revisions" to "id,memory_id,revision,body,created_at",
        "memory_events" to "id,memory_id,type,occurred_at,revision_id,metadata",
        "memory_jobs" to "revision_id,state,attempts,retry_at,last_error,next_segment,model_version",
        "memory_vectors" to "revision_id,segment,model_version,dimensions,vector",
        "memory_links" to "id,from_revision,to_revision,kind,provenance,state,created_at",
        "memory_attachments" to "id,memory_id,file_name,sha256,byte_length,duration_millis,captured_at",
        "attachment_cleanup" to "file_name,created_at",
        "focus_sessions" to "id,priority,started_at,ended_at",
        "focus_events" to "id,session_id,type,occurred_at",
        "memory_collections" to "id,title,kind,parent_id,created_at",
        "collection_events" to "id,collection_id,type,occurred_at,metadata",
        "memory_assignments" to "id,revision_id,intention_id,collection_id,kind,context,created_at",
        "routines" to "id,current_revision,position,paused,created_at,updated_at,deleted_at",
        "routine_revisions" to "id,routine_id,revision,title,weekdays,preferred_start,preferred_end,steps,fallback,created_at",
        "routine_events" to "id,routine_id,revision_id,type,occurred_at,metadata",
        "routine_occurrences" to "id,change_version,routine_id,revision_id,selected_day,target_day,state,position,steps,preferred_start,preferred_end,selected_at,updated_at",
        "routine_occurrence_events" to "id,occurrence_id,type,occurred_at,metadata",
        "local_reviews" to "id,origin,day_key,period,memory_id,created_at",
    )

    val ATTACHMENT_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS memory_attachments (
          id TEXT NOT NULL PRIMARY KEY,
          memory_id TEXT NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
          file_name TEXT NOT NULL UNIQUE,
          sha256 TEXT NOT NULL,
          byte_length INTEGER NOT NULL,
          duration_millis INTEGER NOT NULL,
          captured_at INTEGER NOT NULL,
          UNIQUE(memory_id)
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS attachment_cleanup (
          file_name TEXT NOT NULL PRIMARY KEY,
          created_at INTEGER NOT NULL
        )
        """.trimIndent(),
    )

    val FOCUS_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS focus_sessions (
          id TEXT NOT NULL PRIMARY KEY,
          priority TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          ended_at INTEGER NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS focus_events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          session_id TEXT NOT NULL REFERENCES focus_sessions(id) ON DELETE CASCADE,
          type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL
        )
        """.trimIndent(),
    )

    val CONNECTION_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS memory_collections (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          kind TEXT NOT NULL,
          parent_id TEXT NULL REFERENCES memory_collections(id) ON DELETE SET NULL,
          created_at INTEGER NOT NULL,
          CHECK (kind IN ('topic','project'))
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS collection_events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          collection_id TEXT NOT NULL REFERENCES memory_collections(id) ON DELETE CASCADE,
          type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL,
          metadata TEXT NOT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS memory_assignments (
          id TEXT NOT NULL PRIMARY KEY,
          revision_id TEXT NOT NULL REFERENCES memory_revisions(id) ON DELETE CASCADE,
          intention_id INTEGER NULL REFERENCES intentions(id) ON DELETE CASCADE,
          collection_id TEXT NULL REFERENCES memory_collections(id) ON DELETE CASCADE,
          kind TEXT NOT NULL,
          context TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE(revision_id,intention_id),
          UNIQUE(revision_id,collection_id),
          CHECK ((intention_id IS NOT NULL AND collection_id IS NULL AND kind='intention') OR (intention_id IS NULL AND collection_id IS NOT NULL AND kind='collection'))
        )
        """.trimIndent(),
    )

    val ROUTINE_STATEMENTS: List<String> = listOf(
        """
        CREATE TABLE IF NOT EXISTS routines (
          id TEXT NOT NULL PRIMARY KEY,
          current_revision INTEGER NOT NULL DEFAULT 1,
          position INTEGER NOT NULL DEFAULT 0,
          paused INTEGER NOT NULL DEFAULT 0 CHECK (paused IN (0,1)),
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS routine_revisions (
          id TEXT NOT NULL PRIMARY KEY,
          routine_id TEXT NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
          revision INTEGER NOT NULL,
          title TEXT NOT NULL,
          weekdays INTEGER NULL,
          preferred_start INTEGER NULL,
          preferred_end INTEGER NULL,
          steps TEXT NOT NULL DEFAULT '[]',
          fallback TEXT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE(routine_id,revision),
          CHECK (weekdays IS NULL OR weekdays BETWEEN 1 AND 127),
          CHECK (preferred_start IS NULL OR preferred_start BETWEEN 0 AND 1439),
          CHECK (preferred_end IS NULL OR (preferred_start IS NOT NULL AND preferred_end BETWEEN preferred_start AND 1439))
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS routine_events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          routine_id TEXT NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
          revision_id TEXT NULL REFERENCES routine_revisions(id) ON DELETE CASCADE,
          type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL,
          metadata TEXT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS routine_occurrences (
          id TEXT NOT NULL PRIMARY KEY,
          change_version INTEGER NOT NULL DEFAULT 1,
          routine_id TEXT NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
          revision_id TEXT NOT NULL REFERENCES routine_revisions(id) ON DELETE CASCADE,
          selected_day TEXT NOT NULL,
          target_day TEXT NOT NULL,
          state TEXT NOT NULL DEFAULT 'planned',
          position INTEGER NOT NULL DEFAULT 0,
          steps TEXT NOT NULL,
          preferred_start INTEGER NULL,
          preferred_end INTEGER NULL,
          selected_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(routine_id,selected_day),
          CHECK (state IN ('planned','completed','skipped','deferred')),
          CHECK (preferred_start IS NULL OR preferred_start BETWEEN 0 AND 1439),
          CHECK (preferred_end IS NULL OR (preferred_start IS NOT NULL AND preferred_end BETWEEN preferred_start AND 1439))
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS routine_occurrence_events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          occurrence_id TEXT NOT NULL REFERENCES routine_occurrences(id) ON DELETE CASCADE,
          type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL,
          metadata TEXT NOT NULL
        )
        """.trimIndent(),
        """
        CREATE TABLE IF NOT EXISTS local_reviews (
          id TEXT NOT NULL PRIMARY KEY,
          origin TEXT NOT NULL DEFAULT 'local',
          day_key TEXT NOT NULL,
          period TEXT NOT NULL,
          memory_id TEXT NOT NULL UNIQUE REFERENCES memories(id) ON DELETE CASCADE,
          created_at INTEGER NOT NULL,
          UNIQUE(period,day_key,origin),
          CHECK (period IN ('daily','weekly'))
        )
        """.trimIndent(),
    )

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
    ) + MEMORY_STATEMENTS + ATTACHMENT_STATEMENTS + FOCUS_STATEMENTS + CONNECTION_STATEMENTS + ROUTINE_STATEMENTS

    /**
     * Schema upgrades, applied by whichever runtime opens the file first.
     *
     * Must stay in lockstep with `CyaDatabase.migration.onUpgrade` — the two runtimes share one
     * file, and a column that exists on only one side loses captures (docs/native_db_contract.md).
     * Version checks, statements and version stamp run under one write transaction.
     * Failures propagate and roll back; an already upgraded file needs no ALTER.
     */
    fun upgradeStatements(from: Int): List<String> = buildList {
        if (from < 2) {
            add("ALTER TABLE intentions ADD COLUMN source_package TEXT NULL")
        }
        if (from < 3) addAll(MEMORY_STATEMENTS)
        if (from == 3) {
            add("ALTER TABLE memory_jobs ADD COLUMN next_segment INTEGER NOT NULL DEFAULT 0")
            add("ALTER TABLE memory_jobs ADD COLUMN model_version TEXT NULL")
            add("ALTER TABLE memory_events ADD COLUMN metadata TEXT NULL")
            addAll(MEMORY_STATEMENTS.filter { it.contains("CREATE TABLE IF NOT EXISTS memory_vectors") ||
                it.contains("CREATE TABLE IF NOT EXISTS memory_links") })
        }
        if (from < 5) addAll(ATTACHMENT_STATEMENTS)
        if (from < 6) {
            addAll(FOCUS_STATEMENTS)
            add("INSERT INTO focus_sessions(id,priority,started_at) SELECT 'legacy-focus-' || lower(hex(randomblob(16))),value,CAST(strftime('%s','now') AS INTEGER) FROM preferences WHERE key='focus_priority' AND trim(value) != ''")
            add("INSERT INTO focus_events(session_id,type,occurred_at) SELECT id,'legacy_observed',started_at FROM focus_sessions WHERE id LIKE 'legacy-focus-%'")
        }
        if (from < 7) addAll(CONNECTION_STATEMENTS)
        if (from < 8) addAll(ROUTINE_STATEMENTS)
    }
}
