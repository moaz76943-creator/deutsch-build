package com.deutschbilarabi.app

import android.content.Context
import android.os.Debug
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class AndroidRootDetector(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/root_detector"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isRootedOrCompromised" -> result.success(isRootedOrCompromised())
            "isDebuggerAttached" -> result.success(isDebuggerAttached())
            else -> result.notImplemented()
        }
    }

    private fun isRootedOrCompromised(): Boolean {
        return checkRootFiles() || checkRootPackages() || checkSuBinary() || isDebuggerAttached()
    }

    private fun checkRootFiles(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su", "/system/bin/su", "/system/xbin/su",
            "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
            "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su",
            "/magisk", "/system/xbin/magisk", "/sbin/.magisk"
        )
        return paths.any { File(it).exists() }
    }

    private fun checkSuBinary(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("which", "su"))
            process.waitFor() == 0
        } catch (e: Exception) {
            false
        }
    }

    private fun checkRootPackages(): Boolean {
        val packages = arrayOf(
            "com.noshufou.android.su", "com.thirdparty.superuser",
            "eu.chainfire.supersu", "com.koushikdutta.superuser",
            "com.topjohnwu.magisk", "com.kingroot.kinguser",
            "com.kingo.root", "com.smedialink.oneclickroot",
            "com.zhiqupk.root.global", "com.alephzain.framaroot"
        )
        val pm = context.packageManager
        return packages.any {
            try {
                pm.getPackageInfo(it, 0)
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    private fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected() ||
                (context.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }
}
