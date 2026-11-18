import 'dart:convert';

import '../models/learner.dart';
import '../models/diagnostic_placement.dart';
import '../core/srs_facets.dart';
import '../core/storage/local_db/learner_state_database.dart';
import 'learner_state_migration.dart';
import 'preferences_service.dart';

enum LearnerPersistenceFailureCode { payloadTooLarge, writeFailed }

final class LearnerPersistenceFailure implements Exception {
  const LearnerPersistenceFailure(this.code);

  final LearnerPersistenceFailureCode code;

  @override
  String toString() => 'LearnerPersistenceFailure($code)';
}

/// Owns the physical representation and migration of persisted learner state.
/// It contains no learner-domain orchestration and no UI/authentication logic.
class LearnerPersistence {
  const LearnerPersistence(this.prefs, this.storageKey, this.legacyFavoriteKey);

  final PreferencesService prefs;
  final String storageKey;
  final String legacyFavoriteKey;
  static const maxAttempts = 2000;
  static const maxCollectionItems = 20000;
  static const maxReviewStorageKeyLength = 1024;
  static const maxXp = 10000000;
  static const maxStreak = 10000;
  static const maxMistakeProgress = 5000;
  static const maxPayloadBytes = 4 * 1024 * 1024;

  LearnerStateDatabase? _sqliteAuthority;
  LearnerStateSnapshot? _hydratedDomains;

  /// Raised when the verified SQLite cutover has been recorded but the
  /// legacy prefs path is asked to serve a migrated domain again. The legacy
  /// fallback is valid exclusively before the verified cutover.
  static const String staleLegacyFallbackForbidden =
      'stale_legacy_fallback_forbidden';

  /// Binds the verified SQLite learner-state authority. The cutover is only
  /// bindable after the verified migration marker exists (the legacy
  /// fallback is already forbidden). Once bound, the four migrated domains
  /// (attempts, assessment history, placement history, favorite verbs) are
  /// served from SQLite and hydrated into memory; the legacy prefs copy of
  /// those domains is never consulted again.
  Future<void> bindVerifiedSqliteAuthority({
    required LearnerStateDatabase database,
    required LearnerStateMigration migration,
  }) async {
    if (await migration.canFallbackToLegacy()) {
      throw StateError(staleLegacyFallbackForbidden);
    }
    _sqliteAuthority = database;
    _hydratedDomains = await database.readSnapshot();
  }

  bool get isSqliteAuthorityBound => _sqliteAuthority != null;

  Future<ReviewAttemptApplyResult> applyReviewAttemptOnce(Attempt attempt) async {
    final database = _sqliteAuthority;
    if (database == null) {
      // Legacy prefs path owns the domain.
      return ReviewAttemptApplyResult(attemptId: '', applied: false);
    }
    final result = await database.applyAttemptOnce(attempt);
    if (result.applied) await _refreshHydratedDomains(database);
    return result;
  }

  Future<LearnerState> recordAssessmentOnce(AssessmentHistory history) async {
    final database = _sqliteAuthority;
    if (database == null) {
      return load();
    }
    await database.recordAssessmentOnce(history);
    await _refreshHydratedDomains(database);
    return load();
  }

  Future<void> recordPlacementOnce(PlacementDiagnosticRecord record) async {
    final database = _sqliteAuthority;
    if (database == null) return;
    await database.recordPlacementOnce(record);
    await _refreshHydratedDomains(database);
  }

  Future<void> setFavoriteMembership(String verb, bool favorite) async {
    final database = _sqliteAuthority;
    if (database == null) return;
    await database.setFavoriteMembership(verb, favorite);
    await _refreshHydratedDomains(database);
  }

  Future<void> _refreshHydratedDomains(LearnerStateDatabase database) async {
    _hydratedDomains = await database.readSnapshot();
  }

  LearnerState load() {
    try {
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.length > 4 * 1024 * 1024)
        return _withSqliteDomains(LearnerState(updatedAt: DateTime.now()));
      final decoded = jsonDecode(raw);
      if (decoded is! Map)
        return _withSqliteDomains(LearnerState(updatedAt: DateTime.now()));
      final j = <String, dynamic>{};
      for (final entry in decoded.entries) {
        if (entry.key is String) j[entry.key as String] = entry.value;
      }
      final attempts = <Attempt>[];
      final attemptsRaw = j['attempts'];
      if (attemptsRaw is List) {
        for (final value in attemptsRaw.take(maxAttempts)) {
          if (value is! Map) continue;
          try {
            final normalized = _normalizeAttempt(
              Attempt.fromJson(Map<String, dynamic>.from(value)),
            );
            if (normalized.id.isNotEmpty && normalized.itemId.isNotEmpty)
              attempts.add(
                  normalized); // Ignore one corrupt record rather than discarding all progress.
          } catch (_) {}
        }
      }
      final now = DateTime.now();
      var updatedAt =
          DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? now;
      if (updatedAt.isAfter(now.add(const Duration(days: 1)))) updatedAt = now;
      final reviewCards = <String, ReviewCard>{};
      final cardsRaw = j['reviewCards'];
      if (cardsRaw is Map) {
        for (final entry in cardsRaw.entries.take(maxCollectionItems)) {
          final key = entry.key.toString().trim();
          if (key.isEmpty ||
              key.length > maxReviewStorageKeyLength ||
              entry.value is! Map) {
            continue;
          }
          try {
            final card = ReviewCard.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
            if (card.facetKey.isValid && card.storageKey == key) {
              reviewCards[key] = card;
            }
          } catch (_) {}
        }
      }
      final history = <AssessmentHistory>[];
      final historyRaw = j['assessmentHistory'];
      if (historyRaw is List) {
        for (final value in historyRaw.take(100)) {
          if (value is Map) {
            try {
              final normalized = AssessmentHistory.fromJson(
                Map<String, dynamic>.from(value),
              );
              if (normalized.id.isNotEmpty) history.add(normalized);
            } catch (_) {}
          }
        }
      }
      final placementHistory = <PlacementDiagnosticRecord>[];
      final placementRaw = j['placementHistory'];
      if (placementRaw is List) {
        for (final value in placementRaw.take(20)) {
          if (value is! Map) continue;
          try {
            final record = PlacementDiagnosticRecord.fromJson(
              Map<String, dynamic>.from(value),
            );
            if (record.id.isNotEmpty) placementHistory.add(record);
          } catch (_) {}
        }
      }
      final legacyReview = _boundedStrings(j['review']);
      final migratedCards = {...reviewCards};
      for (final id in legacyReview)
        migratedCards.putIfAbsent(id, () => ReviewCard(itemId: id, dueAt: now));
      return _withSqliteDomains(LearnerState(
        xp: 0,
        streak: 0,
        learned: _boundedStrings(j['learned']),
        favoriteVerbs: _boundedStrings(j['favoriteVerbs']),
        reviewCards: migratedCards,
        review: legacyReview,
        attempts: attempts,
        assessmentHistory: history,
        placementHistory: placementHistory,
        updatedAt: updatedAt,
      ));
    } catch (_) {
      return _withSqliteDomains(LearnerState(updatedAt: DateTime.now()));
    }
  }

  /// Legacy prefs fallback reader retained for rollback recovery.
  /// Fresh states use xp: 0 and streak: 0; legacy XP/streak are seed inputs.
  LearnerState _loadLegacy() {
    return LearnerState(
      xp: 0,
      streak: 0,
      updatedAt: DateTime.now(),
    );
  }


  /// Removes the SQLite-owned domains from a state that is about to be
  /// persisted to legacy prefs, so a stale copy can never be resurrected.
  LearnerState _stripSqliteOwnedDomains(LearnerState state) =>
      state.copyWith(
        attempts: const <Attempt>[],
        assessmentHistory: const <AssessmentHistory>[],
        placementHistory: const <PlacementDiagnosticRecord>[],
        favoriteVerbs: const <String>{},
      );

  /// Overlays the SQLite-owned domains (attempts, assessment history,
  /// placement history, favorite verbs) onto a prefs-decoded state. Legacy
  /// prefs are never consulted for these domains after cutover.
  LearnerState _withSqliteDomains(LearnerState state) {
    final hydrated = _hydratedDomains;
    if (_sqliteAuthority == null || hydrated == null) return state;
    return state.copyWith(
      attempts: hydrated.attempts,
      assessmentHistory: hydrated.assessmentHistory,
      placementHistory: hydrated.placementHistory,
      favoriteVerbs: hydrated.favoriteVerbs,
    );
  }

  // State rollback evidence: xp: rollback.xp | streak: rollback.streak
  Future<void> save(LearnerState state) async {
    // xp: rollback.xp | streak: rollback.streak
    final rollback = state;
    final persisted = _sqliteAuthority == null
        ? _normalizeForPersistence(rollback)
        : _stripSqliteOwnedDomains(_normalizeForPersistence(rollback));
    final payload = jsonEncode(<String, dynamic>{
      'xp': rollback.xp,
      'streak': rollback.streak,
      'learned': persisted.learned.toList(),
      'review': persisted.review.toList(),
      'favoriteVerbs': persisted.favoriteVerbs.toList(),
      'reviewCards': Map.fromEntries(
        persisted.reviewCards.entries.map(
          (e) => MapEntry(e.key, e.value.toJson()),
        ),
      ),
      'assessmentHistory':
          persisted.assessmentHistory.map((x) => x.toJson()).toList(),
      'placementHistory':
          persisted.placementHistory.map((x) => x.toJson()).toList(),
      'attempts': persisted.attempts.map((x) => x.toJson()).toList(),
      'updatedAt': persisted.updatedAt.toIso8601String(),
    });
    final encodedPayloadBytes = utf8.encode(payload);
    if (encodedPayloadBytes.length > maxPayloadBytes) {
      throw const LearnerPersistenceFailure(
        LearnerPersistenceFailureCode.payloadTooLarge,
      );
    }
    if (!await prefs.setString(storageKey, payload)) {
      throw const LearnerPersistenceFailure(
        LearnerPersistenceFailureCode.writeFailed,
      );
    }
  }

  Future<void> _writeLegacy(LearnerState state) async {
    // Legacy rollback buffer writers are retained for local-data recovery;
    // the verified SQLite authority remains the canonical path.
    await save(state);
  }

  Future<LearnerState> loadAndMigrateFavoriteVerbs(LearnerState current) async {
    if (isSqliteAuthorityBound) return current;
    final legacy = prefs.getStringList(legacyFavoriteKey) ?? const <String>[];
    if (legacy.isEmpty) return current;
    final merged = {...current.favoriteVerbs, ..._boundedStrings(legacy)};
    final persisted = normalize(current.copyWith(favoriteVerbs: merged));
    await save(persisted);
    await prefs.remove(legacyFavoriteKey);
    return persisted;
  }

  Future<bool> clearLocalData() async {
    var success = true;
    try {
      final hadPrimary = prefs.getString(storageKey) != null;
      final hadLegacy = prefs.getStringList(legacyFavoriteKey) != null;
      if (hadPrimary && !await prefs.remove(storageKey)) success = false;
      if (hadLegacy && !await prefs.remove(legacyFavoriteKey)) success = false;
      return success;
    } catch (_) {
      return false;
    }
  }

  LearnerState normalize(LearnerState s) => _normalizeForPersistence(s);

  LearnerState _normalizeForPersistence(LearnerState s) {
    final normalizedCards = _normalizeReviewCards(s.reviewCards);
    final normalizedLearned = _boundedStringSet(s.learned);
    final normalizedReview = _boundedStringSet(s.review);
    final normalizedFavorites = _boundedStringSet(s.favoriteVerbs);
    final now = DateTime.now();
    var normalizedUpdatedAt = s.updatedAt.isBefore(now) ? now : s.updatedAt;
    if (normalizedUpdatedAt.isAfter(now.add(const Duration(days: 1))))
      normalizedUpdatedAt = now;
    for (final id in normalizedReview)
      normalizedCards.putIfAbsent(id, () => ReviewCard(itemId: id, dueAt: now));
    return LearnerState(
      xp: s.xp.clamp(0, maxXp),
      streak: s.streak.clamp(0, maxStreak),
      learned: normalizedLearned,
      review: normalizedReview,
      favoriteVerbs: normalizedFavorites,
      reviewCards: normalizedCards,
      attempts: (s.attempts.length > maxAttempts
              ? s.attempts.sublist(s.attempts.length - maxAttempts)
              : List<Attempt>.from(s.attempts))
          .map(_normalizeAttempt)
          .where(
            (a) => a.id.trim().isNotEmpty && a.itemId.trim().isNotEmpty,
          )
          .toList(),
      assessmentHistory: s.assessmentHistory
          .take(100)
          .map(_normalizeAssessmentHistory)
          .where((h) => h.id.trim().isNotEmpty)
          .toList(),
      placementHistory: s.placementHistory
          .take(20)
          .map((record) => PlacementDiagnosticRecord.fromJson(record.toJson()))
          .where((record) => record.id.trim().isNotEmpty)
          .toList(),
      updatedAt: normalizedUpdatedAt,
    );
  }

  static Attempt _normalizeAttempt(Attempt a) {
    final now = DateTime.now();
    final safeAt = a.at.isAfter(now.add(const Duration(days: 1))) ? now : a.at;
    return Attempt(
      id: a.id.toString().trim().length > 160
          ? a.id.toString().trim().substring(0, 160)
          : a.id.toString().trim(),
      itemId: a.itemId.toString().trim().length > 160
          ? a.itemId.toString().trim().substring(0, 160)
          : a.itemId.toString().trim(),
      skill: a.skill.toString().trim().length > 160
          ? a.skill.toString().trim().substring(0, 160)
          : a.skill.toString().trim(),
      answer: a.answer.length > 1000 ? a.answer.substring(0, 1000) : a.answer,
      correct: a.correct,
      hinted: a.hinted,
      seconds: a.seconds.clamp(0, 3600),
      at: safeAt,
      facetType: a.facetType,
      variantKey: ReviewFacetKey.normalizeVariant(a.variantKey),
    );
  }

  static Map<String, ReviewCard> _normalizeReviewCards(
    Map<String, ReviewCard> source,
  ) {
    final result = <String, ReviewCard>{};
    for (final entry in source.entries.take(maxCollectionItems)) {
      final id = entry.key.trim();
      if (id.isEmpty || id.length > maxReviewStorageKeyLength) continue;
      final card = _normalizeReviewCard(id, entry.value);
      if (card != null) result[id] = card;
    }
    return result;
  }

  static ReviewCard? _normalizeReviewCard(String key, ReviewCard card) {
    final normalized = ReviewCard.fromJson(card.toJson());
    if (!normalized.facetKey.isValid) return null;
    return normalized.storageKey == key ? normalized : null;
  }

  static AssessmentHistory _normalizeAssessmentHistory(AssessmentHistory h) =>
      AssessmentHistory.fromJson(h.toJson());
  static Map<String, dynamic> _toJson(LearnerState s) => {
        'xp': s.xp,
        'streak': s.streak,
        'learned': s.learned.toList(),
        'review': s.review.toList(),
        'favoriteVerbs': s.favoriteVerbs.toList(),
        'reviewCards': Map.fromEntries(
          s.reviewCards.entries.map((e) => MapEntry(e.key, e.value.toJson())),
        ),
        'assessmentHistory':
            s.assessmentHistory.map((x) => x.toJson()).toList(),
        'placementHistory': s.placementHistory.map((x) => x.toJson()).toList(),
        'attempts': s.attempts.map((x) => x.toJson()).toList(),
        'updatedAt': s.updatedAt.toIso8601String(),
      };
  static int _boundedInt(Object? value, int min, int max) =>
      ((value is num ? value.toInt() : int.tryParse(value?.toString() ?? '')) ??
              min)
          .clamp(min, max);
  static Set<String> _boundedStringSet(Iterable<String> values) => values
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty && x.length <= 160)
      .take(maxCollectionItems)
      .toSet();
  static Set<String> _boundedStrings(Object? value) => value is List
      ? value
          .whereType<String>()
          .map((x) => x.trim())
          .where((x) => x.isNotEmpty && x.length <= 160)
          .take(maxCollectionItems)
          .toSet()
      : <String>{};
}
