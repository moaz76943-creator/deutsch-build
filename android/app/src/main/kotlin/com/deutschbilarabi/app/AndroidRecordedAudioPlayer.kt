package com.deutschbilarabi.app

import android.content.Context
import android.media.MediaPlayer
import android.media.MediaDataSource
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AndroidRecordedAudioPlayer(private val context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.deutschbilarabi.app/recorded_audio_player"
        private val ALLOWED_EXTENSIONS =
            setOf(".aac", ".flac", ".m4a", ".mp3", ".ogg", ".wav")
    }

    private var player: MediaPlayer? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playAsset" -> {
                val assetPath = call.argument<String>("assetPath")
                if (!isSafeAssetPath(assetPath)) {
                    result.success(false)
                    return
                }
                playAsset(assetPath!!, result)
            }
            "playOpusBytes" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (Build.VERSION.SDK_INT < 23 || bytes == null ||
                    bytes.size < 8 || bytes.size > 8 * 1024 * 1024 ||
                    bytes[0] != 79.toByte() || bytes[1] != 103.toByte() ||
                    bytes[2] != 103.toByte() || bytes[3] != 83.toByte()
                ) {
                    result.success(false)
                } else {
                    playOpusBytes(bytes, result)
                }
            }
            "stop" -> {
                stopInternal(completePending = true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun playAsset(assetPath: String, result: MethodChannel.Result) {
        stopInternal(completePending = true)
        try {
            val key = FlutterInjector.instance()
                .flutterLoader()
                .getLookupKeyForAsset(assetPath)
            val descriptor = context.assets.openFd(key)
            val next = MediaPlayer()
            next.setDataSource(
                descriptor.fileDescriptor,
                descriptor.startOffset,
                descriptor.length,
            )
            descriptor.close()

            pendingResult = result
            player = next

            next.setOnPreparedListener { prepared ->
                prepared.start()
            }
            next.setOnCompletionListener {
                completePlayback(success = true)
            }
            next.setOnErrorListener { _, _, _ ->
                completePlayback(success = false)
                true
            }
            next.prepareAsync()
        } catch (_: Exception) {
            releasePlayer()
            pendingResult = null
            result.success(false)
        }
    }

    private var activeByteSource: MediaDataSource? = null

    private fun playOpusBytes(bytes: ByteArray, result: MethodChannel.Result) {
        stopInternal(completePending = true)
        try {
            val source = object : MediaDataSource() {
                override fun getSize(): Long = bytes.size.toLong()

                override fun readAt(
                    position: Long, buffer: ByteArray, offset: Int, size: Int
                ): Int {
                    if (position < 0 || position >= bytes.size) return -1
                    if (offset < 0 || size < 0 || offset > buffer.size - size) return -1
                    val available = minOf(size, bytes.size - position.toInt())
                    System.arraycopy(bytes, position.toInt(), buffer, offset, available)
                    return available
                }

                override fun close() {}
            }
            val next = MediaPlayer()
            next.setDataSource(source)
            activeByteSource = source
            pendingResult = result
            player = next
            next.setOnPreparedListener { it.start() }
            next.setOnCompletionListener { completePlayback(success = true) }
            next.setOnErrorListener { _, _, _ ->
                completePlayback(success = false)
                true
            }
            next.prepareAsync()
        } catch (_: Exception) {
            releasePlayer()
            pendingResult = null
            result.success(false)
        }
    }

    private fun completePlayback(success: Boolean) {
        val result = pendingResult
        pendingResult = null
        releasePlayer()
        result?.success(success)
    }

    private fun stopInternal(completePending: Boolean) {
        try {
            player?.stop()
        } catch (_: IllegalStateException) {
            // Release below is sufficient for an unprepared/already-stopped player.
        }
        releasePlayer()
        if (completePending) {
            val result = pendingResult
            pendingResult = null
            result?.success(false)
        }
    }

    private fun releasePlayer() {
        try {
            player?.reset()
        } catch (_: IllegalStateException) {
            // Best-effort cleanup.
        }
        try {
            player?.release()
        } catch (_: Exception) {
            // Best-effort cleanup.
        }
        player = null
        activeByteSource?.close()
        activeByteSource = null
    }

    private fun isSafeAssetPath(raw: String?): Boolean {
        if (raw == null) return false
        val value = raw.trim().replace('\\', '/')
        if (value.isEmpty() ||
            value.startsWith("/") ||
            value.contains("../") ||
            value.contains("/..") ||
            value.contains("//")
        ) {
            return false
        }
        val lower = value.lowercase()
        return ALLOWED_EXTENSIONS.any { lower.endsWith(it) }
    }
}
