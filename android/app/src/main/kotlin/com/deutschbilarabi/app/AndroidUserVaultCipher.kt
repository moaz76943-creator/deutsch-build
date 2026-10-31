package com.deutschbilarabi.app

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.security.GeneralSecurityException
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec

/**
 * Version 1: non-exportable hardware Keystore AES-256-GCM.
 * Version 2: local software PBKDF2/AES-256-GCM when hardware backing is absent.
 * Software-derived keys are less tamper-resistant; both envelope versions bind
 * ciphertext to the record ID as authenticated additional data.
 * Existing V1 records are NEVER reinterpreted using a V2 software key.
 */
class AndroidUserVaultCipher(context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/user_vault_security"
        private const val ALIAS = "deutsch_user_vault_aes256_v1"
        private const val CIPHER_NAME = "AES/GCM/NoPadding"
        private const val MAX_BYTES = 4 * 1024 * 1024
        private const val NONCE_SIZE = 12
        private const val TAG_BITS = 128
        private const val HARDWARE_VERSION: Byte = 1
        private const val SOFTWARE_VERSION: Byte = 2
        private const val KDF_ITERATIONS = 210_000
    }

    private val preferences = context.applicationContext.getSharedPreferences(
        "deutsch_user_vault_software_v2", Context.MODE_PRIVATE)
    private val random = SecureRandom()
    @Volatile private var cachedSoftwareKey: SecretKey? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "encrypt" && call.method != "decrypt") {
            result.notImplemented()
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
            result.error("vault_key_unavailable_or_corrupt", null, null)
        } catch (_: IllegalArgumentException) {
            result.error("invalid_input", null, null)
        }
    }

    private fun seal(id: String, bytes: ByteArray): ByteArray {
        val hardware = getOrCreateHardwareKey()
        val key = hardware ?: softwareKey(create = true)
        val version = if (hardware == null) SOFTWARE_VERSION else HARDWARE_VERSION
        val cipher = Cipher.getInstance(CIPHER_NAME)
        cipher.init(Cipher.ENCRYPT_MODE, key)
        cipher.updateAAD(id.toByteArray(Charsets.UTF_8))
        val ciphertext = cipher.doFinal(bytes)
        return ByteBuffer.allocate(1 + NONCE_SIZE + ciphertext.size)
            .put(version)
            .put(cipher.iv)
            .put(ciphertext)
            .array()
    }

    private fun unseal(id: String, envelope: ByteArray): ByteArray {
        if (envelope.size < 1 + NONCE_SIZE + TAG_BITS / 8) {
            throw GeneralSecurityException("Invalid envelope")
        }
        val key = when (envelope[0]) {
            HARDWARE_VERSION -> existingKeyRaw()
                ?: throw GeneralSecurityException("Missing V1 Keystore key")
            SOFTWARE_VERSION -> softwareKey(create = false)
            else -> throw GeneralSecurityException("Unknown vault envelope")
        }
        val nonce = envelope.copyOfRange(1, 1 + NONCE_SIZE)
        val ciphertext = envelope.copyOfRange(1 + NONCE_SIZE, envelope.size)
        val cipher = Cipher.getInstance(CIPHER_NAME)
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, nonce))
        cipher.updateAAD(id.toByteArray(Charsets.UTF_8))
        return cipher.doFinal(ciphertext)
    }

    private fun existingKeyRaw(): SecretKey? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return null
        val store = KeyStore.getInstance("AndroidKeyStore")
        store.load(null)
        return store.getKey(ALIAS, null) as? SecretKey
    }

    private fun isHardwareBacked(key: SecretKey): Boolean = try {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            false
        } else {
            val info = SecretKeyFactory.getInstance("AES", "AndroidKeyStore")
                .getKeySpec(key, KeyInfo::class.java) as KeyInfo
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val level = info.securityLevel
                level == KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT ||
                    level == KeyProperties.SECURITY_LEVEL_STRONGBOX ||
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                        level == KeyProperties.SECURITY_LEVEL_UNKNOWN_SECURE)
            } else {
                @Suppress("DEPRECATION")
                info.isInsideSecureHardware
            }
        }
    } catch (_: GeneralSecurityException) {
        false
    }

    private fun getOrCreateHardwareKey(): SecretKey? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return null
        try {
            val existing = existingKeyRaw()
            if (existing != null) return existing.takeIf { isHardwareBacked(it) }
            val generator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
            generator.init(KeyGenParameterSpec.Builder(
                ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
                .build())
            return generator.generateKey().takeIf { isHardwareBacked(it) }
        } catch (_: GeneralSecurityException) {
            return null
        }
    }

    @Synchronized
    private fun persistedRandom(name: String, bytes: Int, create: Boolean): ByteArray {
        val encoded = preferences.getString(name, null)
        if (encoded != null) {
            val value = Base64.decode(encoded, Base64.NO_WRAP)
            if (value.size != bytes) throw GeneralSecurityException("Bad vault seed")
            return value
        }
        if (!create) throw GeneralSecurityException("Software vault seed missing")
        val generated = ByteArray(bytes)
        random.nextBytes(generated)
        if (!preferences.edit().putString(name,
                Base64.encodeToString(generated, Base64.NO_WRAP)).commit()) {
            throw GeneralSecurityException("Cannot durably save vault seed")
        }
        return generated
    }

    @Synchronized
    private fun softwareKey(create: Boolean): SecretKey {
        cachedSoftwareKey?.let { return it }
        val seed = persistedRandom("secret", 32, create)
        val salt = persistedRandom("salt", 16, create)
        val password = Base64.encodeToString(seed, Base64.NO_WRAP).toCharArray()
        val algorithm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            "PBKDF2WithHmacSHA256" else "PBKDF2WithHmacSHA1"
        val spec = PBEKeySpec(password, salt, KDF_ITERATIONS, 256)
        return try {
            val material = SecretKeyFactory.getInstance(algorithm)
                .generateSecret(spec).encoded
            SecretKeySpec(material, "AES").also {
                cachedSoftwareKey = it
                material.fill(0)
            }
        } finally {
            spec.clearPassword()
            password.fill('\u0000')
            seed.fill(0)
        }
    }
}
