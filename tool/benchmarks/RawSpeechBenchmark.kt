package dev.cya.embeddingprobe

import android.content.res.AssetManager
import android.os.Debug
import android.os.SystemClock
import android.util.Log
import com.google.ai.edge.litertlm.*
import org.json.JSONArray
import org.json.JSONObject

/** Developer-only isolated minified probe. Never reads Cya! or personal sources.
 * Assets: speech/samples.json, queries.json and managed public PCM16 WAVs.
 * Transcripts are query/reference labels only; audio encodings receive WAV bytes.
 */
object RawSpeechBenchmark {
  fun run(engine: EmbeddingEngine, assets: AssetManager) {
    val started = SystemClock.elapsedRealtime()
    val samples = JSONArray(assets.open("speech/samples.json").bufferedReader().use { it.readText() })
    val queries = JSONArray(assets.open("speech/queries.json").bufferedReader().use { it.readText() })
    val options = EmbeddingOptions(normalize=true, outputSize=256, insertSpecialTokens=true)
    val audio = mutableListOf<FloatArray>()
    val text = mutableListOf<FloatArray>()
    var observedPss = 0
    fun memory(): Int {
      val pss = Debug.MemoryInfo().also { Debug.getMemoryInfo(it) }.totalPss
      observedPss = maxOf(observedPss, pss)
      return pss
    }
    fun valid(vector: FloatArray) {
      check(vector.size==256 && vector.all { it.isFinite() })
      check(kotlin.math.abs(vector.sumOf { (it*it).toDouble() }-1.0)<0.001)
    }
    fun score(a:FloatArray,b:FloatArray) = a.indices.sumOf { (a[it]*b[it]).toDouble() }
    fun ranked(query:FloatArray, candidates:List<FloatArray>) = candidates.indices.sortedByDescending { score(query,candidates[it]) }
    val audioTimes = mutableListOf<Long>()
    val queryTimes = mutableListOf<Long>()
    for(i in 0 until samples.length()) {
      val row=samples.getJSONObject(i)
      val wav=assets.open("speech/"+row.getString("file")).use { it.readBytes() }
      val at=SystemClock.elapsedRealtime()
      val vector=engine.computeEmbedding(listOf(InputData.Audio(wav)),options).embedding
      valid(vector);audio.add(vector);audioTimes.add(SystemClock.elapsedRealtime()-at)
      val document=engine.computeEmbedding(listOf(InputData.Text("title: none | text: "+row.getString("raw_transcription"))),options).embedding
      valid(document);text.add(document)
      Log.i("CyaSpeechBench",JSONObject().put("audio",i).put("ms",audioTimes.last()).put("seconds",row.getDouble("seconds")).put("pss_kib",memory()).toString())
    }
    val groups=mutableMapOf<String,MutableList<Int>>()
    val textGroups=mutableMapOf<String,MutableList<Int>>()
    for(i in 0 until queries.length()) {
      val row=queries.getJSONObject(i)
      val at=SystemClock.elapsedRealtime()
      val vector=engine.computeEmbedding(listOf(InputData.Text("task: search result | query: "+row.getString("query"))),options).embedding
      valid(vector);queryTimes.add(SystemClock.elapsedRealtime()-at)
      val indices=ranked(vector,audio)
      val expected=row.optInt("source",-1)
      val expectedId=if(expected>=0)samples.getJSONObject(expected).getString("sentence_id") else ""
      fun relevant(index:Int) = samples.getJSONObject(index).getString("sentence_id")==expectedId
      val rank=if(expected<0)0 else indices.indexOfFirst { relevant(it) }+1
      if(expected>=0) {
        groups.getOrPut(row.getString("group")){mutableListOf()}.add(rank)
        val textRank=ranked(vector,text).indexOfFirst { relevant(it) }+1
        textGroups.getOrPut(row.getString("group")){mutableListOf()}.add(textRank)
      }
      Log.i("CyaSpeechBench",JSONObject().put("query",i).put("group",row.getString("group")).put("rank",rank).put("top_source",indices.first()).put("top_score",score(vector,audio[indices.first()])).put("ms",queryTimes.last()).toString())
    }
    val relatedRanks=audio.indices.map { i -> ranked(audio[i],text).indexOfFirst {
      samples.getJSONObject(it).getString("sentence_id")==samples.getJSONObject(i).getString("sentence_id")
    }+1 }
    fun metrics(ranks:List<Int>) = JSONObject().put("queries",ranks.size)
      .put("hit_at_1",ranks.count{it==1}.toDouble()/ranks.size)
      .put("recall_at_5",ranks.count{it in 1..5}.toDouble()/ranks.size)
      .put("mrr",ranks.sumOf{if(it>0)1.0/it else 0.0}/ranks.size)
    fun quantile(values:List<Long>,p:Double) = values.sorted()[((values.size-1)*p).toInt()]
    val result=JSONObject().put("audio_sources",audio.size).put("queries",queries.length())
      .put("total_ms",SystemClock.elapsedRealtime()-started).put("observed_pss_max_kib",maxOf(observedPss,memory()))
      .put("audio_p50_ms",quantile(audioTimes,0.5)).put("audio_p95_ms",quantile(audioTimes,0.95))
      .put("query_p50_ms",quantile(queryTimes,0.5)).put("query_p95_ms",quantile(queryTimes,0.95))
      .put("audio_to_reference_text",metrics(relatedRanks))
      .put("audio",JSONObject().also { out->groups.forEach{(k,v)->out.put(k,metrics(v))} })
      .put("text",JSONObject().also { out->textGroups.forEach{(k,v)->out.put(k,metrics(v))} })
    Log.i("CyaSpeechBench","RESULT "+result.toString())
  }
}
