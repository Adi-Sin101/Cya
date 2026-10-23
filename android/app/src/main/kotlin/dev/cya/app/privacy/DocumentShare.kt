package dev.cya.app.privacy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File

/**
 * Hands the data export to the OS share sheet (PRD §9.3).
 *
 * Cya! writes the file and offers it; where it goes is entirely the user's choice. That asymmetry
 * is the point — a local-first app that decided the destination would just be a sync product with
 * extra steps.
 *
 * The file lands in a dedicated cache subdirectory, not app-private storage proper: it is a copy
 * made for handing over, the system reclaims it under pressure, and a stale export sitting in
 * `filesDir` forever would be a second copy of everything the store already holds.
 */
internal object DocumentShare {

    private const val TAG = "CyaExport"

    /** Must match the `<cache-path>` in `res/xml/file_paths.xml`. */
    private const val EXPORT_DIR = "exports"

    /**
     * Writes [content] to `<cache>/exports/<fileName>` and opens the share sheet.
     * Returns whether anything could receive it.
     */
    fun share(
        activity: Activity,
        fileName: String,
        content: String,
        mimeType: String,
        title: String,
    ): Boolean = runCatching {
        require(fileName.matches(Regex("[A-Za-z0-9][A-Za-z0-9_.-]*")))
        val directory = File(activity.cacheDir, EXPORT_DIR).apply { mkdirs() }
        // Each export replaces the last. Keeping a history here would quietly accumulate full
        // copies of the user's promises in a directory they never see.
        directory.listFiles()?.forEach { it.delete() }

        val file = File(directory, fileName)
        file.writeText(content)

        val uri = FileProvider.getUriForFile(
            activity,
            "${activity.packageName}.exports",
            file,
        )

        val send = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_TITLE, title)
            // Without this the receiving app gets a Uri it has no permission to open.
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val chooser = Intent.createChooser(send, title)
        if (chooser.resolveActivity(activity.packageManager) == null) return false
        activity.startActivity(chooser)
        true
    }.getOrElse {
        Log.w(TAG, "export_share_failed", it)
        false
    }

    fun prepareArchive(context: Context, fileName: String, manifest: String, attachments: List<ArchiveAttachment>): File {
        require(fileName.matches(Regex("[A-Za-z0-9][A-Za-z0-9_.-]*\\.zip")))
        val directory = File(context.cacheDir, EXPORT_DIR).apply { mkdirs() }
        val staging = File.createTempFile("cya-", ".partial", directory)
        // ArchiveWriter requires a new path and removes it if validation fails.
        check(staging.delete())
        ArchiveWriter.create(staging, File(context.filesDir, "memory_audio"), manifest, attachments)
        val target = File(directory, fileName)
        check(staging.renameTo(target))
        directory.listFiles()?.filter { it != target && it.isFile }?.forEach { it.delete() }
        return target
    }

    fun shareArchive(activity: Activity, file: File): Boolean = runCatching {
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.exports", file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "application/zip"; putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        activity.startActivity(Intent.createChooser(send, "Your Cya! archive (not encrypted)"))
        true
    }.getOrDefault(false)

    fun clearCachedExports(context: Context) {
        File(context.cacheDir, EXPORT_DIR).listFiles()?.forEach { if (it.isFile) check(it.delete()) }
        val root = context.cacheDir.canonicalFile
        for (name in listOf("embeddinggemma-2", "cya-imports")) {
            val directory = File(root, name)
            check(directory.canonicalFile.parentFile == root)
            if (directory.exists()) check(directory.deleteRecursively())
        }
    }
}
