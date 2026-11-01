class DynamicContextualClueInjector {
  final Map<String, String> _clues = {};
  void registerClue(String word, String clue) => _clues[word] = clue;
  String inject(String sentence, String word) {
    final c = _clues[word];
    return c != null ? '$sentence ($c)' : sentence;
  }
}
