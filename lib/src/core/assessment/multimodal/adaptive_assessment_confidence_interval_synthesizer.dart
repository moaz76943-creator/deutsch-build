/// Task 1496: Computes 95% Bayesian credibility intervals around CEFR score
class AssessmentConfidenceSynthesizer {
  List<double> getCredibilityInterval(double theta, double sem) => [theta - 1.96 * sem, theta + 1.96 * sem];
}
