package dev.cya.app.privacy

import android.app.Activity
import android.content.Intent
import java.io.File
import java.io.PushbackInputStream
import java.util.UUID
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class ImportBridge(private val activity: Activity) {
    private var pending: MethodChannel.Result? = null
    private val uuid = Regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}")
    private fun stage(token: String): File {
        require(uuid.matches(token)); return File(activity.cacheDir, "cya-imports/$token")
    }
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "pick" -> {
                if (pending != null) { result.error("busy", "An import selection is open.",null); return }
                pending = result
                try {
                    activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE); type = "*/*"
                        putExtra(Intent.EXTRA_LOCAL_ONLY,true)
                        putExtra(Intent.EXTRA_MIME_TYPES,arrayOf("application/json","application/zip","application/octet-stream"))
                    }, REQUEST)
                } catch (error: Exception) { pending = null; result.error("unavailable","No local document picker.",null) }
            }
            "finish" -> work(result) {
                val token = call.argument<String>("token") ?: error("Missing token")
                val directory = stage(token)
                directory.deleteRecursively(); null
            }
            "copyAttachments" -> work(result) {
                val directory = stage(call.argument<String>("token") ?: error("Missing token"))
                check(directory.isDirectory)
                val mappings = call.argument<List<Map<String,Any>>>("attachments") ?: error("Missing attachments")
                val expected = mappings.map { it["fileName"] as String }.toSet()
                require(expected.size == mappings.size)
                require(directory.listFiles()!!.filter { it.extension == "wav" }.map { it.name }.toSet() == expected)
                val destination = File(activity.filesDir,"memory_audio").apply { mkdirs() }
                val created = mutableListOf<File>()
                try {
                    for (item in mappings) {
                        val oldName = item["fileName"] as String
                        val newId = item["newId"] as String
                        require(oldName.endsWith(".wav") && uuid.matches(oldName.removeSuffix(".wav")) && uuid.matches(newId))
                        val source = File(directory,oldName)
                        require(source.length() == (item["byteLength"] as Number).toLong())
                        require(ArchiveReader.digest(source) == item["sha256"])
                        val target = File(destination,"$newId.wav")
                        check(target.createNewFile())
                        created.add(target)
                        source.inputStream().use { input -> target.outputStream().use { output -> input.copyTo(output); output.fd.sync() } }
                    }
                    true
                } catch(error: Exception) { created.forEach { it.delete() }; throw error }
            }
            else -> result.notImplemented()
        }
    }
    fun onResult(request: Int, code: Int, data: Intent?): Boolean {
        if (request != REQUEST) return false
        val result = pending ?: return true
        pending = null
        val uri = data?.data
        if (code != Activity.RESULT_OK || uri == null) { result.success(null); return true }
        work(result) {
            val root = File(activity.cacheDir,"cya-imports").apply { mkdirs() }
            val token = UUID.randomUUID().toString()
            val directory = File(root,token)
            val input = PushbackInputStream(activity.contentResolver.openInputStream(uri) ?: error("Unreadable file"),4)
            val head = ByteArray(4); val n = input.read(head); if (n > 0) input.unread(head,0,n)
            val zipped = n == 4 && head[0] == 0x50.toByte() && head[1] == 0x4b.toByte()
            val manifest = ArchiveReader.read(input,directory,zipped)
            mapOf("token" to token,"manifest" to manifest,
                "files" to directory.listFiles()!!.filter { it.extension == "wav" }.map { it.name })
        }
        return true
    }
    private fun work(result: MethodChannel.Result, block: () -> Any?) {
        Thread {
            try { val value = block(); activity.runOnUiThread { result.success(value) } }
            catch(error: Exception) { activity.runOnUiThread { result.error("import_failed","Backup could not be validated or copied. Existing data is unchanged.",null) } }
        }.start()
    }
    fun close() { pending?.error("closed","Selection interrupted. Select the file again.",null); pending = null }
    companion object { const val REQUEST = 2303 }
}
