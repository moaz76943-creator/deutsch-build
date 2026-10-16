abstract class LearnerProgressStorageContract {
  Future<void> saveCardProgress({
    required String cardId,
    required int intervalDays,
    required double easeFactor,
    required int repetitions,
    required DateTime nextReview,
  });

  Future<Map<String, dynamic>?> getCardProgress(String cardId);
  Future<List<String>> getDueCardIds(DateTime asOfTime);
}

abstract class ContentDatabaseContract {
  Future<bool> verifyIntegrity(String packagePath, String expectedSha256);
  Future<List<Map<String, dynamic>>> queryVocabulary({
    required String domainId,
    int limit = 50,
    int offset = 0,
  });
}
