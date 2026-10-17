import '../progress/review_transaction_envelope.dart';
import 'domain_mastery_projection.dart';

class MasteryProjectionEngine {
  /// Calculates the domain mastery projection deterministically based on SRS events.
  static DomainMasteryProjection calculate({
    required String domainId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required Set<String> eligibleContentKeys,
    required List<ReviewTransactionEnvelope> events,
    int masteryThreshold = 3,
    Duration boundedReplayWindow = const Duration(days: 365),
    DateTime? now,
  }) {
    final languagePairKey = '${sourceLanguageId}_$targetLanguageId';
    final currentTime = now ?? DateTime.now();
    final replayCutoff = currentTime.subtract(boundedReplayWindow);

    // Sort events by timestamp ascending for deterministic replay.
    final sortedEvents = List<ReviewTransactionEnvelope>.from(events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final Map<String, int> successes = {};
    final Set<String> introduced = {};
    final Set<String> recalled = {};
    DateTime? lastEvidence;
    final Set<String> processedEventIds = {};
    int masteryRevision = 0;

    for (final event in sortedEvents) {
      if (event.timestamp.isBefore(replayCutoff)) continue;
      if (event.timestamp.isAfter(currentTime)) {
        continue; // Reject future invalid timestamps
      }
      if (event.languagePairKey != languagePairKey) continue;

      // Deduplicate
      if (processedEventIds.contains(event.reviewEventId)) continue;
      processedEventIds.add(event.reviewEventId);

      // Only count events for eligible cards.
      if (!eligibleContentKeys.contains(event.learnerContentKey)) continue;

      introduced.add(event.learnerContentKey);
      masteryRevision++;

      if (lastEvidence == null || event.timestamp.isAfter(lastEvidence)) {
        lastEvidence = event.timestamp;
      }

      final isSuccess = event.rating >= 3;
      if (isSuccess) {
        recalled.add(event.learnerContentKey);
        successes[event.learnerContentKey] =
            (successes[event.learnerContentKey] ?? 0) + 1;
      } else {
        recalled.remove(event.learnerContentKey);
        // Failures reset mastery progress
        successes[event.learnerContentKey] = 0;
      }
    }

    int masteredCardCount = 0;
    for (final key in introduced) {
      final s = successes[key] ?? 0;
      if (s >= masteryThreshold) {
        masteredCardCount++;
      }
    }

    int dueCardCount = introduced.length - masteredCardCount;
    if (dueCardCount < 0) dueCardCount = 0;

    return DomainMasteryProjection(
      domainId: domainId,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      eligibleCardCount: eligibleContentKeys.length,
      introducedCardCount: introduced.length,
      recalledCardCount: recalled.length,
      masteredCardCount: masteredCardCount,
      dueCardCount: dueCardCount,
      lastEvidenceUtc: lastEvidence?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      masteryRevision: masteryRevision,
    );
  }
}
