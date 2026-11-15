package com.deutschbilarabi.app

import android.content.Intent
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var pronunciationSignalProbe: AndroidPronunciationSignalProbe
    private lateinit var offlineVoiceProbe: AndroidOfflineVoiceCapabilityProbe

    private var processTextChannel: MethodChannel? = null
    private var processTextListenerReady = false
    private var processTextInFlight = false
    private val pendingProcessText = ArrayDeque<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, AndroidSecureSessionStorage.CHANNEL_NAME)
            .setMethodCallHandler(AndroidSecureSessionStorage(this))
        MethodChannel(messenger, AndroidPackDatabaseKeyStore.CHANNEL_NAME)
            .setMethodCallHandler(AndroidPackDatabaseKeyStore(this))
        MethodChannel(messenger, AndroidUserVaultCipher.CHANNEL_NAME)
            .setMethodCallHandler(AndroidUserVaultCipher(this))
        MethodChannel(messenger, AndroidRecordedAudioPlayer.CHANNEL_NAME)
            .setMethodCallHandler(AndroidRecordedAudioPlayer(this))
        MethodChannel(messenger, AndroidGamificationClockIntegritySource.CHANNEL_NAME)
            .setMethodCallHandler(AndroidGamificationClockIntegritySource(this))

        pronunciationSignalProbe = AndroidPronunciationSignalProbe(this)
        MethodChannel(messenger, AndroidPronunciationSignalProbe.CHANNEL_NAME)
            .setMethodCallHandler(pronunciationSignalProbe)

        offlineVoiceProbe = AndroidOfflineVoiceCapabilityProbe(this)
        MethodChannel(messenger, AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME)
            .setMethodCallHandler(offlineVoiceProbe)

        processTextChannel = MethodChannel(messenger, PROCESS_TEXT_CHANNEL)
        processTextChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "ready" -> {
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

        MethodChannel(messenger, TTS_SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openTtsInstall") {
                openTtsInstaller(result)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Early integrity check: exit immediately if rooted, debugged, or emulated (release only).
        if (!BuildConfig.DEBUG && SecurityGuard.isCompromised(this)) {
            finishAffinity()
            return
        }

        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
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

    override fun onDestroy() {
        if (::offlineVoiceProbe.isInitialized) {
            offlineVoiceProbe.destroy()
        }
        super.onDestroy()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        processTextListenerReady = false
        processTextInFlight = false
        processTextChannel?.setMethodCallHandler(null)
        processTextChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
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

    private fun captureProcessText(source: Intent?) {
        if (source?.action != Intent.ACTION_PROCESS_TEXT) return
        val selected = try {
            source.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()?.trim()
        } catch (_: RuntimeException) {
            null
        }
        if (selected.isNullOrEmpty()) return
        if (pendingProcessText.size >= MAX_PENDING_PROCESS_TEXT) {
            pendingProcessText.removeFirst()
        }
        pendingProcessText.addLast(selected)
        dispatchPendingProcessText()
    }

    private fun dispatchPendingProcessText() {
        val channel = processTextChannel ?: return
        if (!processTextListenerReady || processTextInFlight || pendingProcessText.isEmpty()) {
            return
        }
        processTextInFlight = true
        val selected = pendingProcessText.first()
        channel.invokeMethod(
            "processText",
            selected,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    if (pendingProcessText.isNotEmpty()) {
                        pendingProcessText.removeFirst()
                    }
                    processTextInFlight = false
                    dispatchPendingProcessText()
                }

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?,
                ) {
                    processTextInFlight = false
                    processTextListenerReady = false
                }

                override fun notImplemented() {
                    processTextInFlight = false
                    processTextListenerReady = false
                }
            },
        )
    }

    private fun openTtsInstaller(result: MethodChannel.Result) {
        try {
            val intent = Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            result.success(true)
        } catch (_: Exception) {
            try {
                val fallbackIntent = Intent(TTS_SETTINGS_ACTION)
                fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(fallbackIntent)
                result.success(true)
            } catch (_: Exception) {
                result.error("UNAVAILABLE", "Cannot open TTS settings", null)
            }
        }
    }

    companion object {
        private const val PROCESS_TEXT_CHANNEL = "com.deutsch_bilarabi.app/process_text"
        private const val TTS_SETTINGS_CHANNEL = "com.deutsch_bilarabi.app/tts_settings"
        private const val TTS_SETTINGS_ACTION = "com.android.settings.TTS_SETTINGS"
        private const val MAX_PENDING_PROCESS_TEXT = 10
    }
}
