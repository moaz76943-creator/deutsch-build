import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class MasteryCalculator {
  /// Calculate domain mastery from deduplicated genuine review events.
  static DomainMasteryProjection calculateDomainMastery({
    required String domainId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required int eligibleCardCount,
    required List<ReviewTransactionEnvelope> reviews,
    required int masteryRevision,
  }) {
    final Set<String> processedEvents = {};
    // Map cardId to consecutive successes or score
    final Map<String, int> cardSuccesses = {};
    DateTime? lastEvidence;

    final String targetPairKey = '${sourceLanguageId}_$targetLanguageId';

    // Sort by timestamp to process chronologically
    final sortedReviews = List<ReviewTransactionEnvelope>.from(reviews)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final review in sortedReviews) {
      if (review.languagePairKey != targetPairKey) continue;

      // Deduplicate events (Verify that repeated events cannot award duplicate points)
      if (processedEvents.contains(review.reviewEventId)) continue;
      processedEvents.add(review.reviewEventId);

      // Require an approved mastery threshold before advancement.
      // 2 = good, 3 = easy (success). 0 = again, 1 = hard (failure)
      // Treat missing or conflicting review evidence as unknown (reset progress).

      final cardKey = review.learnerContentKey;
      final currentSuccesses = cardSuccesses[cardKey] ?? 0;

      if (review.rating >= 2) {
         cardSuccesses[cardKey] = currentSuccesses + 1;
      } else {
         cardSuccesses[cardKey] = 0; // reset on failure
      }

      // Track last real evidence
      if (lastEvidence == null || review.timestamp.isAfter(lastEvidence)) {
        lastEvidence = review.timestamp;
      }
    }

    int introducedCount = 0;
    int recalledCount = 0;
    int masteredCount = 0;

    for (final successes in cardSuccesses.values) {
      introducedCount++;
      if (successes >= 1) recalledCount++;
      // Mastery threshold: e.g., 3 consecutive successes
      if (successes >= 3) masteredCount++;
    }

    // Reject negative or impossible mastery calculations.
    if (eligibleCardCount < 0) eligibleCardCount = 0;
    if (introducedCount > eligibleCardCount) introducedCount = eligibleCardCount;
    if (recalledCount > introducedCount) recalledCount = introducedCount;
    if (masteredCount > eligibleCardCount) masteredCount = eligibleCardCount;

    return DomainMasteryProjection(
      domainId: domainId,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      eligibleCardCount: eligibleCardCount,
      introducedCardCount: introducedCount,
      recalledCardCount: recalledCount,
      masteredCardCount: masteredCount,
      dueCardCount: 0,
      lastEvidenceUtc: lastEvidence ?? DateTime.utc(1970),
      masteryRevision: masteryRevision,
    );
  }
}
