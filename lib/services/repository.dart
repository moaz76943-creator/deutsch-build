import '../core/content_contract.dart';
import 'preferences_service.dart';
import 'learner_persistence.dart';
import '../models/learner.dart';
import '../core/srs_facets.dart';
import '../core/srs_scheduler.dart';
import '../core/models/language_catalog_models.dart';
import '../core/progress/offline_pair_progress_engine.dart';
import '../core/progress/review_transaction_envelope.dart';
import '../core/progress/pair_progress_models.dart';
import '../models/assessment.dart';
import '../models/diagnostic_placement.dart';
import '../core/date_utils.dart';
import '../features/gamification/domain/gamification_models.dart';
import '../features/gamification/domain/gamification_review_sink.dart';
import '../features/gamification/gamification_repository.dart';
import '../features/error_pattern_agent/domain/error_diagnostic_repository.dart';
import '../features/error_pattern_agent/domain/error_pattern_models.dart';

/// Local learner-state storage. This app deliberately has no network trust boundary.
/// Persisted values are treated as untrusted input and are bounded before use.
class LearnerRepository {
  final PreferencesService prefs;
  LearnerRepository(
    this.prefs, {
    required this.persistence,
    this.gamificationReviewSink = const NoopGamificationReviewSink(),
    this.errorDiagnosticSink = const NoopErrorDiagnosticSink(),
  });

  final LearnerPersistence persistence;
  final GamificationReviewSink gamificationReviewSink;
  final ErrorDiagnosticSink errorDiagnosticSink;

  OfflinePairProgressEngine? _pairProgressEngine;
  ResolvedLanguagePair? _activeResolvedPair;
  static const key = 'v34_state';
  static const legacyFavoriteKey = 'verb_favorites_v1';
  static const maxAttempts = LearnerPersistence.maxAttempts;
  static const maxCollectionItems = LearnerPersistence.maxCollectionItems;
  static const maxXp = LearnerPersistence.maxXp;
  static const maxStreak = LearnerPersistence.maxStreak;
  Future<void> _writeQueue = Future<void>.value();
  LearnerState? _cachedState;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.then<void>((_) {}).catchError((_) {});
    return next;
  }

  static const maxMistakeProgress = 5000;

  LearnerState load() {
    final cached = _cachedState;
    if (cached != null) return cached;
    final loaded = _loadFromPrefs();
    _cachedState = loaded;
    return loaded;
  }

  /// Reloads the persisted state when another persistence actor may have changed it.
  /// Normal reads stay cached; callers that explicitly need storage truth use this boundary.
  LearnerState reload() {
    _cachedState = null;
    return load();
  }

  /// Reloads persisted state after all writes already queued by this repository finish.
  /// This prevents a synchronous storage read from observing a pre-write snapshot.
  Future<LearnerState> reloadPersisted() async {
    await _writeQueue;
    _cachedState = null;
    return load();
  }

  LearnerState _loadFromPrefs() => persistence.load();

  bool get hasPairProgressAuthority =>
      _pairProgressEngine != null && _activeResolvedPair != null;

  Future<void> bindPairProgressAuthority({
    required OfflinePairProgressEngine engine,
    required ResolvedLanguagePair pair,
    bool migrateLegacy = false,
    int migratedAchievementPoints = 0,
  }) =>
      _enqueue(() async {
        if (migratedAchievementPoints < 0 ||
            migratedAchievementPoints > maxXp) {
          throw ArgumentError.value(
            migratedAchievementPoints,
            'migratedAchievementPoints',
            'must be 0..$maxXp',
          );
        }

        final state = load();
        final hasLegacyProgress = state.reviewCards.isNotEmpty ||
            state.learned.isNotEmpty ||
            state.review.isNotEmpty;
        if (hasLegacyProgress && !migrateLegacy) {
          throw StateError(
            'legacy_pair_progress_requires_explicit_migration',
          );
        }

        if (migrateLegacy && hasLegacyProgress) {
          await _migrateLegacyProgress(
            state,
            engine: engine,
            pair: pair,
            migratedAchievementPoints:
                migratedAchievementPoints,
          );
        }

        _pairProgressEngine = engine;
        _activeResolvedPair = pair;

        if (migrateLegacy && hasLegacyProgress) {
          await _saveNow(
            state.copyWith(
              learned: <String>{},
              review: <String>{},
              reviewCards: <String, ReviewCard>{},
            ),
          );
        }
      });

  Future<PairProgressSnapshot> loadPairProgress() async {
    final authority = _requirePairProgressAuthority();
    return authority.engine.loadPair(authority.pair);
  }

  Future<ReviewCard?> loadPairReviewCard(
    String conceptId, {
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
  }) {
    final authority = _requirePairProgressAuthority();
    return authority.engine.loadReviewCard(
      authority.pair,
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
  }

  Future<void> _migrateLegacyProgress(
    LearnerState state, {
    required OfflinePairProgressEngine engine,
    required ResolvedLanguagePair pair,
    required int migratedAchievementPoints,
  }) async {
    final cards = <String, ReviewCard>{...state.reviewCards};
    final now = DateTime.now();

    for (final id in <String>{...state.learned, ...state.review}) {
      final normalized = id.trim();
      if (normalized.isEmpty || normalized.length > 160) {
        continue;
      }
      cards.putIfAbsent(
        normalized,
        () => ReviewCard(
          itemId: normalized,
          dueAt: now,
        ),
      );
    }

    await engine.migrateLegacySnapshot(
      pair: pair,
      reviewCards: cards.values,
      learnedConceptIds: state.learned,
      achievementPoints: migratedAchievementPoints,
    );
  }

  _PairProgressAuthority _requirePairProgressAuthority() {
    final engine = _pairProgressEngine;
    final pair = _activeResolvedPair;
    if (engine == null || pair == null) {
      throw StateError('pair_progress_authority_not_bound');
    }
    return _PairProgressAuthority(engine: engine, pair: pair);
  }

  LearnerState _withoutLegacyPairProgress(LearnerState state) {
    if (!hasPairProgressAuthority) return state;
    return state.copyWith(
      learned: <String>{},
      review: <String>{},
      reviewCards: <String, ReviewCard>{},
    );
  }

  Future<void> save(LearnerState s) => _enqueue(() async {
        final persisted = persistence.normalize(
          _withoutLegacyPairProgress(s),
        );
        await persistence.save(persisted);
        _cachedState = persisted;
      });

  Future<Set<String>> loadAndMigrateFavoriteVerbs() => _enqueue(() async {
        final result = await persistence.loadAndMigrateFavoriteVerbs(load());
        _cachedState = result;
        return result.favoriteVerbs;
      });

  Future<bool> clearLocalData() => _enqueue<bool>(() async {
        try {
          final authority = hasPairProgressAuthority
              ? _requirePairProgressAuthority()
              : null;
          if (authority != null) {
            await authority.engine.clearAll();
          }
          final learnerCleared = await persistence.clearLocalData();
          await gamificationReviewSink.clearGamification();
          return learnerCleared;
        } finally {
          _cachedState = null;
        }
      });

  Future<void> recordAssessment(AssessmentResult result) => _enqueue(() async {
        final s = load();
        final history = [
          AssessmentHistory(
            id: result.id,
            at: result.at,
            score: result.score,
            weakSkills: result.weakSkills,
            answered: result.answered,
          ),
          ...s.assessmentHistory,
        ].take(100).toList();
        await persistence.recordAssessmentOnce(history.first);
        await _saveNow(s.copyWith(assessmentHistory: history));
      });

  Future<void> recordWritingMistake({required String issue, DateTime? at}) =>
      _enqueue(() async {
        final s = load();
        final key = 'writing:${issue.trim().toLowerCase()}';
        final now = at ?? DateTime.now();
        final attempt = Attempt(
          id: 'w_${now.microsecondsSinceEpoch}',
          itemId: key,
          skill: 'writing',
          answer: issue.trim(),
          correct: false,
          hinted: false,
          seconds: 5,
          at: now,
        );
        final attempts = [...s.attempts, attempt];
        await persistence.applyReviewAttemptOnce(attempt);
        await _saveNow(
          s.copyWith(
            attempts: attempts.length > maxAttempts
                ? attempts.sublist(attempts.length - maxAttempts)
                : attempts,
          ),
        );
      });

  Future<void> toggleFavoriteVerb(String infinitive) => _enqueue(() async {
        final value = infinitive.trim();
        if (value.isEmpty || value.length > 120) return;
        final s = load();
        final f = {...s.favoriteVerbs};
        if (f.contains(value))
          f.remove(value);
        else if (f.length < maxCollectionItems) f.add(value);
        await persistence.setFavoriteMembership(value, f.contains(value));
        await _saveNow(s.copyWith(favoriteVerbs: f));
      });

  Future<void> _saveNow(LearnerState s) async {
    final persisted = persistence.normalize(
      _withoutLegacyPairProgress(s),
    );
    await persistence.save(persisted);
    _cachedState = persisted;
  }

  /// Routes a review through the durable envelope journal.
  /// This wires ReviewTransactionEnvelope -> persistReviewEnvelope ->
  /// applyReviewAttemptOnce into the repository's write path.
  Future<void> persistReviewEnvelope({
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
  }) async {
    final authority = _requirePairProgressAuthority();
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: reviewEventId,
      learnerContentKey: learnerContentKey,
      rating: rating,
      timestamp: timestamp,
      languagePairKey: languagePairKey,
    );
    await authority.engine.persistReviewEnvelope(
      pair: pair,
      reviewEventId: envelope.reviewEventId,
      cardId: envelope.learnerContentKey,
      rating: envelope.rating,
      reviewedAt: envelope.timestamp,
      correct: correct,
      hinted: hinted,
      achievementDelta: achievementDelta,
      requestedXp: requestedXp,
    );
    await authority.engine.applyReviewAttemptOnce(envelope);
  }

  Future<void> _recordGamificationReview(
    Attempt attempt, {
    required int requestedXp,
  }) async {
    try {
      await gamificationReviewSink.recordReview(
        GamificationReviewEvent(
          reviewId: attempt.id,
          facetType: attempt.facetType,
          correct: attempt.correct,
          hinted: attempt.hinted,
          requestedXp: requestedXp,
          occurredAtUtc: attempt.at.toUtc(),
          timezoneOffsetMinutes: attempt.at.timeZoneOffset.inMinutes,
        ),
      );
    } on Object {
      // Gamification is secondary to learning-state durability.
      // A local SQLite failure must never roll back a verified SRS review.
    }
  }

  Future<void> _recordDiagnosticFailure({
    required LearningContent item,
    required String answer,
    required DateTime at,
  }) async {
    try {
      await errorDiagnosticSink.recordFailure(
        LearningFailureSignal(
          source: ErrorEventSource.flashcard,
          skillTag: item.skill,
          expected: item.grammaticalMarker.trim().isNotEmpty
              ? item.grammaticalMarker
              : item.sourceText,
          actual: answer,
          focus: item.sourceText,
          occurredAt: at,
        ),
      );
    } on Object {
      // Diagnostic telemetry is secondary to durable learner progress.
    }
  }

  Future<void> record({
    required LearningContent item,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
    String? skillOverride,
    DateTime? at,
  }) =>
      _enqueue(() async {
        final authority = _requirePairProgressAuthority();
        final state = load();
        final now = at ?? DateTime.now();
        final attempt = Attempt(
          id: 'a_${now.microsecondsSinceEpoch}',
          itemId: item.id,
          skill: skillOverride ?? item.skill,
          answer: answer.length > 1000
              ? answer.substring(0, 1000)
              : answer,
          correct: correct,
          hinted: hinted,
          seconds: seconds.clamp(0, 3600),
          at: now,
        );
        final attempts = <Attempt>[...state.attempts, attempt];
        final bounded = attempts.length > maxAttempts
            ? attempts.sublist(attempts.length - maxAttempts)
            : attempts;
        await persistence.applyReviewAttemptOnce(attempt);
        final xpReward = unifiedSrsScheduler.xpRewardForReview(
          correct: correct,
          hinted: hinted,
        );
        final pairSnapshot =
            await authority.engine.loadPair(authority.pair);
        final currentCard =
            await authority.engine.loadReviewCard(
                  authority.pair,
                  conceptId: item.id,
                ) ??
                ReviewCard(
                  itemId: item.id,
                  dueAt: now,
                );
        final updatedCard =
            await unifiedSrsScheduler.schedule(
          currentCard,
          correct: correct,
          hinted: hinted,
          now: now,
        );
        final envelope = ReviewTransactionEnvelope(
          reviewEventId: attempt.id,
          learnerContentKey: item.id,
          rating: correct ? 2 : 0,
          timestamp: now,
          languagePairKey: pair.uniqueKey,
        );
        await persistReviewEnvelope(
          pair: authority.pair,
          reviewEventId: envelope.reviewEventId,
          cardId: envelope.learnerContentKey,
          rating: envelope.rating,
          timestamp: envelope.timestamp,
          languagePairKey: envelope.languagePairKey,
          learnerContentKey: envelope.learnerContentKey,
          correct: correct,
          hinted: false,
          achievedLevel: pairSnapshot.level,
          achievementDelta: xpReward,
          requestedXp: xpReward,
        );

        await _saveNow(
          state.copyWith(
            attempts: bounded,
          ),
        );
        await _recordGamificationReview(
          attempt,
          requestedXp: xpReward,
        );
        if (!correct) {
          await _recordDiagnosticFailure(
            item: item,
            answer: answer,
            at: now,
          );
        }
      });

  Future<void> recordConversationAttempt({
    required String itemId,
    required String skill,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
  }) =>
      _enqueue(() async {
        final s = load();
        final now = DateTime.now();
        final safeId = itemId.trim();
        if (safeId.isEmpty || safeId.length > 160) return;
        final attempt = Attempt(
          id: 'c_${now.microsecondsSinceEpoch}',
          itemId: safeId,
          skill: skill.trim().isEmpty ? 'production' : skill.trim(),
          answer: answer.length > 1000 ? answer.substring(0, 1000) : answer,
          correct: correct,
          hinted: hinted,
          seconds: seconds.clamp(0, 3600).toInt(),
          at: now,
        );
        final bounded = [...s.attempts, attempt];
        final kept = bounded.length > maxAttempts
            ? bounded.sublist(bounded.length - maxAttempts)
            : bounded;
        await persistence.applyReviewAttemptOnce(attempt);
        final authority = _requirePairProgressAuthority();
        await persistReviewDeliveryEnvelope(
          pair: authority.pair,
          reviewEventId: attempt.id,
          cardId: safeId,
          rating: correct ? 2 : 0,
          timestamp: now,
          languagePairKey: authority.pair.uniqueKey,
          learnerContentKey: safeId,
          correct: correct,
          hinted: hinted,
          achievedLevel: 0,
          achievementDelta: correct ? 10 : 2,
          requestedXp: correct ? 10 : 2,
          kind: 'conversation',
          facetType: ReviewFacetType.production,
        );
        await _saveNow(
          s.copyWith(
            attempts: kept,
          ),
        );
      });
}

extension FacetReviewRepository on LearnerRepository {
  Future<void> recordFacet({
    required LearningContent item,
    required ReviewFacetType facetType,
    String? variantKey,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
    DateTime? at,
  }) {
    final key = ReviewFacetKey(
      conceptId: item.id,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) return Future<void>.value();

    if (key.isLegacyMeaningKey) {
      return record(
        item: item,
        answer: answer,
        correct: correct,
        seconds: seconds,
        hinted: hinted,
        at: at,
      );
    }

    return _enqueue(() async {
      final authority = _requirePairProgressAuthority();
      final state = load();
      final now = at ?? DateTime.now();
      final safeAnswer = answer.length > 1000
          ? answer.substring(0, 1000)
          : answer;
      final attempt = Attempt(
        id: 'f_${now.microsecondsSinceEpoch}',
        itemId: item.id,
        skill: item.skill,
        answer: safeAnswer,
        correct: correct,
        hinted: hinted,
        seconds: seconds.clamp(0, 3600),
        at: now,
        facetType: facetType,
        variantKey: key.normalizedVariantKey,
      );
      final attempts = <Attempt>[...state.attempts, attempt];
      final bounded =
          attempts.length > LearnerRepository.maxAttempts
              ? attempts.sublist(
                  attempts.length - LearnerRepository.maxAttempts,
                )
              : attempts;
      await persistence.applyReviewAttemptOnce(attempt);
      final xpReward = unifiedSrsScheduler.xpRewardForReview(
        correct: correct,
        hinted: hinted,
      );
      final pairSnapshot =
          await authority.engine.loadPair(authority.pair);
      final currentCard =
          await authority.engine.loadReviewCard(
                authority.pair,
                conceptId: item.id,
                facetType: facetType,
                variantKey: key.normalizedVariantKey,
              ) ??
              ReviewCard(
                itemId: item.id,
                facetType: facetType,
                variantKey: key.normalizedVariantKey,
                dueAt: now,
              );
      final updatedCard =
          await unifiedSrsScheduler.schedule(
        currentCard,
        correct: correct,
        hinted: hinted,
        now: now,
      );
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: attempt.id,
        learnerContentKey: item.id,
        rating: correct ? 2 : 0,
        timestamp: now,
        languagePairKey: pair.uniqueKey,
      );
      await persistReviewEnvelope(
        pair: authority.pair,
        reviewEventId: envelope.reviewEventId,
        cardId: envelope.learnerContentKey,
        rating: envelope.rating,
        timestamp: envelope.timestamp,
        languagePairKey: envelope.languagePairKey,
        learnerContentKey: envelope.learnerContentKey,
        correct: correct,
        hinted: false,
        achievedLevel: pairSnapshot.level,
        achievementDelta: xpReward,
        requestedXp: xpReward,
      );

      await _saveNow(
        state.copyWith(
          xp: (state.xp + xpReward)
              .clamp(0, LearnerRepository.maxXp),
          attempts: bounded,
        ),
      );
      await _recordGamificationReview(
        attempt,
        requestedXp: xpReward,
      );
      if (!correct) {
        await _recordDiagnosticFailure(
          item: item,
          answer: answer,
          at: now,
        );
      }
    });
  }
}

final class _PairProgressAuthority {
  const _PairProgressAuthority({
    required this.engine,
    required this.pair,
  });

  final OfflinePairProgressEngine engine;
  final ResolvedLanguagePair pair;
}

extension PlacementDiagnosticRepository on LearnerRepository {
  Future<void> recordPlacementDiagnostic(PlacementDiagnosticRecord record) =>
      _enqueue(() async {
        final state = load();
        final history = <PlacementDiagnosticRecord>[
          record,
          ...state.placementHistory.where(
            (existing) => existing.id != record.id,
          ),
        ].take(20).toList(growable: false);
        await persistence.recordPlacementOnce(record);
        await _saveNow(state.copyWith(placementHistory: history));
      });
}

extension LearnerGamificationContract on LearnerRepository {
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
    required ReviewFacetType facetType,
    required String kind,
  }) async {
    final authority = _requirePairProgressAuthority();
    await authority.engine.persistReviewDeliveryEnvelope(
      pair: pair,
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

  Future<GamificationSnapshot> loadGamificationSnapshot() async {
    final sink = gamificationReviewSink;
    if (sink is GamificationRepository) {
      return sink.loadSnapshot();
    }
    return const GamificationSnapshot(
      profile: GamificationProfile(),
      unlocked: <UnlockedMilestone>[],
      badges: GamificationMilestones.defaults,
    );
  }
}
