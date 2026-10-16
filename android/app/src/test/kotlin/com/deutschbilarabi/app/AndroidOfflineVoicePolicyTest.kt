package com.deutschbilarabi.app

/** Executable with plain kotlinc; no Android runtime, network, microphone or Gradle needed. */
fun main() {
    val observed = AndroidOfflineVoicePolicy.installedLocalCandidates(
        listOf(
            OfflineVoiceCandidate("de-DE", false, false, false),
            OfflineVoiceCandidate("de-DE", false, false, false),
            OfflineVoiceCandidate("ar-SA", false, false, false),
            OfflineVoiceCandidate("fr-FR", true, false, false),
            OfflineVoiceCandidate("es-ES", false, true, false),
            OfflineVoiceCandidate("ja-JP", false, false, true),
            OfflineVoiceCandidate("und", false, false, false),
            OfflineVoiceCandidate("bad tag!", false, false, false),
        ),
    )
    check(observed == listOf("ar-SA", "de-DE")) { "Local candidate filter failed: $observed" }
    check(AndroidOfflineVoicePolicy.installedLocalCandidates(emptyList()).isEmpty())
    val many = (0..150).map { OfflineVoiceCandidate("de-X${it}", false, false, false) }
    check(AndroidOfflineVoicePolicy.installedLocalCandidates(many).size <= 128)
    println("PASS: offline voice policy (filter, ordering, duplicates, fail-closed, bound)")
}
