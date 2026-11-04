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
<<<<<<< HEAD

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Secure session and pack storage channels
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

        // Pronunciation signal probe
        pronunciationSignalProbe = AndroidPronunciationSignalProbe(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidPronunciationSignalProbe.CHANNEL_NAME,
        ).setMethodCallHandler(pronunciationSignalProbe)

        // Play Integrity API for app and device attestation (required for production integrity protection)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidPlayIntegrityManager.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidPlayIntegrityManager(this))

        // Root and debugger detection
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidRootDetector.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidRootDetector(this))
=======
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
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME,
        ).setMethodCallHandler(offlineVoiceProbe)

        // Process text channel for share/select text integration
        processTextChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.deutschbilarabi.app/process_text"
        )
        processTextChannel?.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                processTextListenerReady = true
                dispatchPendingProcessText()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // TTS settings opener
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

        // Play Integrity
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidPlayIntegrityManager.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidPlayIntegrityManager(this))
    }

    override fun onDestroy() {
        super.onDestroy()
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
>>>>>>> origin/staging/v2-full-platform
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

<<<<<<< HEAD
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent the OS/app-switcher from exposing learning data in screenshots (privacy/security).
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
=======
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureProcessText(intent)
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
>>>>>>> origin/staging/v2-full-platform
    }
}
