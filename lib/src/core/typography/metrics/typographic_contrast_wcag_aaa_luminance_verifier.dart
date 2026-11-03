/// Task 1271: WCAG 2.1 AAA 7:1 contrast ratio verifier
class WcagLuminanceVerifier {
  double calculateContrast(double l1, double l2) => (l1 + 0.05) / (l2 + 0.05);
  bool isWcagAaa(double contrast) => contrast >= 7.0;
}
