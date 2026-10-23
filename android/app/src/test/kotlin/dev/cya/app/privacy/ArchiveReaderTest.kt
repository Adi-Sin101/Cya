package dev.cya.app.privacy

import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.file.Files
import java.security.MessageDigest
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import org.junit.Assert.*
import org.junit.Test

class ArchiveReaderTest {
    private fun zip(entries: List<Pair<String,ByteArray>>): ByteArray {
        val out = ByteArrayOutputStream()
        ZipOutputStream(out).use { zip -> entries.forEach { (name,bytes) -> zip.putNextEntry(ZipEntry(name)); zip.write(bytes); zip.closeEntry() } }
        return out.toByteArray()
    }
    @Test fun validManifestRoundTripAndTamperRejection() {
        val root = Files.createTempDirectory("cya-import-test").toFile()
        try {
            val manifest = "{\"format\":\"cya.export\"}".toByteArray()
            val digest = MessageDigest.getInstance("SHA-256").digest(manifest).joinToString("") { "%02x".format(it.toInt() and 255) }.toByteArray()
            val bytes = zip(listOf("manifest.json" to manifest,"manifest.sha256" to digest))
            assertEquals(String(manifest),ArchiveReader.read(ByteArrayInputStream(bytes),File(root,"good"),true))
            val bad = zip(listOf("manifest.json" to "changed".toByteArray(),"manifest.sha256" to digest))
            assertThrows(Exception::class.java) { ArchiveReader.read(ByteArrayInputStream(bad),File(root,"bad"),true) }
            assertFalse(File(root,"bad").exists())
        } finally { root.deleteRecursively() }
    }
    @Test fun pathTraversalAndUnknownEntriesCannotEscapeStaging() {
        val root = Files.createTempDirectory("cya-import-path-test").toFile()
        try {
            for (name in listOf("../outside.wav","/absolute","attachments/nested/file.wav","unknown.json")) {
                assertThrows(Exception::class.java) { ArchiveReader.read(ByteArrayInputStream(zip(listOf(name to byteArrayOf(1)))),File(root,"stage"),true) }
                assertFalse(File(root,"stage").exists())
            }
            assertFalse(File(root,"outside.wav").exists())
        } finally { root.deleteRecursively() }
    }
    @Test fun actualUncompressedManifestLimitIsEnforced() {
        val root = Files.createTempDirectory("cya-import-limit-test").toFile()
        try {
            val bytes = zip(listOf("manifest.json" to ByteArray(ArchiveReader.MANIFEST_LIMIT.toInt()+1)))
            assertThrows(Exception::class.java) { ArchiveReader.read(ByteArrayInputStream(bytes),File(root,"stage"),true) }
            assertFalse(File(root,"stage").exists())
        } finally { root.deleteRecursively() }
    }
}
