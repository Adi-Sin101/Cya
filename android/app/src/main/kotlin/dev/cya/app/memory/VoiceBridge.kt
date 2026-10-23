package dev.cya.app.memory

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.io.RandomAccessFile
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.Executors

/** Foreground local recording only. No speech service, transcript or model.
 * WAV/sidecar files stay app-private. They are not encrypted by SQLCipher.
 */
internal class VoiceBridge(private val activity: Activity) {
    companion object {
        const val REQUEST_AUDIO = 2302
        private const val RATE = 16000
        private const val MAX_BYTES = RATE * 2 * 300
        private val ID = Regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}")
    }
    private val directory = File(activity.filesDir, "memory_audio")
    private val control = Executors.newSingleThreadExecutor()
    @Volatile private var foreground = activity.hasWindowFocus()
    @Volatile private var session: Session? = null
    private var permissionResult: MethodChannel.Result? = null
    private var pendingStart: MethodChannel.Result? = null
    private var player: MediaPlayer? = null
    private var pendingPlayback: MethodChannel.Result? = null

    private class Session(val id: String, val started: Long) {
        @Volatile var stop = false
        @Volatile var recorder: AudioRecord? = null
        @Volatile var error: Exception? = null
        lateinit var thread: Thread
    }
    private fun file(id: String, suffix: String): File {
        require(ID.matches(id)) { "Invalid recording reference." }
        return File(directory, "$id.$suffix")
    }
    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        control.execute {
            try { val value = work(); activity.runOnUiThread { result.success(value) } }
            catch (error: Exception) {
                activity.runOnUiThread { result.error("local_audio_error",
                    "Could not complete local audio operation (${error.javaClass.simpleName}).", null) }
            }
        }
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                    if (permissionResult != null) { result.error("busy", "Microphone permission is already open.", null); return }
                    permissionResult = result
                    activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_AUDIO)
                } else begin(result)
            }
            "stop" -> background(result) {
                val id = requireNotNull(call.argument<String>("id"))
                val current = session
                if (current == null || current.id != id) return@background info(id)
                requestStop(current)
                current.thread.join(5000)
                check(!current.thread.isAlive) { "Recording is still finishing." }
                current.error?.let { throw it }
                info(current.id)
            }
            "pending" -> background(result) {
                val known = call.argument<List<String>>("knownIds").orEmpty().toSet()
                directory.listFiles().orEmpty().mapNotNull { candidate ->
                    candidate.name.substringBeforeLast('.').takeIf {
                        ID.matches(it) && candidate.extension in listOf("wav", "part") && it !in known &&
                            !(session?.let { active -> active.id == it && active.thread.isAlive } ?: false)
                    }
                }.distinct().take(50).map { id ->
                    val source = file(id, "wav").takeIf { it.exists() } ?: file(id, "part")
                    mapOf("id" to id, "capturedAtMillis" to capturedAt(id, source),
                        "durationMillis" to ((source.length() - 44).coerceAtLeast(0) * 1000 / (RATE * 2)),
                        "ready" to (source.extension == "wav"))
                }
            }
            "recover" -> background(result) {
                val id = requireNotNull(call.argument<String>("id"))
                check(session?.let { it.id == id && it.thread.isAlive } != true)
                if (!file(id, "wav").exists()) {
                    val partial = file(id, "part")
                    check(partial.length() > 44) { "No recoverable audio." }
                    val recovered = file(id, "recovering")
                    // Keep the interrupted source until explicit discard/delete.
                    WavePcmFile.recover(partial, recovered)
                    check(recovered.renameTo(file(id, "wav")))
                }
                info(id)
            }
            "play" -> {
                val id = call.argument<String>("id")
                if (id == null || !ID.matches(id)) { result.error("bad_args", "Invalid audio reference.", null); return }
                stopPlayback()
                pendingPlayback = result
                try {
                    val media = MediaPlayer()
                    player = media
                    media.setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
                    media.setDataSource(file(id, "wav").absolutePath)
                    val offset = (call.argument<Number>("offsetMillis")?.toInt() ?: 0).coerceAtLeast(0)
                    media.setOnPreparedListener {
                        try {
                            if (offset > 0) it.seekTo(offset)
                            it.start(); pendingPlayback?.success(true); pendingPlayback = null
                        } catch (error: Exception) { stopPlayback() }
                    }
                    media.setOnCompletionListener { stopPlayback() }
                    media.setOnErrorListener { _, _, _ ->
                        stopPlayback(); true
                    }
                    media.prepareAsync()
                } catch (error: Exception) {
                    stopPlayback()
                }
            }
            "stopPlayback" -> { stopPlayback(); result.success(null) }
            "stopAll" -> {
                stopPlayback()
                val current = session
                current?.let(::requestStop)
                background(result) {
                    current?.thread?.join(5000)
                    check(current?.thread?.isAlive != true) { "Recording is still stopping." }
                    null
                }
            }
            else -> result.notImplemented()
        }
    }

    fun permission(granted: Boolean) {
        val result = permissionResult ?: return
        permissionResult = null
        if (granted) {
            if (foreground) begin(result) else pendingStart = result
        } else result.error("microphone_denied", "Microphone permission was denied. Typed capture still works.", null)
    }

    @Suppress("MissingPermission")
    private fun begin(result: MethodChannel.Result) {
        if (session?.thread?.isAlive == true) { result.error("busy", "A recording is already in progress.", null); return }
        stopPlayback()
        val current = Session(UUID.randomUUID().toString(), System.currentTimeMillis())
        current.thread = Thread({
            runCatching { android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO) }
            var started = false
            try {
                check(foreground && !current.stop) { "Recording requires the foreground app." }
                directory.mkdirs()
                val bufferBytes = maxOf(16000, AudioRecord.getMinBufferSize(RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT))
                val recorder = AudioRecord.Builder().setAudioSource(MediaRecorder.AudioSource.MIC)
                    .setAudioFormat(AudioFormat.Builder().setSampleRate(RATE).setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT).build()).setBufferSizeInBytes(bufferBytes).build()
                current.recorder = recorder
                check(recorder.state == AudioRecord.STATE_INITIALIZED && foreground && !current.stop)
                file(current.id, "json").outputStream().use {
                    it.write(JSONObject().put("capturedAtMillis", current.started).toString().toByteArray())
                    it.fd.sync()
                }
                RandomAccessFile(file(current.id, "part"), "rw").use { output ->
                    output.channel.lock().use {
                    output.setLength(0); output.write(header(0)); output.fd.sync()
                    recorder.startRecording(); started = true
                    activity.runOnUiThread { result.success(mapOf("id" to current.id, "capturedAtMillis" to current.started)) }
                    val buffer = ByteArray(4096); var total = 0; var lastSync = SystemClock.elapsedRealtime()
                    while (!current.stop && foreground && total < MAX_BYTES) {
                        val count = recorder.read(buffer, 0, minOf(buffer.size, MAX_BYTES - total))
                        if (count <= 0 && (current.stop || !foreground)) break
                        check(count > 0) { "Microphone read failed." }
                        output.write(buffer, 0, count); total += count
                        if (SystemClock.elapsedRealtime() - lastSync >= 1000) {
                            output.fd.sync(); lastSync = SystemClock.elapsedRealtime()
                        }
                    }
                    check(total > 0) { "No audio recorded." }
                    output.seek(0); output.write(header(total)); output.fd.sync()
                    }
                }
                check(file(current.id, "part").renameTo(file(current.id, "wav")))
            } catch (error: Exception) {
                current.error = error
                if (!started) activity.runOnUiThread { result.error("recording_failed", "Could not start local recording. Check microphone access and storage.", null) }
            } finally {
                runCatching { current.recorder?.stop() }
                current.recorder?.release(); current.recorder = null
            }
        }, "CyaVoiceRecording")
        session = current
        current.thread.start()
    }

    private fun requestStop(current: Session) {
        current.stop = true
        runCatching { current.recorder?.stop() }
    }
    private fun capturedAt(id: String, source: File): Long = runCatching {
        JSONObject(file(id, "json").readText()).getLong("capturedAtMillis")
    }.getOrDefault(source.lastModified())

    private fun info(id: String): Map<String, Any> {
        val source = file(id, "wav")
        check(source.isFile && source.length() > 44 && source.length() <= MAX_BYTES + 44L)
        val digest = MessageDigest.getInstance("SHA-256")
        source.inputStream().use { input ->
            val buffer = ByteArray(65536)
            while (true) { val count = input.read(buffer); if (count < 0) break; digest.update(buffer, 0, count) }
        }
        return mapOf("id" to id, "fileName" to source.name, "byteLength" to source.length(),
            "sha256" to digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) },
            "durationMillis" to ((source.length() - 44) * 1000 / (RATE * 2)),
            "capturedAtMillis" to capturedAt(id, source))
    }

    fun foreground() {
        foreground = true
        pendingStart?.let { pendingStart = null; begin(it) }
    }
    fun background() {
        foreground = false
        session?.let(::requestStop)
        stopPlayback()
    }
    private fun stopPlayback() {
        pendingPlayback?.error("playback_stopped", "Playback stopped or could not start.", null)
        pendingPlayback = null
        player?.release(); player = null
    }
    fun close() {
        background()
        permissionResult?.error("interrupted", "Microphone request interrupted.", null)
        permissionResult = null
        pendingStart?.error("interrupted", "Recording start interrupted.", null)
        pendingStart = null
        control.shutdown()
    }

    private fun header(bytes: Int): ByteArray = WavePcmFile.header(bytes)
}
