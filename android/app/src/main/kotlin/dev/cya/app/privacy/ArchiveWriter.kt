package dev.cya.app.privacy

import java.io.File
import java.security.MessageDigest
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

internal data class ArchiveAttachment(val id: String, val fileName: String, val sha256: String, val byteLength: Long)

/** Streaming, plaintext portable archive. Never edits a source attachment. */
internal object ArchiveWriter {
    private val idPattern = Regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}")
    fun create(output: File, audioDirectory: File, manifest: String, attachments: List<ArchiveAttachment>) {
        check(!output.exists()) { "Use a fresh staging archive." }
        require(attachments.map { it.id }.toSet().size == attachments.size)
        try {
            ZipOutputStream(output.outputStream().buffered()).use { zip ->
                val metadata = manifest.toByteArray(Charsets.UTF_8)
                zip.putNextEntry(ZipEntry("manifest.json")); zip.write(metadata); zip.closeEntry()
                zip.putNextEntry(ZipEntry("manifest.sha256")); zip.write(hex(MessageDigest.getInstance("SHA-256").digest(metadata)).toByteArray()); zip.closeEntry()
                for (attachment in attachments) {
                    require(idPattern.matches(attachment.id) && attachment.fileName == "${attachment.id}.wav")
                    require(attachment.sha256.matches(Regex("[a-f0-9]{64}")))
                    val source = File(audioDirectory, attachment.fileName)
                    check(source.isFile && source.length() == attachment.byteLength)
                    val digest = MessageDigest.getInstance("SHA-256")
                    zip.putNextEntry(ZipEntry("attachments/${attachment.id}.wav"))
                    source.inputStream().use { input ->
                        val buffer = ByteArray(65536)
                        while (true) {
                            val count = input.read(buffer); if (count < 0) break
                            digest.update(buffer, 0, count); zip.write(buffer, 0, count)
                        }
                    }
                    check(hex(digest.digest()) == attachment.sha256) { "Attachment integrity failure." }
                    zip.closeEntry()
                }
            }
        } catch (error: Exception) { output.delete(); throw error }
    }
    private fun hex(bytes: ByteArray) = bytes.joinToString("") { "%02x".format(it.toInt() and 255) }
}
