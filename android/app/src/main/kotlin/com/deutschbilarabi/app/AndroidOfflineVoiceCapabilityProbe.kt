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

internal fun offlineVoiceLanguageTags(
    voices: Iterable<VoiceCapabilitySnapshot>?,
): List<String> {
    if (voices == null) return emptyList()
    return voices.mapNotNull { voice ->
        val installedOffline = !voice.networkConnectionRequired &&
            !voice.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
        if (installedOffline && voice.languageTag.isNotBlank()) {
            voice.languageTag
        } else {
            null
        }
    }.distinct()
}

class AndroidOfflineVoiceCapabilityProbe(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/offline_voice_capability"
        const val METHOD_GET_OFFLINE_VOICES = "getOfflineVoices"
        private const val INIT_TIMEOUT_MS = 3000L
    }

    private var tts: TextToSpeech? = null
    private val isProbing = AtomicBoolean(false)
    private var pendingResult: MethodChannel.Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == METHOD_GET_OFFLINE_VOICES) {
            probeOfflineVoices(result)
        } else {
            result.notImplemented()
        }
    }

    private fun probeOfflineVoices(result: MethodChannel.Result) {
        if (!isProbing.compareAndSet(false, true)) {
            result.success(emptyList<String>())
            return
        }

        pendingResult = result
        val timeoutRunnable = Runnable { finishProbe(emptyList()) }
        mainHandler.postDelayed(timeoutRunnable, INIT_TIMEOUT_MS)

        try {
            tts = TextToSpeech(context) { status ->
                mainHandler.removeCallbacks(timeoutRunnable)
                if (!isProbing.get()) {
                    shutDownTts()
                    return@TextToSpeech
                }
                if (status == TextToSpeech.SUCCESS) {
                    finishProbe(readOfflineVoices())
                } else {
                    finishProbe(emptyList())
                }
            }
        } catch (e: SecurityException) {
            mainHandler.removeCallbacks(timeoutRunnable)
            finishProbe(emptyList())
        } catch (e: Exception) {
            mainHandler.removeCallbacks(timeoutRunnable)
            finishProbe(emptyList())
        }
    }

    private fun readOfflineVoices(): List<String> {
        val engine = tts ?: return emptyList()
        return try {
            val voices = engine.voices ?: return emptyList()
            offlineVoiceLanguageTags(
                voices.mapNotNull { voice ->
                    val tag = voice.locale?.toLanguageTag() ?: return@mapNotNull null
                    VoiceCapabilitySnapshot(
                        languageTag = tag,
                        networkConnectionRequired = voice.isNetworkConnectionRequired,
                        features = voice.features ?: emptySet(),
                    )
                },
            )
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun finishProbe(locales: List<String>) {
        if (!isProbing.compareAndSet(true, false)) return
        val res = pendingResult
        pendingResult = null
        mainHandler.post { res?.success(locales) }
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
            pendingResult = null
            res?.success(emptyList<String>())
        }
        shutDownTts()
    }
}
