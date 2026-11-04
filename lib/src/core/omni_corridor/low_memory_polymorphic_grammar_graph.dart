/// Task 1903: Polymorphic grammar graph with minimal RAM footprint
class PolymorphicGrammarGraph {
  final Map<String, List<String>> _grammarNodes = {};
  void linkGrammarRule(String lang, String rule) => _grammarNodes.setdefault(lang, []).add(rule);
}
