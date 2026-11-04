/// Task 1936: Adaptive speech rate governor calibrated to learner level
class SpeechRatePacingGovernor {
  double getSpeechRate(String cefr) => cefr == 'A1' ? 0.8 : (cefr == 'C1' ? 1.05 : 0.95);
}
