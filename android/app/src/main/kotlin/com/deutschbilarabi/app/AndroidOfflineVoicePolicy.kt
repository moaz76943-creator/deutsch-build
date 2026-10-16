package com.deutschbilarabi.app

/** Metadata supplied by an installed Android TTS engine, not a playback guarantee. */
internal data class OfflineVoiceCandidate(
    val localeTag: String,
    val networkRequired: Boolean,
    val networkSynthesisFeature: Boolean,
    val notInstalledFeature: Boolean,
)

/** Fail closed when voice metadata cannot prove a local, installed candidate. */
internal object AndroidOfflineVoicePolicy {
    private val validTag = Regex("^[A-Za-z]{2,8}(-[A-Za-z0-9]{1,8})*$")
    private const val MAX_LOCALES = 128

    fun installedLocalCandidates(voices: Iterable<OfflineVoiceCandidate>): List<String> =
        voices.asSequence()
            .filter { !it.networkRequired && !it.networkSynthesisFeature && !it.notInstalledFeature }
            .map { it.localeTag }
            .filter { it != "und" && validTag.matches(it) }
            .distinct()
            .sorted()
            .take(MAX_LOCALES)
            .toList()
}
