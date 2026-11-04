/// Task 1435: Phonation-time fraction (PTF) calculator
class PhonationTimeFractionCalculator {
  double calculatePtf(int speechMs, int totalMs) => totalMs > 0 ? (speechMs / totalMs).clamp(0.0, 1.0) : 0.0;
}
