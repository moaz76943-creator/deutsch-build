package com.deutschbilarabi.app.J037

import android.speech.tts.TextToSpeech
import com.deutschbilarabi.app.AndroidOfflineVoiceCapabilityProbe
import com.deutschbilarabi.app.VoiceCapabilitySnapshot
import com.deutschbilarabi.app.offlineVoiceLanguageTags
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidOfflineVoiceCapabilityProbeTest {
    @Test
    fun channelAndMethodMatchDictationScreen() {
        assertEquals(
            "com.deutschbilarabi.app/offline_voice_capability",
            AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME,
        )
        assertEquals(
            "getOfflineVoices",
            AndroidOfflineVoiceCapabilityProbe.METHOD_GET_OFFLINE_VOICES,
        )
    }

    @Test
    fun classificationKeepsInstalledOfflineVoicesOnly() {
        val voices = listOf(
            VoiceCapabilitySnapshot(
                languageTag = "de-DE",
                networkConnectionRequired = false,
                features = emptySet(),
            ),
            VoiceCapabilitySnapshot(
                languageTag = "en-GB",
                networkConnectionRequired = true,
                features = emptySet(),
            ),
            VoiceCapabilitySnapshot(
                languageTag = "fr-FR",
                networkConnectionRequired = false,
                features = setOf(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED),
            ),
            VoiceCapabilitySnapshot(
                languageTag = "de-DE",
                networkConnectionRequired = false,
                features = emptySet(),
            ),
            VoiceCapabilitySnapshot(
                languageTag = "  ",
                networkConnectionRequired = false,
                features = emptySet(),
            ),
        )

        val offline = offlineVoiceLanguageTags(voices)

        assertEquals(listOf("de-DE"), offline)
    }

    @Test
    fun missingVoiceInventoryFailsClosed() {
        assertTrue(offlineVoiceLanguageTags(null).isEmpty())
        assertTrue(offlineVoiceLanguageTags(emptyList()).isEmpty())
    }
}
