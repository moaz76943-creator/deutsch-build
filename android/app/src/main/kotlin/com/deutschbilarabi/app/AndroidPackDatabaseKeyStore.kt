package com.deutschbilarabi.app

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
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
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class AndroidPackDatabaseKeyStore(private val context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/pack_database_key_store"
        private const val KEY_ALIAS = "deutsch_pack_database_wrap_key_v1"
        private const val FILE_NAME = ".pack_database_key_v1"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val FORMAT_VERSION: Byte = 1
        private const val KEY_BYTES = 32
        private const val NONCE_BYTES = 12
        private const val GCM_TAG_BITS = 128
        private const val VERSION_BYTES = 1
        private const val MAX_PAYLOAD_BYTES =
            VERSION_BYTES + NONCE_BYTES + KEY_BYTES + (GCM_TAG_BITS / 8)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getOrCreate" -> getOrCreate(result)
            "read" -> read(result)
            else -> result.notImplemented()
        }
    }

    private fun getOrCreate(result: MethodChannel.Result) {
        try {
            val existing = readKeyBytes()
            if (existing != null) {
                successKey(result, existing)
                return
            }

            val generated = ByteArray(KEY_BYTES)
            SecureRandom().nextBytes(generated)
            writeWrappedKey(generated)
            successKey(result, generated)
        } catch (_: GeneralSecurityException) {
            result.error("unavailable", null, null)
        } catch (_: IOException) {
            result.error("unreadable", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("corrupted", null, null)
        }
    }

    private fun read(result: MethodChannel.Result) {
        try {
            val existing = readKeyBytes()
            if (existing == null) {
                result.success(null)
            } else {
                successKey(result, existing)
            }
        } catch (_: GeneralSecurityException) {
            result.error("corrupted", null, null)
        } catch (_: IOException) {
            result.error("unreadable", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("corrupted", null, null)
        }
    }

    private fun successKey(result: MethodChannel.Result, key: ByteArray) {
        try {
            result.success(Base64.encodeToString(key, Base64.NO_WRAP))
        } finally {
            key.fill(0)
        }
    }

    private fun readKeyBytes(): ByteArray? {
        val file = keyFile()
        if (!file.exists()) return null
        if (file.length() <= VERSION_BYTES + NONCE_BYTES ||
            file.length() > MAX_PAYLOAD_BYTES
        ) {
            throw GeneralSecurityException("Pack key payload is invalid.")
        }

        val payload = file.readBytes()
        if (payload[0] != FORMAT_VERSION) {
            throw GeneralSecurityException("Pack key payload version is invalid.")
        }
        val nonceStart = VERSION_BYTES
        val nonceEnd = nonceStart + NONCE_BYTES
        val nonce = payload.copyOfRange(nonceStart, nonceEnd)
        val ciphertext = payload.copyOfRange(nonceEnd, payload.size)
        val plaintext = decrypt(nonce, ciphertext)
        if (plaintext.size != KEY_BYTES) {
            plaintext.fill(0)
            throw GeneralSecurityException("Pack database key has invalid length.")
        }
        return plaintext
    }

    private fun writeWrappedKey(key: ByteArray) {
        val encrypted = encrypt(key)
        val target = keyFile()
        val temporary = File(context.filesDir, "$FILE_NAME.tmp")
        temporary.outputStream().use { it.write(encrypted) }
        try {
            Files.move(
                temporary.toPath(),
                target.toPath(),
                ATOMIC_MOVE,
                REPLACE_EXISTING,
            )
        } catch (_: AtomicMoveNotSupportedException) {
            temporary.delete()
            throw IOException("Atomic pack-key persistence is unavailable.")
        }
    }

    private fun encrypt(plaintext: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateWrappingKey())
        val ciphertext = cipher.doFinal(plaintext)
        return ByteBuffer.allocate(VERSION_BYTES + NONCE_BYTES + ciphertext.size)
            .put(FORMAT_VERSION)
            .put(cipher.iv)
            .put(ciphertext)
            .array()
    }

    private fun decrypt(nonce: ByteArray, ciphertext: ByteArray): ByteArray {
        val wrappingKey = getExistingWrappingKey()
            ?: throw GeneralSecurityException("Keystore wrapping key is unavailable.")
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            wrappingKey,
            GCMParameterSpec(GCM_TAG_BITS, nonce),
        )
        return cipher.doFinal(ciphertext)
    }

    private fun getExistingWrappingKey(): SecretKey? {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as? SecretKey
    }

    private fun getOrCreateWrappingKey(): SecretKey {
        val existing = getExistingWrappingKey()
        if (existing != null) return existing

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
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return generator.generateKey()
    }

    private fun keyFile(): File = File(context.filesDir, FILE_NAME)
}
