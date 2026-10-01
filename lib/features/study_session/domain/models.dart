enum Rating { again, hard, good, easy }

class Flashcard {
  final String id;
  final String conceptId;
  final String german;
  final String arabic;

  const Flashcard({
    required this.id,
    required this.conceptId,
    required this.german,
    required this.arabic,
  });
}

class SessionResult {
  final int totalReviewed;
  final double accuracyPercentage;
  final int timeSpentSeconds;

  const SessionResult({
    required this.totalReviewed,
    required this.accuracyPercentage,
    required this.timeSpentSeconds,
  });
}
