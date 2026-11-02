package com.deutschbilarabi.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

/**
 * On-device TTS voice inventory for the dictation screen.
 *
 * Dart calls [CHANNEL_NAME] method [METHOD_GET_OFFLINE_VOICES] and expects a
 * list of BCP-47 tags. Network voices and missing engines are omitted. Every
 * failure returns an empty list so the caller stays on text practice.
 */
internal data class VoiceCapabilitySnapshot(
    val languageTag: String,
    val networkConnectionRequired: Boolean,
    val features: Set<String>,
)

internal enum class VoiceState {
    SUPPORTED, MISSING, UNAVAILABLE, UNKNOWN
}

internal fun classifyVoiceState(voice: VoiceCapabilitySnapshot): VoiceState {
    if (voice.languageTag.isBlank()) return VoiceState.UNKNOWN
    if (voice.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)) return VoiceState.MISSING
    if (voice.networkConnectionRequired) return VoiceState.UNAVAILABLE
    return VoiceState.SUPPORTED
}

internal fun offlineVoiceLanguageTags(
    voices: Iterable<VoiceCapabilitySnapshot>?,
): List<String> {
    if (voices == null) return emptyList()
    return voices.mapNotNull { voice ->
        if (classifyVoiceState(voice) == VoiceState.SUPPORTED) {
            voice.languageTag
        } else {
            null
        }
    }.distinct()
}

internal fun buildCapabilityReport(voices: Iterable<VoiceCapabilitySnapshot>?): String {
    val b = StringBuilder()
    b.append("{\"version\":\"1.0\",")
    b.append("\"status\":")
    if (voices == null) {
        b.append("\"unavailable\",")
        b.append("\"voices\":[]}")
        return b.toString()
    }
    b.append("\"available\",")
    b.append("\"voices\":[")

    val voiceList = voices.toList()

    // Group voices by tag, find the best state (SUPPORTED > MISSING > UNAVAILABLE > UNKNOWN)
    val bestVoices = voiceList.groupBy { it.languageTag }.mapValues { (_, group) ->
        group.map { classifyVoiceState(it) }.minByOrNull { it.ordinal } ?: VoiceState.UNKNOWN
    }.toList()

    for ((index, pair) in bestVoices.withIndex()) {
        val (tag, state) = pair
        b.append("{\"languageTag\":\"${tag}\",\"state\":\"${state.name.lowercase()}\"}")
        if (index < bestVoices.size - 1) {
            b.append(",")
        }
    }
    b.append("]}")
    return b.toString()
}

class AndroidOfflineVoiceCapabilityProbe(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/offline_voice_capability"
        const val PROBE_CHANNEL_NAME = "com.deutschbilarabi.app/tts_capability_probe"
        const val METHOD_GET_OFFLINE_VOICES = "getOfflineVoices"
        const val METHOD_PROBE_CAPABILITIES = "probeCapabilities"
        private const val INIT_TIMEOUT_MS = 3000L
    }

    private var tts: TextToSpeech? = null
    private val isProbing = AtomicBoolean(false)
    private var pendingResult: MethodChannel.Result? = null
    private var pendingMethod: String? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_GET_OFFLINE_VOICES -> probeOfflineVoices(result, METHOD_GET_OFFLINE_VOICES)
            METHOD_PROBE_CAPABILITIES -> probeOfflineVoices(result, METHOD_PROBE_CAPABILITIES)
            else -> result.notImplemented()
        }
    }

    private fun probeOfflineVoices(result: MethodChannel.Result, method: String) {
        if (!isProbing.compareAndSet(false, true)) {
            if (method == METHOD_GET_OFFLINE_VOICES) {
                result.success(emptyList<String>())
            } else {
                result.success(buildCapabilityReport(null))
            }
            return
        }

        pendingResult = result
        pendingMethod = method
        val timeoutRunnable = Runnable { finishProbe(null) }
        mainHandler.postDelayed(timeoutRunnable, INIT_TIMEOUT_MS)

        try {
            tts = TextToSpeech(context) { status ->
                mainHandler.removeCallbacks(timeoutRunnable)
                if (!isProbing.get()) {
                    shutDownTts()
                    return@TextToSpeech
                }
                if (status == TextToSpeech.SUCCESS) {
                    finishProbe(readAllVoices())
                } else {
                    finishProbe(null)
                }
            }
        } catch (e: SecurityException) {
            mainHandler.removeCallbacks(timeoutRunnable)
            finishProbe(null)
        } catch (e: Exception) {
            mainHandler.removeCallbacks(timeoutRunnable)
            finishProbe(null)
        }
    }

    private fun readAllVoices(): List<VoiceCapabilitySnapshot>? {
        val engine = tts ?: return null
        return try {
            val voices = engine.voices ?: return null
            voices.mapNotNull { voice ->
                val tag = voice.locale?.toLanguageTag() ?: return@mapNotNull null
                VoiceCapabilitySnapshot(
                    languageTag = tag,
                    networkConnectionRequired = voice.isNetworkConnectionRequired,
                    features = voice.features ?: emptySet(),
                )
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun finishProbe(voices: List<VoiceCapabilitySnapshot>?) {
        if (!isProbing.compareAndSet(true, false)) return
        val res = pendingResult
        val method = pendingMethod
        pendingResult = null
        pendingMethod = null
        mainHandler.post {
            if (method == METHOD_GET_OFFLINE_VOICES) {
                res?.success(offlineVoiceLanguageTags(voices))
            } else {
                res?.success(buildCapabilityReport(voices))
            }
        }
        shutDownTts()
    }

    private fun shutDownTts() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (e: Exception) {
            // Shutdown stays on device. Ignore engine errors.
        } finally {
            tts = null
        }
    }

    fun destroy() {
        mainHandler.removeCallbacksAndMessages(null)
        if (isProbing.compareAndSet(true, false)) {
            val res = pendingResult
            val method = pendingMethod
            pendingResult = null
            pendingMethod = null
            if (method == METHOD_GET_OFFLINE_VOICES) {
                res?.success(emptyList<String>())
            } else {
                res?.success(buildCapabilityReport(null))
            }
        }
        shutDownTts()
    }
}
