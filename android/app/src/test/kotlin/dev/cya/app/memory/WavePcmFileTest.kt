package dev.cya.app.memory

import org.junit.Assert.*
import org.junit.Test
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.file.Files

class WavePcmFileTest {
    @Test fun headerMatchesManagedRecordingContract() {
        val data = ByteBuffer.wrap(WavePcmFile.header(32000)).order(ByteOrder.LITTLE_ENDIAN)
        assertEquals(32036, data.getInt(4)); assertEquals(16000, data.getInt(24))
        assertEquals(32000, data.getInt(28)); assertEquals(32000, data.getInt(40))
        assertEquals(1, data.getShort(22).toInt()); assertEquals(16, data.getShort(34).toInt())
    }

    @Test fun interruptedPayloadIsRecoveredWithoutChangingTheInterruptedSource() {
        val directory = Files.createTempDirectory("cya-native-wave-").toFile()
        try {
            val source = directory.resolve("source.part")
            val payload = byteArrayOf(0, 0, 127, 127, -128, -128)
            source.writeBytes(WavePcmFile.header(0) + payload + byteArrayOf(1))
            val original = source.readBytes()
            val recovered = directory.resolve("ready.wav")
            WavePcmFile.recover(source, recovered)
            assertArrayEquals(original, source.readBytes())
            assertArrayEquals(payload, recovered.readBytes().drop(44).toByteArray())
            assertEquals(payload.size, ByteBuffer.wrap(recovered.readBytes()).order(ByteOrder.LITTLE_ENDIAN).getInt(40))
        } finally { directory.deleteRecursively() }
    }

    @Test fun recoveryRefusesAnActiveWriter() {
        val directory = Files.createTempDirectory("cya-native-lock-").toFile()
        try {
            val source = directory.resolve("source.part").apply { writeBytes(WavePcmFile.header(0) + ByteArray(100)) }
            RandomAccessFile(source, "rw").use { writer -> writer.channel.lock().use {
                try { WavePcmFile.recover(source, directory.resolve("ready.wav")); fail("Recovery must not race an active writer") }
                catch (_: java.nio.channels.OverlappingFileLockException) { }
            } }
            assertFalse(directory.resolve("ready.wav").exists())
        } finally { directory.deleteRecursively() }
    }
}
