package com.deutschbilarabi.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AndroidOfflineVoiceCapabilityProbe(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi/tts_settings"
        private const val INIT_TIMEOUT_MS = 5000L
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getCapabilities") {
            checkCapabilities(result)
        } else {
            result.notImplemented()
        }
    }

    private fun checkCapabilities(result: MethodChannel.Result) {
        var currentTts: TextToSpeech? = null
        var isCompleted = false

        val timeoutRunnable = Runnable {
            if (!isCompleted) {
                isCompleted = true
                currentTts?.shutdown()
                result.success(
                    mapOf(
                        "status" to "unavailable",
                        "reason" to "timeout",
                        "version" to 1
                    )
                )
            }
        }

        mainHandler.postDelayed(timeoutRunnable, INIT_TIMEOUT_MS)

        currentTts = TextToSpeech(context) { status ->
            mainHandler.removeCallbacks(timeoutRunnable)

            if (isCompleted) {
                currentTts?.shutdown()
                return@TextToSpeech
            }
            isCompleted = true

            if (status == TextToSpeech.SUCCESS) {
                try {
                    val voices = currentTts?.voices
                    if (voices != null) {
                        val availableOfflineLocales = voices
                            .filter { voice ->
                                !voice.isNetworkConnectionRequired &&
                                !voice.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
                            }
                            .map { it.locale.toLanguageTag() }
                            .distinct()

                        result.success(
                            mapOf(
                                "status" to "supported",
                                "voices" to availableOfflineLocales,
                                "version" to 1
                            )
                        )
                    } else {
                        result.success(
                            mapOf(
                                "status" to "unavailable",
                                "reason" to "no_voices",
                                "version" to 1
                            )
                        )
                    }
                } catch (e: Exception) {
                    result.success(
                        mapOf(
                            "status" to "unknown",
                            "reason" to e.message,
                            "version" to 1
                        )
                    )
                } finally {
                    currentTts?.shutdown()
                }
            } else {
                currentTts?.shutdown()
                result.success(
                    mapOf(
                        "status" to "unavailable",
                        "reason" to "init_failed",
                        "version" to 1
                    )
                )
            }
        }
    }

    fun dispose() {
        mainHandler.removeCallbacksAndMessages(null)
    }
}
