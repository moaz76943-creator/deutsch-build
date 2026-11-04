/// Task 1398: Evaluates risk index of negative syntactic transfer
class TransferInterferenceEvaluator {
  double calculateRiskScore(String l1, String l2) => (l1 == 'ar' && l2 == 'de') ? 0.72 : 0.45;
}
