package com.deutschbilarabi.app

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.Voice
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

class AndroidOfflineVoiceCapabilityProbe(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/offline_voice_capability"
        private const val PROBE_TIMEOUT_MS = 5000L
        private const val PAYLOAD_VERSION = 1
    }

    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getOfflineVoiceCapabilities") {
            scope.launch {
                val response = performProbe()
                result.success(response)
            }
        } else {
            result.notImplemented()
        }
    }

    private suspend fun performProbe(): Map<String, Any> {
        val result = mutableMapOf<String, Any>(
            "version" to PAYLOAD_VERSION,
            "status" to "unknown"
        )

        var tts: TextToSpeech? = null
        try {
            val initResult = withTimeoutOrNull(PROBE_TIMEOUT_MS) {
                suspendCancellableCoroutine { cont ->
                    var tempTts: TextToSpeech? = null
                    try {
                        tempTts = TextToSpeech(context) { status ->
                            if (cont.isActive) {
                                cont.resume(Pair(tempTts, status))
                            } else {
                                tempTts?.shutdown()
                            }
                        }
                    } catch (e: Exception) {
                        tempTts?.shutdown()
                        if (cont.isActive) {
                            cont.resume(Pair(null, TextToSpeech.ERROR))
                        }
                    }
                    cont.invokeOnCancellation {
                        tempTts?.shutdown()
                    }
                }
            }

            if (initResult == null) {
                result["status"] = "timeout"
                return result
            }

            tts = initResult.first
            val status = initResult.second

            if (status != TextToSpeech.SUCCESS || tts == null) {
                result["status"] = "unavailable"
                return result
            }

            val voices = try {
                tts.voices
            } catch (e: Exception) {
                null
            }

            if (voices == null) {
                result["status"] = "missing_voices"
                return result
            }

            val offlineLocales = mutableListOf<String>()

            for (voice in voices) {
                val isNetworkRequired = voice.isNetworkConnectionRequired ||
                    voice.features.contains(TextToSpeech.Engine.KEY_FEATURE_NETWORK_SYNTHESIS) ||
                    voice.features.contains("networkTimeout")

                if (!isNetworkRequired) {
                    try {
                        val languageTag = voice.locale.toLanguageTag()
                        if (languageTag.isNotBlank() && languageTag != "und") {
                            offlineLocales.add(languageTag)
                        }
                    } catch (e: Exception) {
                        // ignore invalid locales
                    }
                }
            }

            result["status"] = "supported"
            result["offlineLocales"] = offlineLocales.distinct()

        } catch (e: Exception) {
            result["status"] = "error"
            result["error"] = e.message ?: "Unknown error"
        } finally {
            try {
                tts?.shutdown()
            } catch (e: Exception) {
                // ignore shutdown errors
            }
        }

        return result
    }
}
