package com.deutschbilarabi.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Query-only Android TTS probe. Never synthesizes audio, installs voices or records speech. */
class AndroidOfflineVoiceCapabilityProbe(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutsch_bilarabi.app/offline_voice_capability"
        private const val TIMEOUT_MS = 3000L
    }

    private class Pending(val reply: MethodChannel.Result) {
        var engine: TextToSpeech? = null
        var timeout: Runnable? = null
    }

    private val main = Handler(Looper.getMainLooper())
    private var pending: Pending? = null
    private var disposed = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "probeCapabilities") {
            result.notImplemented()
            return
        }
        if (disposed) {
            result.success(unavailable("disposed"))
            return
        }
        if (pending != null) {
            result.success(unavailable("busy"))
            return
        }
        probe(result)
    }

    private fun probe(result: MethodChannel.Result) {
        val request = Pending(result)
        pending = request
        val timeout = Runnable { complete(request, unavailable("timeout")) }
        request.timeout = timeout
        main.postDelayed(timeout, TIMEOUT_MS)

        try {
            val engine = TextToSpeech(context) { status ->
                // Android may invoke its initialization callback off the UI thread.
                main.post {
                    if (pending !== request) return@post
                    if (status != TextToSpeech.SUCCESS) {
                        complete(request, unavailable("initialization_failed"))
                    } else {
                        queryLocalVoices(request)
                    }
                }
            }
            if (pending === request) {
                request.engine = engine
            } else {
                engine.shutdown()
            }
        } catch (_: SecurityException) {
            complete(request, unavailable("security_exception"))
        } catch (_: Exception) {
            complete(request, unavailable("initialization_failed"))
        }
    }

    private fun queryLocalVoices(request: Pending) {
        val engine = request.engine
            ?: return complete(request, unavailable("engine_unavailable"))
        // Binder-backed voice enumeration must not stall the Android UI thread.
        // At most one worker exists because concurrent probes fail closed as busy.
        try {
            Thread({
                val payload: Map<String, Any> = try {
                    val voices = engine.voices
                    if (voices == null) {
                        unavailable("voices_unavailable")
                    } else {
                        val locales = AndroidOfflineVoicePolicy.installedLocalCandidates(
                            voices.mapNotNull { voice ->
                                val tag = try {
                                    voice.locale.toLanguageTag()
                                } catch (_: Exception) {
                                    return@mapNotNull null
                                }
                                OfflineVoiceCandidate(
                                    localeTag = tag,
                                    networkRequired = voice.isNetworkConnectionRequired,
                                    networkSynthesisFeature = voice.features?.contains(
                                        TextToSpeech.Engine.KEY_FEATURE_NETWORK_SYNTHESIS,
                                    ) == true,
                                    notInstalledFeature = voice.features?.contains(
                                        TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED,
                                    ) == true,
                                )
                            },
                        )
                        if (locales.isEmpty()) {
                            unavailable("no_installed_local_voice")
                        } else {
                            // Metadata is not proof of successful actual synthesis.
                            mapOf(
                                "status" to "success",
                                "capability" to "installed_local_voice_candidates",
                                "locales" to locales,
                            )
                        }
                    }
                } catch (_: SecurityException) {
                    unavailable("security_exception")
                } catch (_: Exception) {
                    unavailable("voice_query_failed")
                }
                main.post { complete(request, payload) }
            }, "OfflineVoiceCapabilityQuery").start()
        } catch (_: Exception) {
            complete(request, unavailable("worker_unavailable"))
        }
    }

    private fun complete(request: Pending, payload: Map<String, Any>) {
        if (pending !== request) return // Stale callback or already timed out.
        pending = null
        request.timeout?.let(main::removeCallbacks)
        request.engine?.let { engine ->
            try { engine.shutdown() } catch (_: Exception) {}
        }
        request.engine = null
        request.reply.success(payload)
    }

    fun dispose() {
        disposed = true
        pending?.let { complete(it, unavailable("disposed")) }
    }

    private fun unavailable(reason: String): Map<String, Any> = mapOf(
        "status" to "unavailable",
        "reason" to reason,
        "locales" to emptyList<String>(),
    )
}
