import 'data/database.dart';
import 'domain/models.dart';

class ReverseQuizMode {
  final ReverseQuizDatabase _database;

  ReverseQuizMode(this._database);

  Future<void> initialize(List<ReverseQuizItem> initialCards) async {
    final mappedCards = initialCards.map((card) => card.toMap()).toList();
    await _database.insertFlashcards(mappedCards);
  }

  Future<List<ReverseQuizItem>> fetchQuizItems(int count) async {
    final records = await _database.getRandomFlashcards(count);
    return records.map((record) => ReverseQuizItem.fromMap(record)).toList();
  }

  Future<void> submitAnswer(String cardId, bool isCorrect) async {
    final attempt = ReverseQuizAttempt(
      id: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
      cardId: cardId,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );
    await _database.recordAttempt(attempt.toMap());
  }

  Future<void> close() async {
    await _database.close();
  }
}
