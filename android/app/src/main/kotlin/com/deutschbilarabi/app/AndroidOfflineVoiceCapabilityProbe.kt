package com.deutschbilarabi.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class AndroidOfflineVoiceCapabilityProbe(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/offline_voice_capability"
        private const val TIMEOUT_MS = 3000L
    }

    private var tts: TextToSpeech? = null
    private var isDisposed = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "probeCapabilities" -> probeCapabilities(result)
            else -> result.notImplemented()
        }
    }

    private fun probeCapabilities(result: MethodChannel.Result) {
        if (isDisposed) {
            result.success(mapOf("status" to "unavailable", "reason" to "disposed"))
            return
        }

        val handler = Handler(Looper.getMainLooper())
        var isResultReturned = false

        val timeoutRunnable = Runnable {
            if (!isResultReturned) {
                isResultReturned = true
                cleanupTts()
                result.success(mapOf("status" to "unavailable", "reason" to "timeout"))
            }
        }

        handler.postDelayed(timeoutRunnable, TIMEOUT_MS)

        try {
            tts = TextToSpeech(context) { status ->
                handler.removeCallbacks(timeoutRunnable)
                if (isResultReturned) return@TextToSpeech

                isResultReturned = true

                if (status == TextToSpeech.SUCCESS) {
                    processVoices(result)
                } else {
                    cleanupTts()
                    result.success(mapOf("status" to "unavailable", "reason" to "initialization_failed"))
                }
            }
        } catch (e: SecurityException) {
            handler.removeCallbacks(timeoutRunnable)
            if (!isResultReturned) {
                isResultReturned = true
                cleanupTts()
                result.success(mapOf("status" to "unavailable", "reason" to "security_exception"))
            }
        } catch (e: Exception) {
            handler.removeCallbacks(timeoutRunnable)
            if (!isResultReturned) {
                isResultReturned = true
                cleanupTts()
                result.success(mapOf("status" to "unavailable", "reason" to "unknown_error"))
            }
        }
    }

    private fun processVoices(result: MethodChannel.Result) {
        try {
            val voices = tts?.voices
            if (voices == null) {
                cleanupTts()
                result.success(mapOf("status" to "unavailable", "reason" to "voices_null"))
                return
            }

            val availableLocales = mutableSetOf<String>()

            for (voice in voices) {
                if (voice.isNetworkConnectionRequired) continue
                if (voice.features?.contains(TextToSpeech.Engine.KEY_FEATURE_NETWORK_SYNTHESIS) == true) continue
                if (voice.features?.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED) == true) continue

                // Try getting BCP-47 Language Tag
                val languageTag = try {
                    voice.locale.toLanguageTag()
                } catch (e: Exception) {
                    continue
                }

                if (languageTag.isNotEmpty() && languageTag != "und") {
                    availableLocales.add(languageTag)
                }
            }

            cleanupTts()
            result.success(mapOf("status" to "success", "locales" to availableLocales.toList()))
        } catch (e: Exception) {
            cleanupTts()
            result.success(mapOf("status" to "unavailable", "reason" to "processing_error"))
        }
    }

    private fun cleanupTts() {
        try {
            tts?.shutdown()
        } catch (_: Exception) {}
        tts = null
    }

    fun dispose() {
        isDisposed = true
        cleanupTts()
    }
}
