enum DomainMasteryState { locked, available, inProgress, mastered }

/// Display projection only. These counters MUST originate from an authoritative,
/// pair-isolated persisted SRS snapshot; event rating alone is not mastery proof.
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

  /// Preserve legacy snapshots without mutating or deleting their data.
  /// Never show a success state when counters are malformed.
  bool get hasConsistentCounters =>
      domainId.trim().isNotEmpty &&
      sourceLanguageId.trim().isNotEmpty &&
      targetLanguageId.trim().isNotEmpty &&
      sourceLanguageId != targetLanguageId &&
      eligibleCardCount >= 0 &&
      introducedCardCount >= 0 &&
      recalledCardCount >= 0 &&
      masteredCardCount >= 0 &&
      dueCardCount >= 0 &&
      introducedCardCount <= eligibleCardCount &&
      recalledCardCount <= introducedCardCount &&
      masteredCardCount <= recalledCardCount &&
      dueCardCount <= introducedCardCount &&
      masteryRevision >= 0;

  double get masteryPercentage {
    if (!hasConsistentCounters || eligibleCardCount == 0) return 0.0;
    return (masteredCardCount / eligibleCardCount).clamp(0.0, 1.0).toDouble();
  }

  DomainMasteryState get masteryState {
    if (!hasConsistentCounters) {
      return introducedCardCount > 0
          ? DomainMasteryState.inProgress
          : DomainMasteryState.available;
    }
    if (introducedCardCount == 0) return DomainMasteryState.available;
    if (eligibleCardCount > 0 && masteredCardCount == eligibleCardCount) {
      return DomainMasteryState.mastered;
    }
    return DomainMasteryState.inProgress;
  }
}
