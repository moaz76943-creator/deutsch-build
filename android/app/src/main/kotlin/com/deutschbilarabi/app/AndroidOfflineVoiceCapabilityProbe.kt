package com.deutschbilarabi.app

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.Voice
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
import android.os.Handler
import android.os.Looper

class AndroidOfflineVoiceCapabilityProbe(
    private val context: Context
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/offline_voice_capability"
    }

    private var tts: TextToSpeech? = null
    private var isProbing = AtomicBoolean(false)
    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "probe") {
            probe(result)
        } else {
            result.notImplemented()
        }
    }

    private fun probe(result: MethodChannel.Result) {
        if (!isProbing.compareAndSet(false, true)) {
            result.success(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "probe_already_in_progress"
                )
            )
            return
        }

        pendingResult = result

        val handler = Handler(Looper.getMainLooper())
        val timeoutRunnable = Runnable {
            if (isProbing.get()) {
                finishProbe(
                    mapOf(
                        "version" to 1,
                        "status" to "unavailable",
                        "reason" to "tts_initialization_timeout"
                    )
                )
            }
        }

        handler.postDelayed(timeoutRunnable, 3000)

        try {
            tts = TextToSpeech(context) { status ->
                handler.removeCallbacks(timeoutRunnable)
                if (status == TextToSpeech.SUCCESS) {
                    handleTtsInitialized()
                } else {
                    finishProbe(
                        mapOf(
                            "version" to 1,
                            "status" to "unavailable",
                            "reason" to "tts_initialization_failed"
                        )
                    )
                }
            }
        } catch (e: SecurityException) {
            handler.removeCallbacks(timeoutRunnable)
            finishProbe(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "security_exception"
                )
            )
        } catch (e: Exception) {
            handler.removeCallbacks(timeoutRunnable)
            finishProbe(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "unknown_error"
                )
            )
        }
    }

    private fun handleTtsInitialized() {
        val ttsInstance = tts
        if (ttsInstance == null) {
            finishProbe(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "tts_instance_null"
                )
            )
            return
        }

        try {
            val voices = ttsInstance.voices
            if (voices == null) {
                finishProbe(
                    mapOf(
                        "version" to 1,
                        "status" to "unavailable",
                        "reason" to "voices_unavailable"
                    )
                )
                return
            }

            val offlineVoices = voices.filter { voice ->
                val features = voice.features ?: emptySet()
                !voice.isNetworkConnectionRequired && !features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
            }.map { voice ->
                voice.locale.toLanguageTag()
            }.distinct()

            finishProbe(
                mapOf(
                    "version" to 1,
                    "status" to "available",
                    "offlineVoices" to offlineVoices
                )
            )
        } catch (e: Exception) {
            finishProbe(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "voice_inspection_failed"
                )
            )
        }
    }

    private fun finishProbe(resultData: Map<String, Any>) {
        if (isProbing.compareAndSet(true, false)) {
            val res = pendingResult
            pendingResult = null

            Handler(Looper.getMainLooper()).post {
                res?.success(resultData)
            }

            shutDownTts()
        }
    }

    private fun shutDownTts() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (e: Exception) {
            // Ignore shutdown errors
        } finally {
            tts = null
        }
    }

    fun destroy() {
        if (isProbing.compareAndSet(true, false)) {
            val res = pendingResult
            pendingResult = null
            res?.success(
                mapOf(
                    "version" to 1,
                    "status" to "unavailable",
                    "reason" to "activity_destroyed"
                )
            )
        }
        shutDownTts()
    }
}
