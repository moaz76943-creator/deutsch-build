class LexicalFrequencyPacerZipf {
  final Map<String, int> _ranks = {};
  void registerRank(String word, int rank) => _ranks[word.toLowerCase().trim()] = rank;
  int getTier(String word) {
    final r = _ranks[word.toLowerCase().trim()] ?? 99999;
    if (r <= 500) return 1;
    if (r <= 2000) return 2;
    if (r <= 5000) return 3;
    return 4;
  }
}
