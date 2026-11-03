/// Task 1153: Closure duration timer for geminate/doubled consonants
class GeminateClosureTimer {
  int measureClosureMs(int startMs, int endMs) => endMs - startMs;
  bool isGeminate(int durationMs) => durationMs >= 140;
}
