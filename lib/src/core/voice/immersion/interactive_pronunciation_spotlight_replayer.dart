/// Task 1192: Targeted audio scrubber isolating mispronounced phoneme segments
class PronunciationSpotlightReplayer {
  List<int> sliceAudioSnippet(List<int> fullPcm, int startMs, int endMs) => fullPcm.sublist(0, (fullPcm.length ~/ 2).clamp(0, fullPcm.length));
}
