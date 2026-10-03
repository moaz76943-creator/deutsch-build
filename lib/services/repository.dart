import '../core/content_contract.dart';
import 'preferences_service.dart';
import 'learner_persistence.dart';
import '../models/learner.dart';
import '../core/srs_facets.dart';
import '../core/srs_scheduler.dart';
import '../models/assessment.dart';
import '../models/diagnostic_placement.dart';
import '../core/date_utils.dart';
import '../features/gamification/domain/gamification_models.dart';
import '../features/gamification/domain/gamification_review_sink.dart';

/// Local learner-state storage. This app deliberately has no network trust boundary.
/// Persisted values are treated as untrusted input and are bounded before use.
class LearnerRepository {
  final PreferencesService prefs;
  LearnerRepository(
    this.prefs, {
    required this.persistence,
    this.gamificationReviewSink = const NoopGamificationReviewSink(),
  });

  final LearnerPersistence persistence;
  final GamificationReviewSink gamificationReviewSink;
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

  Future<void> save(LearnerState s) => _enqueue(() async {
        final persisted = persistence.normalize(s);
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
        await _saveNow(s.copyWith(favoriteVerbs: f));
      });

  Future<void> _saveNow(LearnerState s) async {
    final persisted = persistence.normalize(s);
    await persistence.save(persisted);
    _cachedState = persisted;
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
        final s = load();
        final now = at ?? DateTime.now();
        final attempt = Attempt(
          id: 'a_${now.microsecondsSinceEpoch}',
          itemId: item.id,
          skill: skillOverride ?? item.skill,
          answer: answer.length > 1000 ? answer.substring(0, 1000) : answer,
          correct: correct,
          hinted: hinted,
          seconds: seconds.clamp(0, 3600),
          at: now,
        );
        final a = [...s.attempts, attempt];
        final bounded =
            a.length > maxAttempts ? a.sublist(a.length - maxAttempts) : a;
        final review = {...s.review};
        final cards = {...s.reviewCards};
        final currentCard =
            cards[item.id] ?? ReviewCard(itemId: item.id, dueAt: now);
        final updatedCard = unifiedSrsScheduler.schedule(
          currentCard,
          correct: correct,
          hinted: hinted,
          now: now,
        );
        cards[item.id] = updatedCard;
        if (correct && updatedCard.repetitions >= 2)
          review.remove(item.id);
        else
          review.add(item.id);
        final learned = {...s.learned};
        if (correct) learned.add(item.id);
        final last = s.attempts.isEmpty ? null : s.attempts.last.at;
        final today = now.toUtcMidnight;
        final sameDay = last != null && last.toUtcMidnight == today;
        final yesterday =
            last != null && today.difference(last.toUtcMidnight).inDays == 1;
        final nextStreak = s.attempts.isEmpty
            ? 1
            : (sameDay ? s.streak : (yesterday ? s.streak + 1 : 1));
        final xpReward = unifiedSrsScheduler.xpRewardForReview(
          correct: correct,
          hinted: hinted,
        );
        await _saveNow(
          s.copyWith(
            xp: (s.xp + xpReward).clamp(0, maxXp),
            streak: nextStreak.clamp(0, maxStreak),
            learned: learned,
            review: review,
            reviewCards: cards,
            attempts: bounded,
          ),
        );
        await _recordGamificationReview(attempt, requestedXp: xpReward);
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
        await _saveNow(
          s.copyWith(
            xp: (s.xp + (correct ? 10 : 2)).clamp(0, maxXp),
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
      final state = load();
      final now = at ?? DateTime.now();
      final safeAnswer =
          answer.length > 1000 ? answer.substring(0, 1000) : answer;
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
      final bounded = attempts.length > LearnerRepository.maxAttempts
          ? attempts.sublist(attempts.length - LearnerRepository.maxAttempts)
          : attempts;

      final cards = <String, ReviewCard>{...state.reviewCards};
      final current = cards[key.storageKey] ??
          ReviewCard(
            itemId: item.id,
            facetType: facetType,
            variantKey: key.normalizedVariantKey,
            dueAt: now,
          );
      cards[key.storageKey] = unifiedSrsScheduler.schedule(
        current,
        correct: correct,
        hinted: hinted,
        now: now,
      );

      final xpReward = unifiedSrsScheduler.xpRewardForReview(
        correct: correct,
        hinted: hinted,
      );
      await _saveNow(
        state.copyWith(
          xp: (state.xp + xpReward).clamp(0, LearnerRepository.maxXp),
          reviewCards: cards,
          attempts: bounded,
        ),
      );
      await _recordGamificationReview(attempt, requestedXp: xpReward);
    });
  }
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
        await _saveNow(state.copyWith(placementHistory: history));
      });
}
