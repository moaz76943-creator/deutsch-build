/// Task 1168: Comprehension confirmation cues inserted at discourse intervals
class ComprehensionCheckTrigger {
  int sentenceCount = 0;
  bool shouldTriggerCheck() {
    sentenceCount++;
    return sentenceCount % 4 == 0;
  }
}
