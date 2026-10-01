import '../models/card_progress.dart';
import '../models/deck_summary.dart';
import '../models/review_log.dart';

abstract class ILearnerProgressRepository {
  Future<CardProgress?> getCardProgress(String cardId);
  Future<List<CardProgress>> getDueCards({required DateTime asOf, int? limit});
  Future<void> saveReview({
    required CardProgress updatedProgress,
    required ReviewLog log,
  });
  Future<DeckSummary> getDeckSummary(String deckId);
}
