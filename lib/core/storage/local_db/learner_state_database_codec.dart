part of 'learner_state_database.dart';

const String _attemptsTable = LearnerStateDatabase.attemptsTable;
const String _assessmentTable = LearnerStateDatabase.assessmentTable;
const String _assessmentWeakSkillsTable =
    LearnerStateDatabase.assessmentWeakSkillsTable;
const String _placementTable = LearnerStateDatabase.placementTable;
const String _placementScoresTable =
    LearnerStateDatabase.placementScoresTable;
const String _placementWeakTable =
    LearnerStateDatabase.placementWeakTable;
const String _placementReviewItemsTable =
    LearnerStateDatabase.placementReviewItemsTable;
const String _favoritesTable = LearnerStateDatabase.favoritesTable;

const int _maxAttempts = LearnerStateDatabase.maxAttempts;
const int _maxAssessments = LearnerStateDatabase.maxAssessments;
const int _maxPlacements = LearnerStateDatabase.maxPlacements;
const int _maxFavorites = LearnerStateDatabase.maxFavorites;
const int _maxWeakSkills = LearnerStateDatabase.maxWeakSkills;
const int _maxPlacementReviewItems =
    LearnerStateDatabase.maxPlacementReviewItems;
const int _maxIdentifierLength =
    LearnerStateDatabase.maxIdentifierLength;
const int _maxAnswerLength = LearnerStateDatabase.maxAnswerLength;

bool _attemptRowMatches(
  Map<String, Object?> row,
  Attempt value,
) =>
    _strictIdentifier(row['attempt_id'], field: 'attempt_id') == value.id &&
    _strictIdentifier(row['item_id'], field: 'item_id') == value.itemId &&
    _strictIdentifier(row['skill'], field: 'skill') == value.skill &&
    _strictText(
          row['answer'],
          field: 'answer',
          maxLength: _maxAnswerLength,
          allowEmpty: true,
        ) ==
        value.answer &&
    _strictFlag(row['correct'], field: 'correct') == value.correct &&
    _strictFlag(row['hinted'], field: 'hinted') == value.hinted &&
    _strictInt(
          row['seconds'],
          field: 'seconds',
          min: 0,
          max: 3600,
        ) ==
        value.seconds &&
    _strictDateTime(
          row['occurred_at_utc'],
          field: 'occurred_at_utc',
        ).microsecondsSinceEpoch ==
        value.at.toUtc().microsecondsSinceEpoch &&
    _strictText(
          row['facet_type'],
          field: 'facet_type',
          maxLength: 64,
        ) ==
        value.facetType.wireName &&
    (_optionalBoundedText(
          row['variant_key'],
          field: 'variant_key',
          maxLength: _maxIdentifierLength,
        ) ??
        '') ==
        (ReviewFacetKey.normalizeVariant(value.variantKey) ?? '');

bool _assessmentRowsMatch(
  Map<String, Object?> row,
  List<Map<String, Object?>> weakRows,
  AssessmentHistory value,
) {
  if (_strictIdentifier(row['assessment_id'], field: 'assessment_id') !=
          value.id ||
      _strictDateTime(
            row['occurred_at_utc'],
            field: 'occurred_at_utc',
          ).microsecondsSinceEpoch !=
          value.at.toUtc().microsecondsSinceEpoch ||
      _strictFiniteDouble(
            row['score'],
            field: 'score',
            min: 0,
            max: 100,
          ) !=
          value.score ||
      _strictInt(
            row['answered'],
            field: 'answered',
            min: 0,
            max: 100,
          ) !=
          value.answered ||
      weakRows.length != value.weakSkills.length) {
    return false;
  }
  for (var index = 0; index < weakRows.length; index += 1) {
    final weak = weakRows[index];
    if (_strictInt(
              weak['position'],
              field: 'position',
              min: 0,
              max: _maxWeakSkills - 1,
            ) !=
            index ||
        _strictIdentifier(weak['skill'], field: 'weak_skill') !=
            value.weakSkills[index]) {
      return false;
    }
  }
  return true;
}

bool _placementRowsMatch(
  Map<String, Object?> row,
  List<Map<String, Object?>> scoreRows,
  List<Map<String, Object?>> weakRows,
  List<Map<String, Object?>> reviewRows,
  PlacementDiagnosticRecord value,
) {
  final level = row['curriculum_start_level']?.toString();
  final goal = row['learning_goal']?.toString();
  if (_strictIdentifier(row['placement_id'], field: 'placement_id') !=
          value.id ||
      _strictDateTime(
            row['occurred_at_utc'],
            field: 'occurred_at_utc',
          ).microsecondsSinceEpoch !=
          value.at.toUtc().microsecondsSinceEpoch ||
      _strictInt(row['answered'], field: 'answered', min: 0, max: 20) !=
          value.answered ||
      _strictInt(
            row['scored_answers'],
            field: 'scored_answers',
            min: 0,
            max: 20,
          ) !=
          value.scoredAnswers ||
      _strictFiniteDouble(
            row['score'],
            field: 'score',
            min: 0,
            max: 100,
          ) !=
          value.score ||
      _strictFiniteDouble(
            row['confidence'],
            field: 'confidence',
            min: 0,
            max: 1,
          ) !=
          value.confidence ||
      row['band']?.toString() != value.band.wireName ||
      (level == null || level.isEmpty ? null : level) !=
          value.curriculumStartLevel ||
      _strictInt(
            row['recommended_start_task_order'],
            field: 'recommended_start_task_order',
            min: 1,
            max: 50,
          ) !=
          value.recommendedStartTaskOrder ||
      (goal == null || goal.isEmpty ? null : goal) !=
          value.learningGoal) {
    return false;
  }

  final expectedScores = value.dimensionScores.entries.toList()
    ..sort((a, b) => a.key.wireName.compareTo(b.key.wireName));
  if (scoreRows.length != expectedScores.length ||
      weakRows.length != value.weakDimensions.length ||
      reviewRows.length != value.reviewItemIds.length) {
    return false;
  }
  for (var index = 0; index < scoreRows.length; index += 1) {
    if (scoreRows[index]['dimension']?.toString() !=
            expectedScores[index].key.wireName ||
        _strictFiniteDouble(
              scoreRows[index]['score'],
              field: 'dimension_score',
              min: 0,
              max: 1,
            ) !=
            expectedScores[index].value) {
      return false;
    }
  }
  for (var index = 0; index < weakRows.length; index += 1) {
    if (_strictInt(
              weakRows[index]['position'],
              field: 'position',
              min: 0,
              max: DiagnosticDimension.values.length - 1,
            ) !=
            index ||
        weakRows[index]['dimension']?.toString() !=
            value.weakDimensions[index].wireName) {
      return false;
    }
  }
  for (var index = 0; index < reviewRows.length; index += 1) {
    if (_strictInt(
              reviewRows[index]['position'],
              field: 'position',
              min: 0,
              max: _maxPlacementReviewItems - 1,
            ) !=
            index ||
        _strictIdentifier(
              reviewRows[index]['item_id'],
              field: 'placement_review_item_id',
            ) !=
            value.reviewItemIds[index]) {
      return false;
    }
  }
  return true;
}

Future<List<Attempt>> _readAttempts(DatabaseExecutor db) async {
  final rows = await db.query(
    _attemptsTable,
    orderBy: 'ordinal ASC',
    limit: _maxAttempts + 1,
  );
  if (rows.length > _maxAttempts) {
    throw const LearnerStateDatabaseException(
      'attempt_row_bound_exceeded',
    );
  }
  final result = <Attempt>[];
  final seenIds = <String>{};
  int? previousOrdinal;
  for (final row in rows) {
    final ordinal = _strictInt(
      row['ordinal'],
      field: 'ordinal',
      min: 0,
      max: 1 << 30,
    );
    if (previousOrdinal != null && ordinal <= previousOrdinal) {
      throw const LearnerStateDatabaseException(
        'attempt_ordinal_order_invalid',
      );
    }
    previousOrdinal = ordinal;
    final id = _strictIdentifier(row['attempt_id'], field: 'attempt_id');
    if (!seenIds.add(id)) {
      throw const LearnerStateDatabaseException(
        'duplicate_attempt_id',
      );
    }
    final facet = ReviewFacetType.fromWire(
      _strictText(
        row['facet_type'],
        field: 'facet_type',
        maxLength: 64,
      ),
    );
    if (facet == ReviewFacetType.unknown) {
      throw const LearnerStateDatabaseException(
        'invalid_attempt_facet_type',
      );
    }
    final variant = _optionalBoundedText(
      row['variant_key'],
      field: 'variant_key',
      maxLength: _maxIdentifierLength,
    );
    result.add(
      Attempt(
        id: id,
        itemId: _strictIdentifier(row['item_id'], field: 'item_id'),
        skill: _strictIdentifier(row['skill'], field: 'skill'),
        answer: _strictText(
          row['answer'],
          field: 'answer',
          maxLength: _maxAnswerLength,
          allowEmpty: true,
        ),
        correct: _strictFlag(row['correct'], field: 'correct'),
        hinted: _strictFlag(row['hinted'], field: 'hinted'),
        seconds: _strictInt(
          row['seconds'],
          field: 'seconds',
          min: 0,
          max: 3600,
        ),
        at: _strictDateTime(
          row['occurred_at_utc'],
          field: 'occurred_at_utc',
        ),
        facetType: facet,
        variantKey: variant,
      ),
    );
  }
  return List<Attempt>.unmodifiable(result);
}

Future<List<AssessmentHistory>> _readAssessments(
  DatabaseExecutor db,
) async {
  final rows = await db.query(
    _assessmentTable,
    orderBy: 'ordinal DESC',
    limit: _maxAssessments + 1,
  );
  if (rows.length > _maxAssessments) {
    throw const LearnerStateDatabaseException(
      'assessment_row_bound_exceeded',
    );
  }
  final weakRows = await db.query(
    _assessmentWeakSkillsTable,
    orderBy: 'assessment_id ASC, position ASC',
    limit: (_maxAssessments * _maxWeakSkills) + 1,
  );
  if (weakRows.length > _maxAssessments * _maxWeakSkills) {
    throw const LearnerStateDatabaseException(
      'assessment_weak_skill_bound_exceeded',
    );
  }
  final weakById = <String, List<String>>{};
  for (final row in weakRows) {
    final id = _strictIdentifier(
      row['assessment_id'],
      field: 'assessment_id',
    );
    final position = _strictInt(
      row['position'],
      field: 'position',
      min: 0,
      max: _maxWeakSkills - 1,
    );
    final values = weakById.putIfAbsent(id, () => <String>[]);
    if (position != values.length) {
      throw const LearnerStateDatabaseException(
        'assessment_weak_skill_order_invalid',
      );
    }
    values.add(
      _strictIdentifier(row['skill'], field: 'weak_skill'),
    );
  }

  final result = <AssessmentHistory>[];
  final seenIds = <String>{};
  int? previousOrdinal;
  for (final row in rows) {
    final ordinal = _strictInt(
      row['ordinal'],
      field: 'ordinal',
      min: 0,
      max: 1 << 30,
    );
    if (previousOrdinal != null && ordinal >= previousOrdinal) {
      throw const LearnerStateDatabaseException(
        'assessment_ordinal_order_invalid',
      );
    }
    previousOrdinal = ordinal;
    final id = _strictIdentifier(
      row['assessment_id'],
      field: 'assessment_id',
    );
    if (!seenIds.add(id)) {
      throw const LearnerStateDatabaseException(
        'duplicate_assessment_id',
      );
    }
    result.add(
      AssessmentHistory(
        id: id,
        at: _strictDateTime(
          row['occurred_at_utc'],
          field: 'occurred_at_utc',
        ),
        score: _strictFiniteDouble(
          row['score'],
          field: 'score',
          min: 0,
          max: 100,
        ),
        weakSkills:
            List<String>.unmodifiable(weakById[id] ?? const <String>[]),
        answered: _strictInt(
          row['answered'],
          field: 'answered',
          min: 0,
          max: 100,
        ),
      ),
    );
  }
  if (weakById.keys.any((id) => !seenIds.contains(id))) {
    throw const LearnerStateDatabaseException(
      'orphan_assessment_weak_skill',
    );
  }
  return List<AssessmentHistory>.unmodifiable(result);
}

Future<List<PlacementDiagnosticRecord>> _readPlacements(
  DatabaseExecutor db,
) async {
  final rows = await db.query(
    _placementTable,
    orderBy: 'ordinal DESC',
    limit: _maxPlacements + 1,
  );
  if (rows.length > _maxPlacements) {
    throw const LearnerStateDatabaseException(
      'placement_row_bound_exceeded',
    );
  }

  final scoreRows = await db.query(
    _placementScoresTable,
    orderBy: 'placement_id ASC, dimension ASC',
    limit: (_maxPlacements * DiagnosticDimension.values.length) + 1,
  );
  if (scoreRows.length >
      _maxPlacements * DiagnosticDimension.values.length) {
    throw const LearnerStateDatabaseException(
      'placement_score_bound_exceeded',
    );
  }
  final scoresById = <String, Map<DiagnosticDimension, double>>{};
  for (final row in scoreRows) {
    final id = _strictIdentifier(
      row['placement_id'],
      field: 'placement_id',
    );
    final dimension = DiagnosticDimension.fromWire(
      _strictText(
        row['dimension'],
        field: 'dimension',
        maxLength: 32,
      ),
    );
    if (dimension == null) {
      throw const LearnerStateDatabaseException(
        'invalid_placement_dimension',
      );
    }
    final scores = scoresById.putIfAbsent(
      id,
      () => <DiagnosticDimension, double>{},
    );
    if (scores.containsKey(dimension)) {
      throw const LearnerStateDatabaseException(
        'duplicate_placement_dimension',
      );
    }
    scores[dimension] = _strictFiniteDouble(
      row['score'],
      field: 'dimension_score',
      min: 0,
      max: 1,
    );
  }

  final weakRows = await db.query(
    _placementWeakTable,
    orderBy: 'placement_id ASC, position ASC',
    limit: (_maxPlacements * DiagnosticDimension.values.length) + 1,
  );
  if (weakRows.length >
      _maxPlacements * DiagnosticDimension.values.length) {
    throw const LearnerStateDatabaseException(
      'placement_weak_dimension_bound_exceeded',
    );
  }
  final weakById = <String, List<DiagnosticDimension>>{};
  for (final row in weakRows) {
    final id = _strictIdentifier(
      row['placement_id'],
      field: 'placement_id',
    );
    final position = _strictInt(
      row['position'],
      field: 'position',
      min: 0,
      max: DiagnosticDimension.values.length - 1,
    );
    final dimension = DiagnosticDimension.fromWire(
      _strictText(
        row['dimension'],
        field: 'dimension',
        maxLength: 32,
      ),
    );
    if (dimension == null) {
      throw const LearnerStateDatabaseException(
        'invalid_placement_weak_dimension',
      );
    }
    final values = weakById.putIfAbsent(
      id,
      () => <DiagnosticDimension>[],
    );
    if (position != values.length || values.contains(dimension)) {
      throw const LearnerStateDatabaseException(
        'placement_weak_dimension_order_invalid',
      );
    }
    values.add(dimension);
  }

  final reviewRows = await db.query(
    _placementReviewItemsTable,
    orderBy: 'placement_id ASC, position ASC',
    limit: (_maxPlacements * _maxPlacementReviewItems) + 1,
  );
  if (reviewRows.length > _maxPlacements * _maxPlacementReviewItems) {
    throw const LearnerStateDatabaseException(
      'placement_review_item_bound_exceeded',
    );
  }
  final reviewById = <String, List<String>>{};
  for (final row in reviewRows) {
    final id = _strictIdentifier(
      row['placement_id'],
      field: 'placement_id',
    );
    final position = _strictInt(
      row['position'],
      field: 'position',
      min: 0,
      max: _maxPlacementReviewItems - 1,
    );
    final itemId = _strictIdentifier(
      row['item_id'],
      field: 'placement_review_item_id',
    );
    final values = reviewById.putIfAbsent(id, () => <String>[]);
    if (position != values.length || values.contains(itemId)) {
      throw const LearnerStateDatabaseException(
        'placement_review_item_order_invalid',
      );
    }
    values.add(itemId);
  }

  final result = <PlacementDiagnosticRecord>[];
  final seenIds = <String>{};
  const allowedBands = <String>{
    'foundation',
    'basic',
    'developing',
    'strong',
  };
  const allowedLevels = <String>{'A1', 'A2', 'B1', 'B2'};
  const allowedGoals = <String>{
    'general',
    'dailyLife',
    'work',
    'studyExam',
    'travel',
  };

  int? previousOrdinal;
  for (final row in rows) {
    final ordinal = _strictInt(
      row['ordinal'],
      field: 'ordinal',
      min: 0,
      max: 1 << 30,
    );
    if (previousOrdinal != null && ordinal >= previousOrdinal) {
      throw const LearnerStateDatabaseException(
        'placement_ordinal_order_invalid',
      );
    }
    previousOrdinal = ordinal;
    final id = _strictIdentifier(
      row['placement_id'],
      field: 'placement_id',
    );
    if (!seenIds.add(id)) {
      throw const LearnerStateDatabaseException(
        'duplicate_placement_id',
      );
    }
    final bandRaw = _strictText(
      row['band'],
      field: 'band',
      maxLength: 32,
    );
    if (!allowedBands.contains(bandRaw)) {
      throw const LearnerStateDatabaseException(
        'invalid_placement_band',
      );
    }
    final level = _nullableStrictEnum(
      row['curriculum_start_level'],
      allowed: allowedLevels,
      field: 'curriculum_start_level',
    );
    final goal = _nullableStrictEnum(
      row['learning_goal'],
      allowed: allowedGoals,
      field: 'learning_goal',
    );

    result.add(
      PlacementDiagnosticRecord(
        id: id,
        at: _strictDateTime(
          row['occurred_at_utc'],
          field: 'occurred_at_utc',
        ),
        answered: _strictInt(
          row['answered'],
          field: 'answered',
          min: 0,
          max: 20,
        ),
        scoredAnswers: _strictInt(
          row['scored_answers'],
          field: 'scored_answers',
          min: 0,
          max: 20,
        ),
        score: _strictFiniteDouble(
          row['score'],
          field: 'score',
          min: 0,
          max: 100,
        ),
        confidence: _strictFiniteDouble(
          row['confidence'],
          field: 'confidence',
          min: 0,
          max: 1,
        ),
        band: DiagnosticPlacementBand.values.firstWhere(
          (candidate) => candidate.wireName == bandRaw,
        ),
        dimensionScores:
            Map<DiagnosticDimension, double>.unmodifiable(
          scoresById[id] ?? const <DiagnosticDimension, double>{},
        ),
        weakDimensions:
            List<DiagnosticDimension>.unmodifiable(
          weakById[id] ?? const <DiagnosticDimension>[],
        ),
        reviewItemIds: List<String>.unmodifiable(
          reviewById[id] ?? const <String>[],
        ),
        curriculumStartLevel: level,
        recommendedStartTaskOrder: _strictInt(
          row['recommended_start_task_order'],
          field: 'recommended_start_task_order',
          min: 1,
          max: 50,
        ),
        learningGoal: goal,
      ),
    );
  }

  final known = seenIds;
  if (scoresById.keys.any((id) => !known.contains(id)) ||
      weakById.keys.any((id) => !known.contains(id)) ||
      reviewById.keys.any((id) => !known.contains(id))) {
    throw const LearnerStateDatabaseException(
      'orphan_placement_child_row',
    );
  }
  return List<PlacementDiagnosticRecord>.unmodifiable(result);
}

Future<Set<String>> _readFavorites(DatabaseExecutor db) async {
  final rows = await db.query(
    _favoritesTable,
    orderBy: 'verb ASC',
    limit: _maxFavorites + 1,
  );
  if (rows.length > _maxFavorites) {
    throw const LearnerStateDatabaseException(
      'favorite_row_bound_exceeded',
    );
  }
  final result = <String>{};
  for (final row in rows) {
    final verb = _strictIdentifier(row['verb'], field: 'favorite_verb');
    if (!result.add(verb)) {
      throw const LearnerStateDatabaseException(
        'duplicate_favorite_verb',
      );
    }
  }
  return Set<String>.unmodifiable(result);
}

void _validateSnapshotBounds(LearnerSqliteSnapshot snapshot) {
  if (snapshot.attempts.length > _maxAttempts ||
      snapshot.assessmentHistory.length > _maxAssessments ||
      snapshot.placementHistory.length > _maxPlacements ||
      snapshot.favoriteVerbs.length > _maxFavorites) {
    throw const LearnerStateDatabaseException(
      'learner_snapshot_bound_exceeded',
    );
  }

  _requireUnique(
    snapshot.attempts.map((value) => value.id),
    'duplicate_attempt_id',
  );
  _requireUnique(
    snapshot.assessmentHistory.map((value) => value.id),
    'duplicate_assessment_id',
  );
  _requireUnique(
    snapshot.placementHistory.map((value) => value.id),
    'duplicate_placement_id',
  );
}

Attempt _validateAttempt(Attempt attempt) {
  _strictIdentifier(attempt.id, field: 'attempt_id');
  _strictIdentifier(attempt.itemId, field: 'item_id');
  _strictIdentifier(attempt.skill, field: 'skill');
  _strictText(
    attempt.answer,
    field: 'answer',
    maxLength: _maxAnswerLength,
    allowEmpty: true,
  );
  if (attempt.seconds < 0 || attempt.seconds > 3600) {
    throw const LearnerStateDatabaseException(
      'invalid_attempt_seconds',
    );
  }
  if (attempt.facetType == ReviewFacetType.unknown) {
    throw const LearnerStateDatabaseException(
      'invalid_attempt_facet_type',
    );
  }
  final variant = ReviewFacetKey.normalizeVariant(attempt.variantKey);
  if (variant != null && variant.length > _maxIdentifierLength) {
    throw const LearnerStateDatabaseException(
      'invalid_attempt_variant',
    );
  }
  _validateUtcDateRange(attempt.at, field: 'attempt_at');
  return attempt;
}

AssessmentHistory _validateAssessment(AssessmentHistory value) {
  _strictIdentifier(value.id, field: 'assessment_id');
  _validateUtcDateRange(value.at, field: 'assessment_at');
  if (!value.score.isFinite || value.score < 0 || value.score > 100) {
    throw const LearnerStateDatabaseException(
      'invalid_assessment_score',
    );
  }
  if (value.answered < 0 || value.answered > 100 ||
      value.weakSkills.length > _maxWeakSkills) {
    throw const LearnerStateDatabaseException(
      'invalid_assessment_bounds',
    );
  }
  for (final skill in value.weakSkills) {
    _strictIdentifier(skill, field: 'weak_skill');
  }
  return value;
}

PlacementDiagnosticRecord _validatePlacement(
  PlacementDiagnosticRecord value,
) {
  _strictIdentifier(value.id, field: 'placement_id');
  _validateUtcDateRange(value.at, field: 'placement_at');
  if (value.answered < 0 ||
      value.answered > 20 ||
      value.scoredAnswers < 0 ||
      value.scoredAnswers > 20 ||
      !value.score.isFinite ||
      value.score < 0 ||
      value.score > 100 ||
      !value.confidence.isFinite ||
      value.confidence < 0 ||
      value.confidence > 1 ||
      value.weakDimensions.length > DiagnosticDimension.values.length ||
      value.reviewItemIds.length > _maxPlacementReviewItems ||
      value.recommendedStartTaskOrder < 1 ||
      value.recommendedStartTaskOrder > 50) {
    throw const LearnerStateDatabaseException(
      'invalid_placement_bounds',
    );
  }
  const allowedLevels = <String>{'A1', 'A2', 'B1', 'B2'};
  const allowedGoals = <String>{
    'general',
    'dailyLife',
    'work',
    'studyExam',
    'travel',
  };
  final level = value.curriculumStartLevel;
  final goal = value.learningGoal;
  if ((level != null && !allowedLevels.contains(level)) ||
      (goal != null && !allowedGoals.contains(goal))) {
    throw const LearnerStateDatabaseException(
      'invalid_placement_metadata',
    );
  }
  for (final score in value.dimensionScores.values) {
    if (!score.isFinite || score < 0 || score > 1) {
      throw const LearnerStateDatabaseException(
        'invalid_placement_dimension_score',
      );
    }
  }
  if (value.weakDimensions.toSet().length !=
      value.weakDimensions.length) {
    throw const LearnerStateDatabaseException(
      'duplicate_placement_weak_dimension',
    );
  }
  _requireUnique(
    value.reviewItemIds,
    'duplicate_placement_review_item',
  );
  return value;
}

String _strictIdentifier(
  Object? raw, {
  required String field,
}) =>
    _strictText(
      raw,
      field: field,
      maxLength: _maxIdentifierLength,
    );

String _strictText(
  Object? raw, {
  required String field,
  required int maxLength,
  bool allowEmpty = false,
}) {
  if (raw is! String) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = raw.trim();
  if ((!allowEmpty && value.isEmpty) || value.length > maxLength) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  return allowEmpty ? raw : value;
}

String? _optionalBoundedText(
  Object? raw, {
  required String field,
  required int maxLength,
}) {
  if (raw == null) return null;
  if (raw is! String) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = raw.trim();
  if (value.isEmpty) return null;
  if (value.length > maxLength) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  return value;
}

int _strictInt(
  Object? raw, {
  required String field,
  required int min,
  required int max,
}) {
  if (raw is! num || raw.toInt() != raw) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = raw.toInt();
  if (value < min || value > max) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  return value;
}

bool _strictFlag(Object? raw, {required String field}) {
  final value = _strictInt(raw, field: field, min: 0, max: 1);
  return value == 1;
}

double _strictFiniteDouble(
  Object? raw, {
  required String field,
  required double min,
  required double max,
}) {
  if (raw is! num) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = raw.toDouble();
  if (!value.isFinite || value < min || value > max) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  return value;
}

DateTime _strictDateTime(
  Object? raw, {
  required String field,
}) {
  if (raw is! String) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = DateTime.tryParse(raw)?.toUtc();
  if (value == null) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  _validateUtcDateRange(value, field: field);
  return value;
}

void _validateUtcDateRange(
  DateTime value, {
  required String field,
}) {
  final utc = value.toUtc();
  final min = DateTime.utc(2000);
  final max = DateTime.now().toUtc().add(const Duration(days: 1));
  if (utc.isBefore(min) || utc.isAfter(max)) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
}

String? _nullableStrictEnum(
  Object? raw, {
  required Set<String> allowed,
  required String field,
}) {
  if (raw == null) return null;
  if (raw is! String) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  final value = raw.trim();
  if (value.isEmpty) return null;
  if (!allowed.contains(value)) {
    throw LearnerStateDatabaseException('invalid_$field');
  }
  return value;
}

void _requireUnique(
  Iterable<String> values,
  String code,
) {
  final seen = <String>{};
  for (final raw in values) {
    final value = _strictIdentifier(raw, field: 'identity');
    if (!seen.add(value)) {
      throw LearnerStateDatabaseException(code);
    }
  }
}
