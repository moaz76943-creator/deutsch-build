/// Task 1155: Speaking rate meter and articulation pace calculator
class SpeechRateWpmMeter {
  double calculateWpm(int wordCount, int durationSeconds) => durationSeconds > 0 ? (wordCount / durationSeconds) * 60.0 : 0.0;
  bool isPaceNatural(double wpm) => wpm >= 90.0 && wpm <= 160.0;
}
