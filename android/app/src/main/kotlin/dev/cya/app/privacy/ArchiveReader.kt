package dev.cya.app.privacy

import java.io.File
import java.io.InputStream
import java.security.MessageDigest
import java.util.zip.ZipInputStream

/** Untrusted files never choose a destination path. All limits count actual bytes. */
internal object ArchiveReader {
    const val MANIFEST_LIMIT = 10 * 1024 * 1024L
    const val AUDIO_LIMIT = 9600044L
    const val TOTAL_LIMIT = 1024 * 1024 * 1024L
    private val audioName = Regex("attachments/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\\.wav")
    fun read(input: InputStream, directory: File, zipped: Boolean): String {
        check(directory.mkdir())
        try {
            if (!zipped) {
                val target = File(directory, "manifest.json")
                input.use { copyLimited(it, target, MANIFEST_LIMIT) }
                return target.readText(Charsets.UTF_8)
            }
            var total = 0L
            val names = mutableSetOf<String>()
            ZipInputStream(input.buffered()).use { zip ->
                while (true) {
                    val entry = zip.nextEntry ?: break
                    require(!entry.isDirectory && names.add(entry.name) && names.size <= 10002)
                    val name = entry.name
                    require(name == "manifest.json" || name == "manifest.sha256" || audioName.matches(name))
                    val target = File(directory, name.substringAfterLast('/'))
                    val limit = when(name) { "manifest.json" -> MANIFEST_LIMIT; "manifest.sha256" -> 64L; else -> AUDIO_LIMIT }
                    total += copyLimited(zip, target, limit)
                    require(total <= TOTAL_LIMIT)
                    zip.closeEntry() // verifies CRC as well as actual uncompressed limits
                }
            }
            require(names.containsAll(listOf("manifest.json", "manifest.sha256")))
            val manifest = File(directory, "manifest.json")
            val expected = File(directory, "manifest.sha256").readText()
            require(expected.matches(Regex("[a-f0-9]{64}")) && digest(manifest) == expected)
            return manifest.readText(Charsets.UTF_8)
        } catch (error: Exception) { directory.deleteRecursively(); throw error }
    }
    fun digest(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input ->
            val buffer = ByteArray(65536)
            while (true) { val n = input.read(buffer); if (n < 0) break; digest.update(buffer,0,n) }
        }
        return digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
    }
    private fun copyLimited(input: InputStream, target: File, limit: Long): Long {
        var size = 0L
        target.outputStream().use { output ->
            val buffer = ByteArray(65536)
            while (true) {
                val n = input.read(buffer); if (n < 0) break
                size += n; require(size <= limit); output.write(buffer,0,n)
            }
            output.fd.sync()
        }
        return size
    }
}
