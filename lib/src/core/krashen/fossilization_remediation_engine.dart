class FossilizationRemediationEngine {
  final Map<String, int> _mistakes = {};
  void recordMistake(String pattern) => _mistakes[pattern] = (_mistakes[pattern] ?? 0) + 1;
  bool isFossilized(String pattern) => (_mistakes[pattern] ?? 0) >= 5;
}
