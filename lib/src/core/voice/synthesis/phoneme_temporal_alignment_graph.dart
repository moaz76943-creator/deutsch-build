/// Task 1102: Phoneme-to-frame duration predictor and alignment graph
class PhonemeAlignmentGraph {
  final Map<String, int> _durations = {};
  void setDuration(String phoneme, int frames) => _durations[phoneme] = frames;
  int getDuration(String phoneme) => _durations[phoneme] ?? 4;
}
