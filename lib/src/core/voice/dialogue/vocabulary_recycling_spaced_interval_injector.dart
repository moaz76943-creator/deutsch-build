/// Task 1177: Spaced recycling of previously learned lemmas into turns
class VocabularyRecyclingInjector {
  final Set<String> _dueWords = {};
  void enqueueReview(String word) => _dueWords.add(word);
  String? popNextReview() => _dueWords.isNotEmpty ? _dueWords.first : null;
}
