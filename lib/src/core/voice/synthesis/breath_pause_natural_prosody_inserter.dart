/// Task 1107: Contextual micro-pause and inhalation synthesis
class BreathPauseInserter {
  int calculatePauseMs(String punctuation) => punctuation == '.' ? 250 : (punctuation == ',' ? 120 : 0);
}
