package com.deutschbilarabi.app

import android.content.Context
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Play Integrity API wrapper for strong device and app attestation.
 *
 * Call requestToken() before unlocking sensitive offline packs, premium features,
 * or any backend-protected content. Send the token to your backend for verification
 * against Google's API. Never trust the token client-side only.
 *
 * Requires dependency:
 * implementation 'com.google.android.play:integrity:1.4.0'
 *
 * Cloud Project Number is read from BuildConfig (set via CLOUD_PROJECT_NUMBER
 * Gradle property, local.properties, or CI environment for production builds).
 */
class AndroidPlayIntegrityManager(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/play_integrity"
    }

    private val integrityManager by lazy {
        IntegrityManagerFactory.create(context.applicationContext)
    }

    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestIntegrityToken" -> requestIntegrityToken(call, result)
            else -> result.notImplemented()
        }
    }

    private fun requestIntegrityToken(call: MethodCall, result: MethodChannel.Result) {
        val projectNumber = BuildConfig.CLOUD_PROJECT_NUMBER
        if (projectNumber == 0L) {
            result.error("not_configured", "Cloud project number not set. Configure CLOUD_PROJECT_NUMBER for production integrity checks.", null)
            return
        }

        val nonce = call.argument<String>("nonce") ?: generateNonce()

        scope.launch {
            try {
                val token = withContext(Dispatchers.IO) {
                    val request = IntegrityTokenRequest.builder()
                        .setCloudProjectNumber(projectNumber)
                        .setNonce(nonce)
                        .build()

                    Tasks.await(integrityManager.requestIntegrityToken(request)).token()
                }
                result.success(token)
            } catch (e: Exception) {
                if (e is InterruptedException) {
                    Thread.currentThread().interrupt()
                }
                result.error("integrity_failed", e.message, null)
            }
        }
    }

    private fun generateNonce(): String {
        val bytes = ByteArray(16)
        java.security.SecureRandom().nextBytes(bytes)
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
