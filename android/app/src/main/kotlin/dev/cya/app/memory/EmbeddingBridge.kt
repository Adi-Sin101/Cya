package dev.cya.app.memory

import android.app.Activity
import android.content.Intent
import com.google.ai.edge.litertlm.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.Executors

/** Only the foreground Flutter host owns this bridge, never a capture surface.
 * No URL, HTTP client, auto-download, account or remote inference path exists.
 */
internal class EmbeddingBridge(private val activity: Activity) {
    companion object {
        const val REQUEST_MODEL = 2301
        const val SHA256 = "e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c"
        const val MODEL_BYTES = 484622336L
    }
    private val executor = Executors.newSingleThreadExecutor { work ->
        Thread(work, "CyaLocalEmbeddings").apply { priority = Thread.MIN_PRIORITY }
    }
    private val directory = File(activity.filesDir, "memory_models")
    private val model = File(directory, "embeddinggemma-2.litertlm")
    private val verified = File(directory, "verified.sha256")
    private var engine: EmbeddingEngine? = null
    private var checkedModel = false
    private var pendingInstall: MethodChannel.Result? = null

    private fun installed() = model.isFile && model.length() == MODEL_BYTES &&
        verified.isFile && verified.readText() == SHA256

    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        executor.execute {
            try {
                val value = work()
                activity.runOnUiThread { result.success(value) }
            } catch (error: Exception) {
                // No source text, audio, key or filesystem path in error payloads.
                activity.runOnUiThread { result.error("local_model_error",
                    "Local model operation failed (${error.javaClass.simpleName}).", null) }
            } catch (error: LinkageError) {
                activity.runOnUiThread { result.error("unsupported_runtime",
                    "The local model runtime is unavailable on this device.", null) }
            }
        }
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "installed" -> background(result) { installed() }
            "unload" -> background(result) { engine?.close(); engine = null; null }
            "install" -> {
                if (pendingInstall != null) { result.error("busy", "Model installation is already open.", null); return }
                pendingInstall = result
                try {
                    activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "*/*"
                        putExtra(Intent.EXTRA_LOCAL_ONLY, true)
                    }, REQUEST_MODEL)
                } catch (error: Exception) {
                    pendingInstall = null
                    result.error("picker_unavailable", "Could not open the local file picker.", null)
                }
            }
            "embedText" -> {
                val text = call.argument<String>("text")
                if (text == null || text.length > 10000) { result.error("bad_args", "A bounded text input is required.", null); return }
                background(result) { embedding(listOf(InputData.Text(text))) }
            }
            "embedAudio" -> {
                val wav = call.argument<ByteArray>("wav")
                if (wav == null || wav.size > 1000000) { result.error("bad_args", "A bounded WAV segment is required.", null); return }
                background(result) { embedding(listOf(InputData.Audio(wav))) }
            }
            else -> result.notImplemented()
        }
    }

    private fun embedding(input: List<InputData>): List<Double> {
        check(installed()) { "Install the verified local model first." }
        if (!checkedModel) {
            val digest = MessageDigest.getInstance("SHA-256")
            model.inputStream().use { source ->
                val buffer = ByteArray(65536)
                while (true) {
                    val count = source.read(buffer)
                    if (count < 0) break
                    digest.update(buffer, 0, count)
                }
            }
            val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
            if (actual != SHA256) {
                verified.delete()
                throw IllegalStateException("Local model integrity check failed.")
            }
            checkedModel = true
        }
        val active = engine ?: EmbeddingEngine(EmbeddingEngineConfig(
            modelPath = model.absolutePath, backend = Backend.CPU(threadCount = 2),
            visionBackend = null, audioBackend = Backend.CPU(threadCount = 2),
            activationDataType = ActivationDataType.FLOAT32,
            cacheDir = File(activity.cacheDir, "embeddinggemma-2").also { it.mkdirs() }.absolutePath,
        )).also { candidate ->
            try { candidate.initialize(); engine = candidate }
            catch (error: Exception) { candidate.close(); throw error }
        }
        val vector = active.computeEmbedding(input, EmbeddingOptions(
            normalize = true, outputSize = 256, insertSpecialTokens = true,
        )).embedding
        check(vector.size == 256 && vector.all { it.isFinite() }) { "Invalid embedding." }
        return vector.map { it.toDouble() }
    }

    fun onActivityResult(request: Int, code: Int, data: Intent?): Boolean {
        if (request != REQUEST_MODEL) return false
        val result = pendingInstall ?: return true
        pendingInstall = null
        val uri = data?.data
        if (code != Activity.RESULT_OK || uri == null) { result.success(false); return true }
        background(result) {
            directory.mkdirs()
            val staging = File(directory, "${UUID.randomUUID()}.installing")
            try {
                val digest = MessageDigest.getInstance("SHA-256")
                var total = 0L
                activity.contentResolver.openInputStream(uri).use { source ->
                    checkNotNull(source)
                    staging.outputStream().use { target ->
                        val buffer = ByteArray(65536)
                        while (true) {
                            val count = source.read(buffer)
                            if (count < 0) break
                            total += count
                            check(total <= MODEL_BYTES) { "Wrong model size." }
                            digest.update(buffer, 0, count)
                            target.write(buffer, 0, count)
                        }
                        target.fd.sync()
                    }
                }
                val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) }
                check(total == MODEL_BYTES && actual == SHA256) { "Wrong model artifact." }
                engine?.close(); engine = null
                checkedModel = false
                check(staging.renameTo(model)) { "Cannot install model." }
                verified.writeText(SHA256)
                true
            } finally { staging.delete() }
        }
        return true
    }

    fun close() {
        pendingInstall?.error("closed", "Model installation was interrupted. Try again.", null)
        pendingInstall = null
        executor.execute { engine?.close(); engine = null }
        executor.shutdown()
    }
}
