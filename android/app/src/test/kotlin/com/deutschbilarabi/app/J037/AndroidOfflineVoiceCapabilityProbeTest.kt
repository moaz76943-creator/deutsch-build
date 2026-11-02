package com.deutschbilarabi.app.J037

import android.speech.tts.TextToSpeech
import com.deutschbilarabi.app.AndroidOfflineVoiceCapabilityProbe
import com.deutschbilarabi.app.VoiceCapabilitySnapshot
import com.deutschbilarabi.app.offlineVoiceLanguageTags
import com.deutschbilarabi.app.VoiceState
import com.deutschbilarabi.app.classifyVoiceState
import com.deutschbilarabi.app.buildCapabilityReport
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

    @Test
    fun capabilityClassificationMapsStatesCorrectly() {
        val supportedVoice = VoiceCapabilitySnapshot("de-DE", false, emptySet())
        val missingVoice = VoiceCapabilitySnapshot("fr-FR", false, setOf(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED))
        val unavailableVoice = VoiceCapabilitySnapshot("en-US", true, emptySet())
        val unknownVoice = VoiceCapabilitySnapshot("  ", false, emptySet())

        assertEquals(VoiceState.SUPPORTED, classifyVoiceState(supportedVoice))
        assertEquals(VoiceState.MISSING, classifyVoiceState(missingVoice))
        assertEquals(VoiceState.UNAVAILABLE, classifyVoiceState(unavailableVoice))
        assertEquals(VoiceState.UNKNOWN, classifyVoiceState(unknownVoice))
    }

    @Test
    fun capabilityReportJsonSerialization() {
        val voices = listOf(
            VoiceCapabilitySnapshot("de-DE", false, emptySet()),
            VoiceCapabilitySnapshot("en-GB", true, emptySet()),
            VoiceCapabilitySnapshot("fr-FR", false, setOf(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)),
            VoiceCapabilitySnapshot("de-DE", false, emptySet()) // Duplicate test
        )

        val report = buildCapabilityReport(voices)
        assertTrue(report.contains("\"version\":\"1.0\""))
        assertTrue(report.contains("\"status\":\"available\""))
        assertTrue(report.contains("{\"languageTag\":\"de-DE\",\"state\":\"supported\"}"))
        assertTrue(report.contains("{\"languageTag\":\"en-GB\",\"state\":\"unavailable\"}"))
        assertTrue(report.contains("{\"languageTag\":\"fr-FR\",\"state\":\"missing\"}"))

        // Ensure no trailing comma and duplicate is ignored (de-DE is only once)
        val deCount = report.split("de-DE").size - 1
        assertEquals(1, deCount)
    }

    @Test
    fun capabilityReportJsonSerializationNull() {
        val report = buildCapabilityReport(null)
        assertTrue(report.contains("\"version\":\"1.0\""))
        assertTrue(report.contains("\"status\":\"unavailable\""))
        assertTrue(report.contains("\"voices\":[]"))
    }
}
