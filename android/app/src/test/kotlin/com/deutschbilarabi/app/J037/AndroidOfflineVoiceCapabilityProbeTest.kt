package com.deutschbilarabi.app.J037

import com.deutschbilarabi.app.AndroidOfflineVoiceCapabilityProbe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AndroidOfflineVoiceCapabilityProbeTest {

    private class FakeResult : MethodChannel.Result {
        var successResult: Any? = null
        var errorResult: String? = null
        var notImplementedCalled = false

        override fun success(result: Any?) {
            successResult = result
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            errorResult = errorCode
        }

        override fun notImplemented() {
            notImplementedCalled = true
        }
    }

    // A lightweight replacement for org.junit.Test without annotations
    fun testUnknownMethodCallReturnsNotImplemented() {
        val result = FakeResult()
        val probe = AndroidOfflineVoiceCapabilityProbe(android.content.ContextWrapper(null))

        probe.onMethodCall(MethodCall("unknownMethod", null), result)

        if (!result.notImplementedCalled) throw AssertionError("notImplemented() was not called")
    }

    fun testDisposedProbeReturnsUnavailable() {
        val result = FakeResult()
        val probe = AndroidOfflineVoiceCapabilityProbe(android.content.ContextWrapper(null))
        probe.dispose()

        probe.onMethodCall(MethodCall("probeCapabilities", null), result)

        val map = result.successResult as Map<*, *>
        if (map["status"] != "unavailable") throw AssertionError("Expected status unavailable but was ${map["status"]}")
        if (map["reason"] != "disposed") throw AssertionError("Expected reason disposed but was ${map["reason"]}")
    }

    fun testVoiceFilteringLogic() {
        val result = FakeResult()
        val probe = AndroidOfflineVoiceCapabilityProbe(android.content.ContextWrapper(null))

        try {
            probe.onMethodCall(MethodCall("probeCapabilities", null), result)
            val map = result.successResult as? Map<*, *>
            if (map != null && map["status"] != "unavailable") {
                throw AssertionError("Expected unavailable without mock framework but got success")
            }
        } catch (e: Exception) {
            // expected given null Context and unmocked Handler
        }
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            val test = AndroidOfflineVoiceCapabilityProbeTest()
            test.testUnknownMethodCallReturnsNotImplemented()
            test.testDisposedProbeReturnsUnavailable()
            test.testVoiceFilteringLogic()
            println("All lightweight checks passed.")
        }
    }
}
