package com.deutschbilarabi.app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var pronunciationSignalProbe: AndroidPronunciationSignalProbe
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    private lateinit var offlineVoiceProbe: AndroidOfflineVoiceCapabilityProbe
=======
    private lateinit var offlineVoiceCapabilityProbe: AndroidOfflineVoiceCapabilityProbe
>>>>>>> pr-151
=======
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

>>>>>>> pr-179
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
<<<<<<< HEAD
<<<<<<< HEAD

<<<<<<< HEAD
        offlineVoiceProbe = AndroidOfflineVoiceCapabilityProbe(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME,
        ).setMethodCallHandler(offlineVoiceProbe)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::offlineVoiceProbe.isInitialized) {
            offlineVoiceProbe.destroy()
        }
=======
        offlineVoiceCapabilityProbe = AndroidOfflineVoiceCapabilityProbe(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME,
        ).setMethodCallHandler(offlineVoiceCapabilityProbe)
    }

    override fun onDestroy() {
        if (::offlineVoiceCapabilityProbe.isInitialized) {
            offlineVoiceCapabilityProbe.dispose()
        }
        super.onDestroy()
>>>>>>> pr-151
=======
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
>>>>>>> pr-179
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
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
<<<<<<< HEAD
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
        super.cleanUpFlutterEngine(flutterEngine)
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    }
}
