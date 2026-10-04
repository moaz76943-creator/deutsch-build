import '../../models/learner.dart';

final class PairProgressCard {
  const PairProgressCard({
    required this.pairKey,
    required this.cardId,
    required this.learned,
    required this.correctCount,
    required this.incorrectCount,
    required this.lastReviewedAt,
    required this.reviewCard,
  });

  final String pairKey;
  final String cardId;
  final bool learned;
  final int correctCount;
  final int incorrectCount;
  final DateTime lastReviewedAt;
  final ReviewCard? reviewCard;
}

final class PairProgressSnapshot {
  const PairProgressSnapshot({
    required this.pairKey,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.level,
    required this.achievementPoints,
    required this.cards,
  });

  final String pairKey;
  final String sourceLanguageId;
  final String targetLanguageId;
  final int level;
  final int achievementPoints;
  final List<PairProgressCard> cards;

  int get learnedCardCount =>
      cards.where((card) => card.learned).length;
}
