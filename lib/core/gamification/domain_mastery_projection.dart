// SRS-derived view only. The persistence layer supplies the verified
// counters; this class must not infer "mastered" from arbitrary raw ratings.
class DomainMasteryProjection {
  final String domainId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final int eligibleCardCount;
  final int introducedCardCount;
  final int recalledCardCount;
  final int masteredCardCount;
  final int dueCardCount;
  final DateTime lastEvidenceUtc;
  final int masteryRevision;

  const DomainMasteryProjection({
    required this.domainId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.eligibleCardCount,
    required this.introducedCardCount,
    required this.recalledCardCount,
    required this.masteredCardCount,
    required this.dueCardCount,
    required this.lastEvidenceUtc,
    required this.masteryRevision,
  });

  /// Use only counters obtained from one committed directed-pair SRS snapshot.
  /// This does not establish CEFR proficiency or manufacture review history.
  factory DomainMasteryProjection.fromVerifiedCounters({
    required String domainId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required int eligibleCardCount,
    required int introducedCardCount,
    required int recalledCardCount,
    required int masteredCardCount,
    required int dueCardCount,
    required DateTime lastEvidenceUtc,
    required int masteryRevision,
  }) {
    if (domainId.trim().isEmpty ||
        sourceLanguageId.trim().isEmpty ||
        targetLanguageId.trim().isEmpty ||
        sourceLanguageId == targetLanguageId ||
        masteryRevision < 0 ||
        eligibleCardCount < 0 ||
        introducedCardCount < 0 ||
        introducedCardCount > eligibleCardCount ||
        recalledCardCount < 0 ||
        recalledCardCount > introducedCardCount ||
        masteredCardCount < 0 ||
        masteredCardCount > recalledCardCount ||
        dueCardCount < 0 ||
        dueCardCount > introducedCardCount) {
      throw ArgumentError('Invalid verified, pair-isolated SRS counters');
    }
    return DomainMasteryProjection(
      domainId: domainId,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      eligibleCardCount: eligibleCardCount,
      introducedCardCount: introducedCardCount,
      recalledCardCount: recalledCardCount,
      masteredCardCount: masteredCardCount,
      dueCardCount: dueCardCount,
      lastEvidenceUtc: lastEvidenceUtc.toUtc(),
      masteryRevision: masteryRevision,
    );
  }

  double get masteryPercentage {
    if (eligibleCardCount <= 0) return 0.0;
    return (masteredCardCount / eligibleCardCount).clamp(0.0, 1.0).toDouble();
  }

  DomainMasteryState get masteryState {
    if (introducedCardCount <= 0) return DomainMasteryState.available;
    if (masteredCardCount == eligibleCardCount && eligibleCardCount > 0) {
      return DomainMasteryState.mastered;
    }
    return DomainMasteryState.inProgress;
  }
}

enum DomainMasteryState { locked, available, inProgress, mastered }
