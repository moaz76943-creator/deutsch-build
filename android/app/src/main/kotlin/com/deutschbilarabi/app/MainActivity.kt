package com.deutschbilarabi.app

import android.content.Intent
import android.speech.tts.TextToSpeech
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var pronunciationSignalProbe: AndroidPronunciationSignalProbe

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AndroidUserVaultCipher.CHANNEL_NAME,
        ).setMethodCallHandler(AndroidUserVaultCipher())
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
    }
}
