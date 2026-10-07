import '../core/content_contract.dart';
import 'preferences_service.dart';
import 'learner_persistence.dart';
import '../models/learner.dart';
import '../core/srs_facets.dart';
import '../core/srs_scheduler.dart';
import '../core/models/language_catalog_models.dart';
import '../core/progress/offline_pair_progress_engine.dart';
import '../core/progress/pair_progress_models.dart';
import '../core/progress/review_transaction_envelope.dart';
import '../models/assessment.dart';
import '../models/diagnostic_placement.dart';
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
  static const maxXp = LearnerPersistence.maxXp;
  Future<void> _writeQueue = Future<void>.value();
  LearnerState? _cachedState;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.then<void>((_) {}).catchError((_) {});
    return next;
  }


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

  Future<GamificationSnapshot> loadGamificationSnapshot() {
    final sink = gamificationReviewSink;
    if (sink is GamificationRepository) {
      return sink.loadSnapshot();
    }
    return Future<GamificationSnapshot>.value(
      const GamificationSnapshot(
        profile: GamificationProfile(),
        unlocked: <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      ),
    );
  }

  bool get hasPairProgressAuthority =>
      _pairProgressEngine != null && _activeResolvedPair != null;

  OfflinePairProgressEngine get boundPairProgressEngine =>
      _requirePairProgressAuthority().engine;

  Future<void> bindPairProgressAuthority({
    required OfflinePairProgressEngine engine,
    required ResolvedLanguagePair pair,
    bool migrateLegacy = false,
    int migratedAchievementPoints = 0,
  }) =>
      _enqueue(() async {
        if (migratedAchievementPoints < 0 ||
            migratedAchievementPoints > LearnerRepository.maxXp) {
          throw ArgumentError.value(
            migratedAchievementPoints,
            'migratedAchievementPoints',
            'must be 0..${LearnerRepository.maxXp}',
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
        _cachedState = persistence.load();
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
        final persisted = await persistence.recordAssessmentOnce(
          AssessmentHistory(
            id: result.id,
            at: result.at,
            score: result.score,
            weakSkills: result.weakSkills,
            answered: result.answered,
          ),
        );
        _cachedState = persisted;
      });

  Future<void> recordWritingMistake({required String issue, DateTime? at}) =>
      _enqueue(() async {
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
        final result = await persistence.applyReviewAttemptOnce(
          reviewEventId: attempt.id,
          attempt: attempt,
        );
        _cachedState = result.state;
      });

  Future<void> toggleFavoriteVerb(String infinitive) => _enqueue(() async {
        final value = infinitive.trim();
        if (value.isEmpty || value.length > 120) return;
        final current = load();
        final shouldFavorite = !current.favoriteVerbs.contains(value);
        final persisted = await persistence.setFavoriteMembership(
          value,
          isFavorite: shouldFavorite,
        );
        _cachedState = persisted;
      });

  Future<void> _saveNow(LearnerState s) async {
    final persisted = persistence.normalize(
      _withoutLegacyPairProgress(s),
    );
    await persistence.save(persisted);
    _cachedState = persistence.load();
  }

  Future<void> _reconcileAcceptedReviewBestEffort({
    required _PairProgressAuthority authority,
    required ReviewTransactionEnvelope envelope,
    required String payloadHash,
  }) async {
    try {
      final result = await persistence.applyReviewAttemptOnce(
        reviewEventId: envelope.reviewEventId,
        attempt: Attempt(
          id: envelope.reviewEventId,
          itemId: envelope.conceptId,
          skill: envelope.skill,
          answer: envelope.answer,
          correct: envelope.correct,
          hinted: envelope.hinted,
          seconds: envelope.seconds,
          at: envelope.occurredAtUtc,
          facetType: envelope.facetType,
          variantKey: envelope.variantKey,
        ),
      );
      _cachedState = result.state;
      await authority.engine.acknowledgeReviewTransaction(
        reviewEventId: envelope.reviewEventId,
        payloadHash: payloadHash,
        sink: ReviewTransactionSink.attempt,
      );
    } on Object {
      // The PairProgress transaction is already the durable acceptance point.
      // Leave the attempt stage pending for bounded reconciliation.
    }

    if (gamificationReviewSink is NoopGamificationReviewSink) {
      return;
    }
    try {
      await gamificationReviewSink.recordReview(
        GamificationReviewEvent(
          reviewId: envelope.reviewEventId,
          facetType: envelope.facetType,
          correct: envelope.correct,
          hinted: envelope.hinted,
          requestedXp: envelope.requestedXp,
          occurredAtUtc: envelope.occurredAtUtc,
          timezoneOffsetMinutes: envelope.timezoneOffsetMinutes,
        ),
      );
      await authority.engine.acknowledgeReviewTransaction(
        reviewEventId: envelope.reviewEventId,
        payloadHash: payloadHash,
        sink: ReviewTransactionSink.gamification,
      );
    } on Object {
      // Keep the accepted event pending. Replay is idempotent at the sink.
    }
  }

  static String _reviewEventId({
    required String kind,
    required DateTime occurredAt,
    String? supplied,
  }) {
    final explicit = supplied?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return ReviewTransactionEnvelope.generateReviewEventId(
      kind: kind,
      occurredAt: occurredAt,
    );
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
    String? reviewEventId,
  }) =>
      _enqueue(() async {
        final authority = _requirePairProgressAuthority();
        final now = at ?? DateTime.now();
        final safeAnswer = answer.length > 1000
            ? answer.substring(0, 1000)
            : answer;
        final safeSeconds = seconds.clamp(0, 3600).toInt();
        final xpReward = unifiedSrsScheduler.xpRewardForReview(
          correct: correct,
          hinted: hinted,
        );
        final stableReviewEventId = LearnerRepository._reviewEventId(
          kind: 'meaning',
          occurredAt: now,
          supplied: reviewEventId,
        );
        final envelope = ReviewTransactionEnvelope(
          reviewEventId: stableReviewEventId,
          sourceLanguageId: authority.pair.source.id,
          targetLanguageId: authority.pair.target.id,
          conceptId: item.id,
          skill: skillOverride ?? item.skill,
          answer: safeAnswer,
          correct: correct,
          hinted: hinted,
          seconds: safeSeconds,
          occurredAt: now,
          timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
          requestedXp: xpReward,
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
        final acceptance = await authority.engine.persistReviewEnvelope(
          pair: authority.pair,
          envelope: envelope,
          reviewCard: updatedCard,
          learned: correct,
          level: pairSnapshot.level,
        );

        await _reconcileAcceptedReviewBestEffort(
          authority: authority,
          envelope: envelope,
          payloadHash: acceptance.payloadHash,
        );
        if (!acceptance.alreadyAccepted && !correct) {
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
    DateTime? at,
    String? reviewEventId,
  }) =>
      _enqueue(() async {
        final authority = _requirePairProgressAuthority();
        final now = at ?? DateTime.now();
        final safeId = itemId.trim();
        if (safeId.isEmpty || safeId.length > 160) return;
        final safeSkill =
            skill.trim().isEmpty ? 'production' : skill.trim();
        final safeAnswer =
            answer.length > 1000 ? answer.substring(0, 1000) : answer;
        final safeSeconds = seconds.clamp(0, 3600).toInt();
        final stableReviewEventId = LearnerRepository._reviewEventId(
          kind: 'conversation',
          occurredAt: now,
          supplied: reviewEventId,
        );
        final envelope = ReviewTransactionEnvelope(
          reviewEventId: stableReviewEventId,
          sourceLanguageId: authority.pair.source.id,
          targetLanguageId: authority.pair.target.id,
          conceptId: safeId,
          facetType: ReviewFacetType.production,
          skill: safeSkill,
          answer: safeAnswer,
          correct: correct,
          hinted: hinted,
          seconds: safeSeconds,
          occurredAt: now,
          timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
          requestedXp: correct ? 10 : 2,
        );
        final acceptance =
            await authority.engine.persistReviewDeliveryEnvelope(
          pair: authority.pair,
          envelope: envelope,
        );
        await _reconcileAcceptedReviewBestEffort(
          authority: authority,
          envelope: envelope,
          payloadHash: acceptance.payloadHash,
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
    String? reviewEventId,
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
        reviewEventId: reviewEventId,
      );
    }

    return _enqueue(() async {
      final authority = _requirePairProgressAuthority();
      final now = at ?? DateTime.now();
      final safeAnswer = answer.length > 1000
          ? answer.substring(0, 1000)
          : answer;
      final safeSeconds = seconds.clamp(0, 3600).toInt();
      final xpReward = unifiedSrsScheduler.xpRewardForReview(
        correct: correct,
        hinted: hinted,
      );
      final stableReviewEventId = LearnerRepository._reviewEventId(
        kind: 'facet',
        occurredAt: now,
        supplied: reviewEventId,
      );
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: stableReviewEventId,
        sourceLanguageId: authority.pair.source.id,
        targetLanguageId: authority.pair.target.id,
        conceptId: item.id,
        facetType: facetType,
        variantKey: key.normalizedVariantKey,
        skill: item.skill,
        answer: safeAnswer,
        correct: correct,
        hinted: hinted,
        seconds: safeSeconds,
        occurredAt: now,
        timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
        requestedXp: xpReward,
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
      final acceptance = await authority.engine.persistReviewEnvelope(
        pair: authority.pair,
        envelope: envelope,
        reviewCard: updatedCard,
        learned: correct,
        level: pairSnapshot.level,
      );

      await _reconcileAcceptedReviewBestEffort(
        authority: authority,
        envelope: envelope,
        payloadHash: acceptance.payloadHash,
      );
      if (!acceptance.alreadyAccepted && !correct) {
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
        final persisted = await persistence.recordPlacementOnce(record);
        _cachedState = persisted;
      });
}
