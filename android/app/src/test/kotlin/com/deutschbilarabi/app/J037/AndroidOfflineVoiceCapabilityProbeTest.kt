package com.deutschbilarabi.app.J037

import android.speech.tts.TextToSpeech
import com.deutschbilarabi.app.AndroidOfflineVoiceCapabilityProbe
import com.deutschbilarabi.app.VoiceCapabilitySnapshot
import com.deutschbilarabi.app.offlineVoiceLanguageTags

class AndroidOfflineVoiceCapabilityProbeTest {
    fun channelAndMethodMatchDictationScreen() {
        assert("com.deutschbilarabi.app/offline_voice_capability" == AndroidOfflineVoiceCapabilityProbe.CHANNEL_NAME)
        assert("getOfflineVoices" == AndroidOfflineVoiceCapabilityProbe.METHOD_GET_OFFLINE_VOICES)
    }

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
        assert(listOf("de-DE") == offline)
    }

    fun missingVoiceInventoryFailsClosed() {
        assert(offlineVoiceLanguageTags(null).isEmpty())
        assert(offlineVoiceLanguageTags(emptyList()).isEmpty())
    }
}
