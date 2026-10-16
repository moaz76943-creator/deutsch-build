package com.deutschbilarabi.app

import android.content.Intent
import android.speech.tts.TextToSpeech
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val PROCESS_TEXT_CHANNEL = "com.deutsch_bilarabi.app/process_text"
        const val MAX_PENDING_PROCESS_TEXT = 8
    }

    private lateinit var pronunciationSignalProbe: AndroidPronunciationSignalProbe
    private var offlineVoiceCapabilityProbe: AndroidOfflineVoiceCapabilityProbe? = null
    private var offlineVoiceCapabilityChannel: MethodChannel? = null
    private var processTextChannel: MethodChannel? = null
    private var processTextListenerReady = false
    private var processTextInFlight = false
    private val pendingProcessText = ArrayDeque<String>()

    private fun captureProcessText(source: Intent?) {
        if (source?.action != Intent.ACTION_PROCESS_TEXT) return
        val selected = try {
            source.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()?.trim()
        } catch (_: RuntimeException) {
            null
        }
        if (selected.isNullOrEmpty()) return

        // A malicious sender cannot accumulate unbounded text selections.
        if (pendingProcessText.size >= MAX_PENDING_PROCESS_TEXT) {
            pendingProcessText.removeFirst()
        }
        pendingProcessText.addLast(selected)
        dispatchPendingProcessText()
    }

    private fun dispatchPendingProcessText() {
        val channel = processTextChannel ?: return
        if (!processTextListenerReady || processTextInFlight ||
            pendingProcessText.isEmpty()) return

        processTextInFlight = true
        val selected = pendingProcessText.first()
        channel.invokeMethod("processText", selected, object : MethodChannel.Result {
            override fun success(result: Any?) {
                pendingProcessText.removeFirst()
                processTextInFlight = false
                dispatchPendingProcessText()
            }

            override fun error(
                errorCode: String,
                errorMessage: String?,
                errorDetails: Any?,
            ) {
                // Retain the selection; a new Dart "ready" handshake retries it.
                processTextInFlight = false
                processTextListenerReady = false
            }

            override fun notImplemented() {
                processTextInFlight = false
                processTextListenerReady = false
            }
        })
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        processTextListenerReady = false
        processTextChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PROCESS_TEXT_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "ready" -> {
                        // Dart sends this only after setMethodCallHandler().
                        processTextListenerReady = true
                        result.success(null)
                        dispatchPendingProcessText()
                    }
                    "notReady" -> {
                        processTextListenerReady = false
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidUserVaultCipher.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidUserVaultCipher(this))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidSecureSessionStorage.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidSecureSessionStorage(this))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidPackDatabaseKeyStore.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidPackDatabaseKeyStore(this))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidRecordedAudioPlayer.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidRecordedAudioPlayer(this))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidGamificationClockIntegritySource.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidGamificationClockIntegritySource(this))
        pronunciationSignalProbe = AndroidPronunciationSignalProbe(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidPronunciationSignalProbe.CHANNEL_NAME,
        ).setMethodCallHandler(pronunciationSignalProbe)
        offlineVoiceCapabilityChannel?.setMethodCallHandler(null)
        offlineVoiceCapabilityProbe?.dispose()
        offlineVoiceCapabilityProbe = AndroidOfflineVoiceCapabilityProbe(this)
        offlineVoiceCapabilityChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME,
        ).also { it.setMethodCallHandler(offlineVoiceCapabilityProbe) }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.deutsch_bilarabi.app/tts_settings",
        ).setMethodCallHandler { call, result ->
            if (call.method == "openTtsInstall") {
                try {
                    val intent = Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    try {
                        val fallbackIntent = Intent("com.android.settings.TTS_SETTINGS")
                        fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(fallbackIntent)
                        result.success(true)
                    } catch (ex: Exception) {
                        result.error("UNAVAILABLE", "Cannot open TTS settings", null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (
            ::pronunciationSignalProbe.isInitialized &&
            pronunciationSignalProbe.onRequestPermissionsResult(
                requestCode,
                grantResults,
            )
        ) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent the OS/app-switcher from exposing learning data in screenshots.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        captureProcessText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureProcessText(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        processTextListenerReady = false
        processTextChannel?.setMethodCallHandler(null)
        processTextChannel = null
        offlineVoiceCapabilityChannel?.setMethodCallHandler(null)
        offlineVoiceCapabilityChannel = null
        offlineVoiceCapabilityProbe?.dispose()
        offlineVoiceCapabilityProbe = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
