/// Task 1785: Translation Edit Rate (TER) metric tracking post-editing edits
class TranslationEditRateCalculator {
  double computeTer(List<String> ref, List<String> hyp) => (ref.length - hyp.length).abs() / (ref.isEmpty ? 1.0 : ref.length);
}
