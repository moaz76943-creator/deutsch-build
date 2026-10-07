import 'dart:convert';

import '../models/learner.dart';
import '../models/diagnostic_placement.dart';
import '../core/srs_facets.dart';
import '../core/storage/local_db/learner_state_database.dart';
import 'preferences_service.dart';
import 'legacy_learner_snapshot_reader.dart';

enum LearnerPersistenceFailureCode { payloadTooLarge, writeFailed }

final class LearnerPersistenceFailure implements Exception {
  const LearnerPersistenceFailure(this.code);

  final LearnerPersistenceFailureCode code;

  @override
  String toString() => 'LearnerPersistenceFailure($code)';
}

enum ReviewAttemptApplyStatus {
  applied,
  alreadyApplied,
}

final class ReviewAttemptApplyResult {
  const ReviewAttemptApplyResult({
    required this.status,
    required this.state,
  });

  final ReviewAttemptApplyStatus status;
  final LearnerState state;

  bool get alreadyApplied =>
      status == ReviewAttemptApplyStatus.alreadyApplied;
}

final class ReviewAttemptApplyException implements Exception {
  const ReviewAttemptApplyException(this.code);

  final String code;

  @override
  String toString() => 'ReviewAttemptApplyException($code)';
}

final class LegacyGamificationSeed {
  const LegacyGamificationSeed({
    required this.xp,
    required this.streak,
  });

  final int xp;
  final int streak;
}

/// Owns the physical representation and migration of persisted learner state.
/// It contains no learner-domain orchestration and no UI/authentication logic.
class LearnerPersistence {
  LearnerPersistence(this.prefs, this.storageKey, this.legacyFavoriteKey);

  final PreferencesService prefs;
  final String storageKey;
  final String legacyFavoriteKey;

  LearnerStateDatabase? _sqliteDatabase;
  LearnerMigrationRecord? _cutoverRecord;
  LearnerSqliteSnapshot? _sqliteSnapshot;
  LearnerState? _legacyStateCache;
  bool _closed = false;
  static const maxAttempts = 2000;
  static const maxCollectionItems = 20000;
  static const maxReviewStorageKeyLength = 1024;
  static const maxXp = 10000000;
  static const maxStreak = 10000;
  static const maxMistakeProgress = 5000;
  static const maxPayloadBytes = 4 * 1024 * 1024;

  bool get hasVerifiedSqliteAuthority =>
      _sqliteDatabase != null &&
      _cutoverRecord != null &&
      _sqliteSnapshot != null;

  Future<void> bindVerifiedSqliteAuthority({
    required LearnerStateDatabase database,
    required LearnerMigrationRecord migrationRecord,
  }) async {
    if (_closed) {
      throw const LearnerPersistenceSqliteException(
        'learner_persistence_closed',
      );
    }

    final revision = await database.loadRevision();
    if (revision < migrationRecord.cutoverRevision) {
      throw const LearnerPersistenceSqliteException(
        'learner_store_revision_regressed',
      );
    }

    final snapshot = await database.readSnapshot();
    if (revision == migrationRecord.cutoverRevision) {
      final hash =
          await LegacyLearnerSnapshotReader.canonicalSnapshotSha256(
        snapshot,
      );
      if (hash != migrationRecord.importedSnapshotSha256 ||
          snapshot.attempts.length != migrationRecord.attemptCount ||
          snapshot.assessmentHistory.length !=
              migrationRecord.assessmentCount ||
          snapshot.placementHistory.length !=
              migrationRecord.placementCount ||
          snapshot.favoriteVerbs.length !=
              migrationRecord.favoriteCount) {
        throw const LearnerPersistenceSqliteException(
          'verified_learner_sqlite_snapshot_mismatch',
        );
      }
    }

    _sqliteDatabase = database;
    _cutoverRecord = migrationRecord;
    _sqliteSnapshot = snapshot;
    _legacyStateCache = _loadLegacy();
  }

  Future<bool> canUseLegacyRollbackBuffer() async {
    final database = _sqliteDatabase;
    final record = _cutoverRecord;
    if (database == null || record == null) return true;
    try {
      final revision = await database.loadRevision();
      return revision <= record.cutoverRevision;
    } on Object {
      return false;
    }
  }

  LegacyGamificationSeed loadLegacyGamificationSeed() {
    final legacy = _legacyStateCache ?? _loadLegacy();
    return LegacyGamificationSeed(
      xp: legacy.xp,
      streak: legacy.streak,
    );
  }

  LearnerState load() {
    final legacy = _legacyStateCache ?? _loadLegacy();
    final snapshot = _sqliteSnapshot;
    if (!hasVerifiedSqliteAuthority || snapshot == null) {
      return LearnerState(
        xp: 0,
        streak: 0,
        learned: legacy.learned,
        review: legacy.review,
        favoriteVerbs: legacy.favoriteVerbs,
        reviewCards: legacy.reviewCards,
        attempts: legacy.attempts,
        assessmentHistory: legacy.assessmentHistory,
        placementHistory: legacy.placementHistory,
        updatedAt: legacy.updatedAt,
      );
    }
    return LearnerState(
      xp: 0,
      streak: 0,
      learned: legacy.learned,
      review: legacy.review,
      favoriteVerbs: snapshot.favoriteVerbs,
      reviewCards: legacy.reviewCards,
      attempts: snapshot.attempts,
      assessmentHistory: snapshot.assessmentHistory,
      placementHistory: snapshot.placementHistory,
      updatedAt: legacy.updatedAt,
    );
  }

  LearnerState _loadLegacy() {
    try {
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.length > 4 * 1024 * 1024)
        return LearnerState(updatedAt: DateTime.now());
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return LearnerState(updatedAt: DateTime.now());
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
      return LearnerState(
        xp: _boundedInt(j['xp'], 0, maxXp),
        streak: _boundedInt(j['streak'], 0, maxStreak),
        learned: _boundedStrings(j['learned']),
        favoriteVerbs: _boundedStrings(j['favoriteVerbs']),
        reviewCards: migratedCards,
        review: legacyReview,
        attempts: attempts,
        assessmentHistory: history,
        placementHistory: placementHistory,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return LearnerState(updatedAt: DateTime.now());
    }
  }

  Future<void> save(LearnerState state) async {
    final normalized = normalize(state);
    final rollback = _legacyStateCache ?? _loadLegacy();

    if (!hasVerifiedSqliteAuthority) {
      final legacyOnly = LearnerState(
        xp: rollback.xp,
        streak: rollback.streak,
        learned: normalized.learned,
        review: normalized.review,
        favoriteVerbs: normalized.favoriteVerbs,
        reviewCards: normalized.reviewCards,
        attempts: normalized.attempts,
        assessmentHistory: normalized.assessmentHistory,
        placementHistory: normalized.placementHistory,
        updatedAt: normalized.updatedAt,
      );
      await _writeLegacy(legacyOnly);
      return;
    }

    final legacyOnly = LearnerState(
      xp: rollback.xp,
      streak: rollback.streak,
      learned: normalized.learned,
      review: normalized.review,
      favoriteVerbs: rollback.favoriteVerbs,
      reviewCards: normalized.reviewCards,
      attempts: rollback.attempts,
      assessmentHistory: rollback.assessmentHistory,
      placementHistory: rollback.placementHistory,
      updatedAt: normalized.updatedAt,
    );
    await _writeLegacy(legacyOnly);
    _legacyStateCache = legacyOnly;
  }

  Future<void> _writeLegacy(LearnerState state) async {
    final payload = jsonEncode(_toJson(state));
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
    if (hasVerifiedSqliteAuthority) {
      _legacyStateCache = state;
    }
  }

  Future<ReviewAttemptApplyResult> applyReviewAttemptOnce({
    required String reviewEventId,
    required Attempt attempt,
  }) async {
    final normalizedReviewEventId = reviewEventId.trim();
    if (normalizedReviewEventId.isEmpty ||
        normalizedReviewEventId.length > 160) {
      throw const ReviewAttemptApplyException(
        'invalid_review_event_id',
      );
    }
    if (attempt.id.trim() != normalizedReviewEventId) {
      throw const ReviewAttemptApplyException(
        'review_attempt_event_id_mismatch',
      );
    }

    final normalizedAttempt = _normalizeAttempt(attempt);
    if (normalizedAttempt.id != normalizedReviewEventId ||
        normalizedAttempt.itemId.isEmpty) {
      throw const ReviewAttemptApplyException(
        'invalid_review_attempt_identity',
      );
    }

    final database = _sqliteDatabase;
    if (hasVerifiedSqliteAuthority && database != null) {
      final result = await database.applyAttemptOnce(normalizedAttempt);
      if (!result.alreadyApplied) {
        await _refreshSqliteSnapshot();
      }
      return ReviewAttemptApplyResult(
        status: result.alreadyApplied
            ? ReviewAttemptApplyStatus.alreadyApplied
            : ReviewAttemptApplyStatus.applied,
        state: load(),
      );
    }

    final current = load();
    final existing = current.attempts
        .where((candidate) => candidate.id == normalizedReviewEventId)
        .toList(growable: false);
    if (existing.isNotEmpty) {
      final allMatch = existing.every(
        (candidate) => _attemptsEquivalent(
          _normalizeAttempt(candidate),
          normalizedAttempt,
        ),
      );
      if (!allMatch) {
        throw const ReviewAttemptApplyException(
          'review_attempt_payload_mismatch',
        );
      }
      return ReviewAttemptApplyResult(
        status: ReviewAttemptApplyStatus.alreadyApplied,
        state: current,
      );
    }

    final attempts = <Attempt>[
      ...current.attempts,
      normalizedAttempt,
    ];
    final boundedAttempts = attempts.length > maxAttempts
        ? attempts.sublist(attempts.length - maxAttempts)
        : attempts;
    final next = normalize(
      current.copyWith(attempts: boundedAttempts),
    );
    await save(next);
    return ReviewAttemptApplyResult(
      status: ReviewAttemptApplyStatus.applied,
      state: load(),
    );
  }

  Future<LearnerState> recordAssessmentOnce(
    AssessmentHistory assessment,
  ) async {
    final database = _sqliteDatabase;
    if (hasVerifiedSqliteAuthority && database != null) {
      final result = await database.recordAssessmentOnce(
        _normalizeAssessmentHistory(assessment),
      );
      if (!result.alreadyApplied) {
        await _refreshSqliteSnapshot();
      }
      return load();
    }

    final current = load();
    final existing = current.assessmentHistory
        .where((item) => item.id == assessment.id)
        .toList(growable: false);
    if (existing.isNotEmpty) {
      if (!existing.every(
        (item) => _assessmentsEquivalent(item, assessment),
      )) {
        throw const LearnerPersistenceSqliteException(
          'assessment_payload_mismatch',
        );
      }
      return current;
    }
    final history = <AssessmentHistory>[
      _normalizeAssessmentHistory(assessment),
      ...current.assessmentHistory,
    ].take(100).toList(growable: false);
    final next = normalize(
      current.copyWith(assessmentHistory: history),
    );
    await save(next);
    return next;
  }

  Future<LearnerState> recordPlacementOnce(
    PlacementDiagnosticRecord placement,
  ) async {
    final database = _sqliteDatabase;
    if (hasVerifiedSqliteAuthority && database != null) {
      final result = await database.recordPlacementOnce(placement);
      if (!result.alreadyApplied) {
        await _refreshSqliteSnapshot();
      }
      return load();
    }

    final current = load();
    final existing = current.placementHistory
        .where((item) => item.id == placement.id)
        .toList(growable: false);
    if (existing.isNotEmpty) {
      if (!existing.every(
        (item) => _placementsEquivalent(item, placement),
      )) {
        throw const LearnerPersistenceSqliteException(
          'placement_payload_mismatch',
        );
      }
      return current;
    }
    final history = <PlacementDiagnosticRecord>[
      placement,
      ...current.placementHistory,
    ].take(20).toList(growable: false);
    final next = normalize(
      current.copyWith(placementHistory: history),
    );
    await save(next);
    return next;
  }

  Future<LearnerState> setFavoriteMembership(
    String verb, {
    required bool isFavorite,
  }) async {
    final value = verb.trim();
    if (value.isEmpty || value.length > 160) {
      throw ArgumentError.value(
        verb,
        'verb',
        'must be 1..160 characters',
      );
    }

    final database = _sqliteDatabase;
    if (hasVerifiedSqliteAuthority && database != null) {
      final result = await database.setFavoriteMembership(
        verb: value,
        isFavorite: isFavorite,
      );
      if (!result.alreadyApplied) {
        await _refreshSqliteSnapshot();
      }
      return load();
    }

    final current = load();
    final favorites = <String>{...current.favoriteVerbs};
    if (isFavorite) {
      if (favorites.length >= maxCollectionItems &&
          !favorites.contains(value)) {
        throw const LearnerPersistenceSqliteException(
          'favorite_row_bound_exceeded',
        );
      }
      favorites.add(value);
    } else {
      favorites.remove(value);
    }
    final next = normalize(
      current.copyWith(favoriteVerbs: favorites),
    );
    await save(next);
    return next;
  }

  Future<void> _refreshSqliteSnapshot() async {
    final database = _sqliteDatabase;
    final record = _cutoverRecord;
    if (database == null || record == null) {
      throw const LearnerPersistenceSqliteException(
        'sqlite_authority_not_bound',
      );
    }
    try {
      _sqliteSnapshot = await database.readSnapshot();
    } on Object {
      final revision = await database.loadRevision();
      if (revision > record.cutoverRevision) {
        throw const LearnerPersistenceSqliteException(
          'stale_legacy_fallback_forbidden',
        );
      }
      rethrow;
    }
  }

  Future<LearnerState> loadAndMigrateFavoriteVerbs(
    LearnerState current,
  ) async {
    if (hasVerifiedSqliteAuthority) {
      return load();
    }
    final legacy = prefs.getStringList(legacyFavoriteKey) ?? const <String>[];
    if (legacy.isEmpty) return current;
    final merged = {...current.favoriteVerbs, ..._boundedStrings(legacy)};
    final persisted = normalize(current.copyWith(favoriteVerbs: merged));
    await save(persisted);
    return persisted;
  }

  Future<bool> clearLocalData() async {
    var success = true;
    try {
      final database = _sqliteDatabase;
      if (database != null) {
        await database.clearAuthoritativeStateForUserReset();
        await database.close();
        _sqliteDatabase = null;
        _cutoverRecord = null;
        _sqliteSnapshot = null;
        _legacyStateCache = null;
      }
      final hadPrimary = prefs.getString(storageKey) != null;
      final hadLegacy = prefs.getStringList(legacyFavoriteKey) != null;
      if (hadPrimary && !await prefs.remove(storageKey)) success = false;
      if (hadLegacy && !await prefs.remove(legacyFavoriteKey)) success = false;
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final database = _sqliteDatabase;
    _sqliteDatabase = null;
    _cutoverRecord = null;
    _sqliteSnapshot = null;
    if (database != null) {
      await database.close();
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

  static bool _attemptsEquivalent(Attempt left, Attempt right) =>
      left.id == right.id &&
      left.itemId == right.itemId &&
      left.skill == right.skill &&
      left.answer == right.answer &&
      left.correct == right.correct &&
      left.hinted == right.hinted &&
      left.seconds == right.seconds &&
      left.at.toUtc().microsecondsSinceEpoch ==
          right.at.toUtc().microsecondsSinceEpoch &&
      left.facetType == right.facetType &&
      ReviewFacetKey.normalizeVariant(left.variantKey) ==
          ReviewFacetKey.normalizeVariant(right.variantKey);

  static bool _assessmentsEquivalent(
    AssessmentHistory left,
    AssessmentHistory right,
  ) =>
      left.id == right.id &&
      left.at.toUtc().microsecondsSinceEpoch ==
          right.at.toUtc().microsecondsSinceEpoch &&
      left.score == right.score &&
      left.answered == right.answered &&
      _orderedStringsEqual(left.weakSkills, right.weakSkills);

  static bool _placementsEquivalent(
    PlacementDiagnosticRecord left,
    PlacementDiagnosticRecord right,
  ) {
    if (left.id != right.id ||
        left.at.toUtc().microsecondsSinceEpoch !=
            right.at.toUtc().microsecondsSinceEpoch ||
        left.answered != right.answered ||
        left.scoredAnswers != right.scoredAnswers ||
        left.score != right.score ||
        left.confidence != right.confidence ||
        left.band != right.band ||
        left.curriculumStartLevel != right.curriculumStartLevel ||
        left.recommendedStartTaskOrder !=
            right.recommendedStartTaskOrder ||
        left.learningGoal != right.learningGoal ||
        !_orderedStringsEqual(left.reviewItemIds, right.reviewItemIds) ||
        left.weakDimensions.length != right.weakDimensions.length ||
        left.dimensionScores.length != right.dimensionScores.length) {
      return false;
    }
    for (var index = 0;
        index < left.weakDimensions.length;
        index += 1) {
      if (left.weakDimensions[index] != right.weakDimensions[index]) {
        return false;
      }
    }
    for (final entry in left.dimensionScores.entries) {
      if (right.dimensionScores[entry.key] != entry.value) return false;
    }
    return true;
  }

  static bool _orderedStringsEqual(
    List<String> left,
    List<String> right,
  ) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
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


final class LearnerPersistenceSqliteException implements Exception {
  const LearnerPersistenceSqliteException(this.code);

  final String code;

  @override
  String toString() => 'LearnerPersistenceSqliteException($code)';
}
