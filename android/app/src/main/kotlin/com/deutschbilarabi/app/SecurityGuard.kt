package com.deutschbilarabi.app

import android.content.Context
import android.os.Build
import android.os.Debug
import java.io.File

/**
 * Lightweight runtime integrity checks suitable for Google Play offline apps.
 * Detects common root indicators and attached debuggers.
 * In release builds, suspicious environments cause the app to exit early.
 */
object SecurityGuard {
    fun isCompromised(context: Context): Boolean {
        return isDebuggerAttached() || isRooted(context) || isRunningOnEmulator()
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
            "/su/bin/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        // Check for Magisk or other common root apps via package (optional, may require query)
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
                || "google_sdk" == Build.PRODUCT)
    }
}
