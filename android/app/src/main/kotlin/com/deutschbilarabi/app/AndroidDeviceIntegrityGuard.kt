package com.deutschbilarabi.app

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import java.io.File

/**
 * Lightweight, offline device-integrity probe.
 * Detects common root indicators and active debuggers.
 * Designed for rapid integration; false positives are possible on exotic devices
 * but the check is intentionally conservative and non-blocking.
 */
class AndroidDeviceIntegrityGuard(private val context: Context) {

    fun isCompromised(): Boolean {
        return isDebuggerAttached() || isRooted()
    }

    private fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected() || Debug.waitingForDebugger()
    }

    private fun isRooted(): Boolean {
        return hasTestKeys() || hasSuBinary() || hasRootManagementApps()
    }

    private fun hasTestKeys(): Boolean {
        val tags = Build.TAGS
        return tags != null && tags.contains("test-keys")
    }

    private fun hasSuBinary(): Boolean {
        val paths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/system/bin/.ext/.su",
            "/system/usr/we-need-root/su-backup",
            "/system/xbin/mu",
            "/data/local/su",
            "/data/local/bin/su",
            "/data/local/xbin/su"
        )
        return paths.any { File(it).exists() }
    }

    private fun hasRootManagementApps(): Boolean {
        val packages = arrayOf(
            "com.topjohnwu.magisk",
            "eu.chainfire.supersu",
            "com.noshufou.android.su",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su"
        )
        val pm = context.packageManager
        return packages.any { pkg ->
            try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }
    }
}
