class IncidentalVocabularyTracker {
  final Map<String, int> _counts = {};
  void recordEncounter(String word) => _counts[word.toLowerCase()] = (_counts[word.toLowerCase()] ?? 0) + 1;
  bool isProductiveReady(String word) => (_counts[word.toLowerCase()] ?? 0) >= 10;
}
