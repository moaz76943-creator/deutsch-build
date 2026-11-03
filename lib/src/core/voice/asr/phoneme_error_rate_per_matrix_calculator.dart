/// Task 1151: Phoneme Error Rate (PER) matrix calculator
class PhonemeErrorRateCalculator {
  double calculatePer(List<String> hyp, List<String> ref) {
    if (ref.isEmpty) return 0.0;
    int mismatches = 0;
    for (int i = 0; i < hyp.length && i < ref.length; i++) {
      if (hyp[i] != ref[i]) mismatches++;
    }
    mismatches += (hyp.length - ref.length).abs();
    return (mismatches / ref.length).clamp(0.0, 1.0);
  }
}
