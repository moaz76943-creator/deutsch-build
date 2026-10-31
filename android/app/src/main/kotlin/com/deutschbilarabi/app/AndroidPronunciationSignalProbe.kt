package com.deutschbilarabi.app

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs
import kotlin.math.sqrt

class AndroidPronunciationSignalProbe(
    private val activity: MainActivity,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME =
            "com.deutschbilarabi.app/pronunciation_signal"
        private const val REQUEST_CODE = 4814
        private const val SAMPLE_RATE = 16000
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    @Volatile
    private var captureInProgress = false

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "requestPermission" -> requestPermission(result)
            "capture" -> capture(call, result)
            else -> result.notImplemented()
        }
    }

    private fun requestPermission(result: MethodChannel.Result) {
        if (hasPermission()) {
            result.success(true)
            return
        }
        if (pendingPermissionResult != null) {
            result.success(false)
            return
        }
        pendingPermissionResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.RECORD_AUDIO),
            REQUEST_CODE,
        )
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val pending = pendingPermissionResult
        pendingPermissionResult = null
        pending?.success(
            grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED,
        )
        return true
    }

    private fun capture(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (!hasPermission()) {
            result.success(
                unavailable("microphone_permission_required"),
            )
            return
        }
        if (captureInProgress) {
            result.success(unavailable("pronunciation_capture_busy"))
            return
        }

        val requested =
            call.argument<Int>("maxDurationMs") ?: 1600
        val durationMs = requested.coerceIn(500, 2500)
        captureInProgress = true

        Thread {
            val payload = captureFeatures(durationMs)
            activity.runOnUiThread {
                captureInProgress = false
                result.success(payload)
            }
        }.start()
    }

    private fun captureFeatures(durationMs: Int): Map<String, Any?> {
        val minBuffer = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
        )
        if (minBuffer <= 0) {
            return unavailable("audio_record_buffer_unavailable")
        }

        val bufferSize = maxOf(minBuffer, 2048)
        val recorder = try {
            AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize,
            )
        } catch (_: SecurityException) {
            return unavailable("microphone_permission_required")
        } catch (_: Throwable) {
            return unavailable("audio_record_initialization_failed")
        }

        if (recorder.state != AudioRecord.STATE_INITIALIZED) {
            recorder.release()
            return unavailable("audio_record_initialization_failed")
        }

        val targetSamples = SAMPLE_RATE * durationMs / 1000
        val buffer = ShortArray(bufferSize / 2)
        var total = 0
        var voiced = 0
        var zeroCrossings = 0
        var previous = 0
        var peak = 0
        var sumSquares = 0.0

        return try {
            recorder.startRecording()
            while (total < targetSamples) {
                val wanted = minOf(buffer.size, targetSamples - total)
                val read = recorder.read(
                    buffer,
                    0,
                    wanted,
                    AudioRecord.READ_BLOCKING,
                )
                if (read <= 0) break

                for (index in 0 until read) {
                    val sample = buffer[index].toInt()
                    val magnitude = abs(sample)
                    if (magnitude > peak) peak = magnitude
                    sumSquares += sample.toDouble() * sample.toDouble()
                    if (magnitude >= 500) voiced++
                    if (
                        index > 0 &&
                        magnitude >= 250 &&
                        abs(previous) >= 250 &&
                        ((sample >= 0) != (previous >= 0))
                    ) {
                        zeroCrossings++
                    }
                    previous = sample
                }
                total += read
            }

            if (recorder.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                recorder.stop()
            }

            if (total < SAMPLE_RATE / 10) {
                unavailable("pronunciation_capture_too_short")
            } else {
                val rms = sqrt(sumSquares / total) / 32768.0
                mapOf(
                    "available" to true,
                    "captureDurationMs" to (total * 1000 / SAMPLE_RATE),
                    "voicedDurationMs" to (voiced * 1000 / SAMPLE_RATE),
                    "rms" to rms.coerceIn(0.0, 1.0),
                    "peak" to (peak / 32768.0).coerceIn(0.0, 1.0),
                    "zeroCrossingRate" to (
                        zeroCrossings.toDouble() /
                            maxOf(1, total - 1)
                    ).coerceIn(0.0, 1.0),
                )
            }
        } catch (_: SecurityException) {
            unavailable("microphone_permission_required")
        } catch (_: Throwable) {
            unavailable("pronunciation_capture_failed")
        } finally {
            try {
                if (
                    recorder.recordingState ==
                        AudioRecord.RECORDSTATE_RECORDING
                ) {
                    recorder.stop()
                }
            } catch (_: Throwable) {
            }
            recorder.release()
        }
    }

    private fun hasPermission(): Boolean =
        activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED

    private fun unavailable(reason: String): Map<String, Any?> =
        mapOf(
            "available" to false,
            "reason" to reason,
        )
}
