/// Task 1416: Adaptive penalty attenuator scaling score deductions for hints
class HintPenaltyAttenuator {
  double calculateScore(int hintTier, double basePoints) => basePoints * (1.0 - hintTier * 0.25).clamp(0.0, 1.0);
}
