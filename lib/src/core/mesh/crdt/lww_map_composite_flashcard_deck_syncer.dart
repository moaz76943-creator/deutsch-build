/// Task 1536: LWW-Map resolving concurrent updates to flashcard intervals
class LwwFlashcardMap {
  final Map<String, Map<String, dynamic>> _entries = {};
  void setRating(String cardId, int rating, int ts) {
    if (ts >= (_entries[cardId]?['ts'] ?? 0)) {
      _entries[cardId] = {'rating': rating, 'ts': ts};
    }
  }
}
