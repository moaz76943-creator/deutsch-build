package com.deutschbilarabi.app

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.file.AtomicMoveNotSupportedException
import java.nio.file.Files
import java.nio.file.StandardCopyOption.ATOMIC_MOVE
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.security.GeneralSecurityException
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Android platform boundary for the opaque authenticated-session credential.
 *
 * The encryption key is generated and retained by Android Keystore. The
 * encrypted payload is stored only in the app-private files directory.
 * Credential values and cryptographic material are never logged.
 */
class AndroidSecureSessionStorage(private val context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/secure_session_storage"
        private const val KEY_ALIAS = "deutsch_session_storage_key_v1"
        private const val FILE_NAME = ".secure_session_credential"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_BITS = 128
        private const val FORMAT_VERSION: Byte = 1
        private const val VERSION_BYTES = 1
        private const val NONCE_BYTES = 12
        private const val MAX_CREDENTIAL_BYTES = 16 * 1024
        private const val MAX_STORED_PAYLOAD_BYTES =
            VERSION_BYTES + MAX_CREDENTIAL_BYTES + NONCE_BYTES + (GCM_TAG_BITS / 8)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "save" -> save(call, result)
            "read" -> read(result)
            "clear" -> clear(result)
            else -> result.notImplemented()
        }
    }

    private fun save(call: MethodCall, result: MethodChannel.Result) {
        val value = call.argument<String>("value")
        if (value.isNullOrEmpty()) {
            result.error("unreadable", null, null)
            return
        }
        val valueBytes = value.toByteArray(Charsets.UTF_8)
        if (valueBytes.size > MAX_CREDENTIAL_BYTES) {
            result.error("unreadable", null, null)
            return
        }
        try {
            val encrypted = encrypt(valueBytes)
            val target = credentialFile()
            val temporary = File(context.filesDir, "$FILE_NAME.tmp")
            temporary.outputStream().use { it.write(encrypted) }
            try {
                Files.move(temporary.toPath(), target.toPath(), ATOMIC_MOVE, REPLACE_EXISTING)
            } catch (_: AtomicMoveNotSupportedException) {
                temporary.delete()
                result.error("unavailable", null, null)
                return
            }
            result.success(null)
        } catch (_: GeneralSecurityException) {
            result.error("unavailable", null, null)
        } catch (_: IOException) {
            result.error("unreadable", null, null)
        }
    }

    private fun read(result: MethodChannel.Result) {
        val file = credentialFile()
        if (!file.exists()) {
            result.success(null)
            return
        }
        try {
            if (file.length() > MAX_STORED_PAYLOAD_BYTES) {
                result.error("corrupted", null, null)
                return
            }
            val payload = file.readBytes()
            if (payload.size <= VERSION_BYTES + NONCE_BYTES) {
                result.error("corrupted", null, null)
                return
            }
            val version = payload[0]
            if (version != FORMAT_VERSION) {
                result.error("corrupted", null, null)
                return
            }
            val nonceStart = VERSION_BYTES
            val nonceEnd = nonceStart + NONCE_BYTES
            val nonce = payload.copyOfRange(nonceStart, nonceEnd)
            val ciphertext = payload.copyOfRange(nonceEnd, payload.size)
            val plaintext = decrypt(nonce, ciphertext)
            val value = plaintext.toString(Charsets.UTF_8)
            if (value.isEmpty()) {
                result.error("corrupted", null, null)
                return
            }
            result.success(value)
        } catch (_: GeneralSecurityException) {
            result.error("corrupted", null, null)
        } catch (_: IOException) {
            result.error("unreadable", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("corrupted", null, null)
        }
    }

    private fun clear(result: MethodChannel.Result) {
        try {
            val file = credentialFile()
            if (file.exists() && !file.delete()) {
                result.error("unreadable", null, null)
                return
            }
            val temporary = File(context.filesDir, "$FILE_NAME.tmp")
            if (temporary.exists() && !temporary.delete()) {
                result.error("unreadable", null, null)
                return
            }
            result.success(null)
        } catch (_: SecurityException) {
            result.error("unreadable", null, null)
        }
    }

    private fun encrypt(plaintext: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey())
        val ciphertext = cipher.doFinal(plaintext)
        return ByteBuffer.allocate(VERSION_BYTES + NONCE_BYTES + ciphertext.size)
            .put(FORMAT_VERSION)
            .put(cipher.iv)
            .put(ciphertext)
            .array()
    }

    private fun decrypt(nonce: ByteArray, ciphertext: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            getExistingKey() ?: throw GeneralSecurityException("Session encryption key is unavailable."),
            GCMParameterSpec(GCM_TAG_BITS, nonce),
        )
        return cipher.doFinal(ciphertext)
    }

    private fun getExistingKey(): SecretKey? {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as? SecretKey
    }

    private fun getOrCreateKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        val existing = keyStore.getKey(KEY_ALIAS, null)
        if (existing is SecretKey) {
            return existing
        }

        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore",
        )
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return generator.generateKey()
    }

    private fun credentialFile(): File = File(context.filesDir, FILE_NAME)
}
