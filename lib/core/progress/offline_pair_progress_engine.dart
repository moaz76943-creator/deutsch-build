import '../../models/learner.dart';
import '../models/language_catalog_models.dart';
import '../packs/pack_models.dart';
import '../srs_facets.dart';
import '../srs_scheduler.dart';
import '../storage/local_db/pair_progress_database.dart';
import 'pair_progress_models.dart';

final class OfflinePairProgressEngine {
  const OfflinePairProgressEngine(this._store);

  final PairProgressDatabase _store;

  Future<void> recordCard({
    required ResolvedLanguagePair pair,
    required String cardId,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
  }) async {
    final context = _validatePair(pair);
    final normalizedCardId = _cardId(cardId);
    _validateProgress(level, achievementDelta);

    await _store.recordCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      cardId: normalizedCardId,
      learned: learned,
      level: level,
      achievementDelta: achievementDelta,
      correct: correct,
      reviewedAt: reviewedAt,
    );
  }

  Future<void> migrateLegacySnapshot({
    required ResolvedLanguagePair pair,
    required Iterable<ReviewCard> reviewCards,
    required Set<String> learnedConceptIds,
    required int achievementPoints,
    int level = 0,
  }) async {
    final context = _validatePair(pair);
    _validateProgress(level, achievementPoints);
    final cards = reviewCards.toList(growable: false);
    if (cards.any((card) => !card.facetKey.isValid)) {
      throw ArgumentError('Invalid legacy review card.');
    }
    await _store.migrateLegacySnapshot(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewCards: cards,
      learnedConceptIds: learnedConceptIds,
      achievementPoints: achievementPoints,
      level: level,
    );
  }

  Future<void> importReviewCard({
    required ResolvedLanguagePair pair,
    required ReviewCard reviewCard,
    required bool learned,
    int level = 0,
    int achievementDelta = 0,
  }) async {
    final context = _validatePair(pair);
    _validateProgress(level, achievementDelta);
    if (!reviewCard.facetKey.isValid) {
      throw ArgumentError('Invalid review card.');
    }
    await _store.importReviewCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewCard: reviewCard,
      learned: learned,
      level: level,
      achievementDelta: achievementDelta,
    );
  }

  Future<void> persistScheduledReview({
    required ResolvedLanguagePair pair,
    required ReviewCard reviewCard,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
  }) async {
    final context = _validatePair(pair);
    _validateProgress(level, achievementDelta);
    if (!reviewCard.facetKey.isValid) {
      throw ArgumentError('Invalid review card.');
    }
    await _store.recordScheduledReview(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewCard: reviewCard,
      learned: learned,
      level: level,
      achievementDelta: achievementDelta,
      correct: correct,
      reviewedAt: reviewedAt,
    );
  }

  Future<ReviewCard> scheduleReview({
    required ResolvedLanguagePair pair,
    required String conceptId,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
    required bool correct,
    required bool hinted,
    required int level,
    required int achievementDelta,
    required DateTime reviewedAt,
    SrsScheduler scheduler = unifiedSrsScheduler,
  }) async {
    final context = _validatePair(pair);
    _validateProgress(level, achievementDelta);
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) {
      throw ArgumentError('Invalid review facet key.');
    }

    final current = await _store.loadReviewCard(
          sourceLanguageId: context.source,
          targetLanguageId: context.target,
          cardId: key.storageKey,
        ) ??
        ReviewCard(
          itemId: key.conceptId.trim(),
          facetType: key.facetType,
          variantKey: key.normalizedVariantKey,
          dueAt: reviewedAt,
        );
    final updated = await scheduler.schedule(
      current,
      correct: correct,
      hinted: hinted,
      now: reviewedAt,
    );

    await _store.recordScheduledReview(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewCard: updated,
      learned: correct,
      level: level,
      achievementDelta: achievementDelta,
      correct: correct,
      reviewedAt: reviewedAt,
    );
    return updated;
  }

  Future<ReviewCard?> loadReviewCard(
    ResolvedLanguagePair pair, {
    required String conceptId,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
  }) {
    final context = _validatePair(pair);
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) {
      throw ArgumentError('Invalid review facet key.');
    }
    return _store.loadReviewCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      cardId: key.storageKey,
    );
  }

  Future<void> clearAll() => _store.clearAll();

  Future<void> clearPair(ResolvedLanguagePair pair) {
    final context = _validatePair(pair);
    return _store.clearPair(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
    );
  }

  Future<PairProgressSnapshot> loadPair(
    ResolvedLanguagePair pair,
  ) {
    final context = _validatePair(pair);
    return _store.loadPair(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
    );
  }

  Future<PairProgressCard?> loadCard(
    ResolvedLanguagePair pair,
    String cardId,
  ) {
    final context = _validatePair(pair);
    final normalizedCardId = _cardId(cardId);
    return _store.loadCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      cardId: normalizedCardId,
    );
  }

  /// Loads pending review transactions from the bounded journal.
  /// Delegates to PairProgressDatabase with bounded limit.
  Future<List<Map<String, Object?>>> loadPendingReviewTransactions(
      {int limit = 128}) {
    return _store.loadPendingReviewTransactions(limit: limit);
  }

  /// Persists a review transaction envelope to the bounded journal.
  /// Called by ReviewTransactionReconciler / repository to record
  /// pending reviews before durable commit.
  Future<void> persistReviewEnvelope({
    required ResolvedLanguagePair pair,
    required String reviewEventId,
    required String cardId,
    required int rating,
    required DateTime reviewedAt,
    required bool correct,
    required bool hinted,
    required int achievementDelta,
    required int requestedXp,
  }) async {
    final context = _validatePair(pair);
    await _store.recordScheduledReviewEnvelope(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewEventId: reviewEventId,
      cardId: _cardId(cardId),
      rating: rating,
      reviewedAt: reviewedAt,
      correct: correct,
      hinted: hinted,
      achievementDelta: achievementDelta,
      requestedXp: requestedXp,
    );
  }

  /// Persists a review delivery envelope via the durable bounded journal,
  /// used for conversation-reward records with kind:'conversation' metadata.
  Future<void> persistReviewDeliveryEnvelope({
    required ResolvedLanguagePair pair,
    required String reviewEventId,
    required String cardId,
    required int rating,
    required DateTime timestamp,
    required String languagePairKey,
    required String learnerContentKey,
    required bool correct,
    required bool hinted,
    required int achievedLevel,
    required int achievementDelta,
    required int requestedXp,
    required String kind,
    required ReviewFacetType facetType,
  }) async {
    final context = _validatePair(pair);
    await _store.recordReviewDeliveryEnvelope(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      reviewEventId: reviewEventId,
      cardId: cardId,
      rating: rating,
      timestamp: timestamp,
      languagePairKey: languagePairKey,
      learnerContentKey: learnerContentKey,
      correct: correct,
      hinted: hinted,
      achievedLevel: achievedLevel,
      achievementDelta: achievementDelta,
      requestedXp: requestedXp,
      kind: kind,
      facetType: facetType,
    );
  }

  /// Applies a single review attempt (progress + SRS) for the durable sink.
  /// Returns true when the attempt was applied (or was already committed).
  Future<bool> applyReviewAttemptOnce(ReviewTransactionEnvelope envelope) async {
    // Reconstruct the pair from the envelope's languagePairKey.
    // Journal rows store '${sourceId}_${targetId}'; the pair's uniqueKey is
    // '${sourceLocale}_${targetLocale}_${semanticVersion}'. Take the first two
    // segments; anything else cannot be applied.
    final segments = envelope.languagePairKey.split('_');
    if (segments.length < 2) {
      // Cannot apply attempt without a valid pair; treat as not applicable.
      return false;
    }
    final sourceId = segments.first;
    final targetId = segments[1];

    final currentCard = await _store.loadReviewCard(
      sourceLanguageId: sourceId,
      targetLanguageId: targetId,
      cardId: envelope.learnerContentKey,
    ) ??
        ReviewCard(
          itemId: envelope.learnerContentKey,
          dueAt: envelope.timestamp,
        );

    final correct = envelope.rating >= 2;
    final hinted = false;
    final updatedCard = await unifiedSrsScheduler.schedule(
      currentCard,
      correct: correct,
      hinted: hinted,
      now: envelope.timestamp,
    );

    await _store.recordScheduledReview(
      sourceLanguageId: sourceId,
      targetLanguageId: targetId,
      reviewCard: updatedCard,
      learned: correct,
      level: 0,
      achievementDelta: correct ? 1 : 0,
      correct: correct,
      reviewedAt: envelope.timestamp,
    );
    return true;
  }

  _PairContext _validatePair(ResolvedLanguagePair pair) {
    final source = _language(pair.source.id, 'pair.source.id');
    final target = _language(pair.target.id, 'pair.target.id');
    if (source == target) {
      throw ArgumentError('Pair source and target must differ.');
    }

    final request = PackPairRequest(
      sourceLanguageTag: source,
      targetLanguageTag: target,
    );
    if (pair.pairKey != request.pairKey ||
        pair.route.request.pairKey != request.pairKey) {
      throw StateError('resolved_pair_context_mismatch');
    }

    return _PairContext(source: source, target: target);
  }

  static String _cardId(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty || normalized.length > 1024) {
      throw ArgumentError.value(
        raw,
        'cardId',
        'must be 1..1024 characters',
      );
    }
    return normalized;
  }

  static void _validateProgress(
    int level,
    int achievementDelta,
  ) {
    if (level < 0 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be 0..100');
    }
    if (achievementDelta < 0 || achievementDelta > 100000) {
      throw ArgumentError.value(
        achievementDelta,
        'achievementDelta',
        'must be 0..100000',
      );
    }
  }

  static String _language(String raw, String field) {
    final normalized =
        raw.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
        .hasMatch(normalized)) {
      throw ArgumentError.value(
        raw,
        field,
        'must be a valid language tag',
      );
    }
    return normalized;
  }
}

final class _PairContext {
  const _PairContext({
    required this.source,
    required this.target,
  });

  final String source;
  final String target;
}
