package com.deutschbilarabi.app

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import com.google.android.play.protections.annotations.PlayAutomaticIntegrityProtection
import java.io.File
import java.security.MessageDigest

/**
 * Lightweight runtime integrity checks suitable for Google Play offline apps.
 * Detects common root indicators, Magisk, attached debuggers, emulators, basic Frida, and Xposed.
 * Includes optional APK signature verification to detect repackaging/modding.
 * In release builds, suspicious environments cause the app to exit early.
 * Keep checks simple, fast, and non-network to preserve offline-first design.
 * Enhanced 2026-11-26: Added Xposed detection and more Frida indicators.
 * 2026-11-27: Annotated critical method for Play Automatic Integrity Protection.
 * 2026-11-28: Signature hash now injected via BuildConfig (set -PEXPECTED_SIGNATURE_SHA256 at build time).
 */
object SecurityGuard {
    // Expected SHA-256 of the release signing certificate (hex, lowercase).
    // Injected at build time from Gradle property EXPECTED_SIGNATURE_SHA256.
    // Obtain via: keytool -list -v -keystore your.keystore | grep SHA256
    // Empty value skips the signature check (safe for development).
    private val EXPECTED_SIGNATURE_SHA256 = BuildConfig.EXPECTED_SIGNATURE_SHA256

    @PlayAutomaticIntegrityProtection()
    fun isCompromised(context: Context): Boolean {
        return isDebuggerAttached() ||
                isRooted(context) ||
                isRunningOnEmulator() ||
                isFridaDetected() ||
                isXposedDetected(context) ||
                !isSignatureValid(context)
    }

    private fun isDebuggerAttached(): Boolean =
        Debug.isDebuggerConnected() || Debug.waitingForDebugger()

    private fun isRooted(context: Context): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/system/bin/.ext/.su",
            "/system/usr/we-need-root/su",
            "/cache/su",
            "/data/su",
            "/dev/su",
            // Magisk common paths
            "/sbin/.magisk",
            "/cache/.disable_magisk",
            "/data/adb/magisk",
            "/data/adb/modules"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }

        // Check for common root/Magisk packages
        val rootPackages = arrayOf(
            "com.topjohnwu.magisk",
            "eu.chainfire.supersu",
            "com.noshufou.android.su",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.kingroot.kinguser",
            "com.kingo.root",
            "com.smedialink.oneclickroot",
            "com.zhiqupk.root.global",
            "com.alephzain.framaroot"
        )
        val pm = context.packageManager
        for (pkg in rootPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                return true
            } catch (_: PackageManager.NameNotFoundException) {
                // Not installed
            }
        }
        return false
    }

    private fun isRunningOnEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk" == Build.PRODUCT
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu"))
    }

    private fun isFridaDetected(): Boolean {
        val fridaPaths = arrayOf(
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server",
            "/data/local/tmp/frida-agent"
        )
        for (path in fridaPaths) {
            if (File(path).exists()) return true
        }
        // Check for Frida library in process maps (lightweight)
        try {
            val maps = File("/proc/self/maps").readText()
            if (maps.contains("frida") || maps.contains("gum-js-loop")) return true
        } catch (_: Exception) {}
        return false
    }

    private fun isXposedDetected(context: Context): Boolean {
        // Common Xposed indicators
        try {
            Class.forName("de.robv.android.xposed.XposedBridge")
            return true
        } catch (_: ClassNotFoundException) {}
        val xposedPackages = arrayOf(
            "de.robv.android.xposed.installer",
            "org.meowcat.edxposed.manager",
            "org.lsposed.manager"
        )
        val pm = context.packageManager
        for (pkg in xposedPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                return true
            } catch (_: PackageManager.NameNotFoundException) {}
        }
        return false
    }

    private fun isSignatureValid(context: Context): Boolean {
        if (EXPECTED_SIGNATURE_SHA256.isEmpty()) return true // Skip if not configured
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
            }
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }
            signatures?.any { sig ->
                val md = MessageDigest.getInstance("SHA-256")
                val digest = md.digest(sig.toByteArray())
                digest.joinToString("") { "%02x".format(it) } == EXPECTED_SIGNATURE_SHA256
            } ?: false
        } catch (_: Exception) {
            false
        }
    }
}
