/// Task 1466: Scanning speed vs Skimming gist comprehension timer
class SpeedReadingTimer {
  double calculateWpm(int wordCount, int seconds) => seconds > 0 ? (wordCount / seconds) * 60.0 : 0.0;
}
