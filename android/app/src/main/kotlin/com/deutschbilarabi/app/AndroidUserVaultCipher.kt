package com.deutschbilarabi.app

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.security.GeneralSecurityException
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec

/** Encrypts values with a non-exportable Android Keystore AES-256-GCM key.
 * If the device does not certify secure hardware storage, calls fail closed.
 */
class AndroidUserVaultCipher : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/user_vault_security"
        private const val ALIAS = "deutsch_user_vault_aes256_v1"
        private const val CIPHER_NAME = "AES/GCM/NoPadding"
        private const val MAX_BYTES = 4 * 1024 * 1024
        private const val NONCE_SIZE = 12
        private const val TAG_BITS = 128
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "encrypt" && call.method != "decrypt") {
            result.notImplemented()
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.error("hardware_unavailable", null, null)
            return
        }
        val id = call.argument<String>("recordId")
        val input = call.argument<ByteArray>("bytes")
        if (id == null || !Regex("^[a-zA-Z0-9_.:/-]{1,128}$").matches(id) ||
            input == null || input.size > MAX_BYTES + 29) {
            result.error("invalid_input", null, null)
            return
        }
        try {
            val output = if (call.method == "encrypt") {
                if (input.size > MAX_BYTES) {
                    result.error("invalid_input", null, null)
                    return
                }
                seal(id, input)
            } else {
                unseal(id, input)
            }
            result.success(output)
        } catch (_: GeneralSecurityException) {
            result.error("hardware_unavailable_or_corrupt", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("invalid_input", null, null)
        }
    }

    private fun seal(id: String, bytes: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(CIPHER_NAME)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey())
        cipher.updateAAD(id.toByteArray(Charsets.UTF_8))
        val ciphertext = cipher.doFinal(bytes)
        return ByteBuffer.allocate(1 + NONCE_SIZE + ciphertext.size)
            .put(1.toByte())
            .put(cipher.iv)
            .put(ciphertext)
            .array()
    }

    private fun unseal(id: String, envelope: ByteArray): ByteArray {
        if (envelope.size < 1 + NONCE_SIZE + TAG_BITS / 8 ||
            envelope[0] != 1.toByte()) {
            throw GeneralSecurityException("Invalid envelope")
        }
        val nonce = envelope.copyOfRange(1, 1 + NONCE_SIZE)
        val ciphertext = envelope.copyOfRange(1 + NONCE_SIZE, envelope.size)
        val cipher = Cipher.getInstance(CIPHER_NAME)
        val key = getExistingKey() ?: throw GeneralSecurityException("Missing vault key")
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, nonce))
        cipher.updateAAD(id.toByteArray(Charsets.UTF_8))
        return cipher.doFinal(ciphertext)
    }

    private fun existingKeyRaw(): SecretKey? {
        val store = KeyStore.getInstance("AndroidKeyStore")
        store.load(null)
        return store.getKey(ALIAS, null) as? SecretKey
    }

    private fun requireHardware(key: SecretKey): SecretKey {
        val info = SecretKeyFactory.getInstance("AES", "AndroidKeyStore")
            .getKeySpec(key, KeyInfo::class.java) as KeyInfo
        if (!info.isInsideSecureHardware) {
            throw GeneralSecurityException("No secure hardware backing")
        }
        return key
    }

    private fun getExistingKey(): SecretKey? =
        existingKeyRaw()?.let { requireHardware(it) }

    private fun getOrCreateKey(): SecretKey {
        val existing = getExistingKey()
        if (existing != null) return existing
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(KeyGenParameterSpec.Builder(
            ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setRandomizedEncryptionRequired(true)
            .build())
        return requireHardware(generator.generateKey())
    }
}
