class ImplicitGrammarInductionEngine {
  final Map<String, int> _bigrams = {};
  void observe(String a, String b) => _bigrams['$a->$b'] = (_bigrams['$a->$b'] ?? 0) + 1;
  int frequency(String a, String b) => _bigrams['$a->$b'] ?? 0;
}
