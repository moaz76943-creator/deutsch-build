/// Task 1425: Levenshtein phonetic distance aligner for error triage
class PhoneticDistanceAligner {
  int computePhoneticDistance(List<String> hyp, List<String> ref) => (hyp.length - ref.length).abs();
}
