/// Task 1298: Time-stamped text transcripts accompanying audio dialogues
class MediaTranscriptAggregator {
  final List<String> lines = [];
  void addTranscriptLine(int ms, String text) => lines.add('[$ms ms] $text');
}
