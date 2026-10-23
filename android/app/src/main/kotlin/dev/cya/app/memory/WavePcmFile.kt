package dev.cya.app.memory

import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

internal object WavePcmFile {
    const val RATE = 16000
    const val MAX_BYTES = RATE * 2 * 300
    fun header(bytes: Int): ByteArray {
        require(bytes >= 0 && bytes <= MAX_BYTES && bytes % 2 == 0)
        return ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN).apply {
            put("RIFF".toByteArray()); putInt(36 + bytes); put("WAVEfmt ".toByteArray()); putInt(16)
            putShort(1); putShort(1); putInt(RATE); putInt(RATE * 2); putShort(2); putShort(16)
            put("data".toByteArray()); putInt(bytes)
        }.array()
    }

    fun recover(partial: File, output: File) {
        check(partial.length() > 45) { "No complete recoverable sample." }
        val bytes = ((partial.length() - 44) / 2 * 2).coerceAtMost(MAX_BYTES.toLong()).toInt()
        RandomAccessFile(partial, "r").use { source ->
            val lock = source.channel.tryLock(0, Long.MAX_VALUE, true)
                ?: throw IllegalStateException("Recording is still being finalized.")
            lock.use {
                RandomAccessFile(output, "rw").use { target ->
                    target.setLength(0); target.write(header(bytes)); source.seek(44)
                    val buffer = ByteArray(32768); var left = bytes
                    while (left > 0) {
                        val count = source.read(buffer, 0, minOf(left, buffer.size))
                        check(count > 0); target.write(buffer, 0, count); left -= count
                    }
                    target.fd.sync()
                }
            }
        }
    }
}
