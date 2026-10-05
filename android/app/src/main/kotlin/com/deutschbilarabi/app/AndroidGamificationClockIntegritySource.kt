package com.deutschbilarabi.app

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AndroidGamificationClockIntegritySource(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME =
            "com.deutschbilarabi.app/gamification_clock_integrity"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (call.method != "readStamp") {
            result.notImplemented()
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            result.success(null)
            return
        }

        val bootCount = Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.BOOT_COUNT,
            -1,
        )
        if (bootCount < 0) {
            result.success(null)
            return
        }

        result.success(
            mapOf(
                "elapsedRealtimeMilliseconds" to SystemClock.elapsedRealtime(),
                "bootCount" to bootCount,
            ),
        )
    }
}
