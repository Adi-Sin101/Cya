package dev.cya.app.privacy

import org.junit.Assert.*
import org.junit.Test
import java.nio.file.Files
import java.security.MessageDigest
import java.util.zip.ZipFile

class ArchiveWriterTest {
    private val id = "00000000-0000-4000-8000-000000000001"
    private fun hash(data: ByteArray) = MessageDigest.getInstance("SHA-256").digest(data)
        .joinToString("") { "%02x".format(it.toInt() and 255) }

    @Test fun archiveContainsManifestIntegrityAndExactOriginalAttachment() {
        val root = Files.createTempDirectory("cya-archive-").toFile()
        try {
            val audio = root.resolve("audio").apply { mkdirs() }
            val bytes = byteArrayOf(1, 2, 3, 4)
            audio.resolve("$id.wav").writeBytes(bytes)
            val manifest = "{\"format\":\"cya.export\",\"formatVersion\":4}"
            val output = root.resolve("export.zip")
            ArchiveWriter.create(output, audio, manifest, listOf(ArchiveAttachment(id, "$id.wav", hash(bytes), bytes.size.toLong())))
            ZipFile(output).use { zip ->
                assertEquals(manifest, zip.getInputStream(zip.getEntry("manifest.json")).reader().readText())
                assertEquals(hash(manifest.toByteArray()), zip.getInputStream(zip.getEntry("manifest.sha256")).reader().readText())
                assertArrayEquals(bytes, zip.getInputStream(zip.getEntry("attachments/$id.wav")).readBytes())
            }
            assertArrayEquals(bytes, audio.resolve("$id.wav").readBytes())
        } finally { root.deleteRecursively() }
    }

    @Test fun corruptionAndPathTraversalNeverProduceAPartialSharedArchive() {
        val root = Files.createTempDirectory("cya-archive-bad-").toFile()
        try {
            val audio = root.resolve("audio").apply { mkdirs() }
            audio.resolve("$id.wav").writeBytes(byteArrayOf(1, 2))
            for (attachment in listOf(
                ArchiveAttachment(id, "$id.wav", "0".repeat(64), 2),
                ArchiveAttachment(id, "../secret.wav", "0".repeat(64), 2),
            )) {
                val output = root.resolve("export.zip")
                try { ArchiveWriter.create(output, audio, "{}", listOf(attachment)); fail("Invalid attachment must fail") }
                catch (_: Exception) { }
                assertFalse(output.exists())
                assertTrue(audio.resolve("$id.wav").exists())
            }
        } finally { root.deleteRecursively() }
    }
}
