import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../core/srs_facets.dart';
import '../core/storage/local_db/learner_state_database.dart';
import '../models/diagnostic_placement.dart';
import '../models/learner.dart';
import 'preferences_service.dart';

final class LegacyLearnerSnapshotReader {
  const LegacyLearnerSnapshotReader({
    required this.prefs,
    required this.storageKey,
    required this.legacyFavoriteKey,
  });

  final PreferencesService prefs;
  final String storageKey;
  final String legacyFavoriteKey;

  static const int maxPayloadBytes = 4 * 1024 * 1024;

  Future<LegacyLearnerMigrationSnapshot> readStrict() async {
    final rawPayload = prefs.getString(storageKey);
    final sourcePayload = rawPayload ?? '{}';
    if (utf8.encode(sourcePayload).length > maxPayloadBytes) {
      throw const LegacyLearnerSnapshotException(
        'legacy_payload_too_large',
      );
    }

    final decoded = _decodeTopLevel(sourcePayload);
    final attempts = _parseAttempts(decoded['attempts']);
    final assessments = _parseAssessments(decoded['assessmentHistory']);
    final placements = _parsePlacements(decoded['placementHistory']);
    final primaryFavorites = _parseFavoriteList(
      decoded['favoriteVerbs'],
      field: 'favoriteVerbs',
    );

    final rawLegacyFavorites =
        prefs.getStringList(legacyFavoriteKey) ?? const <String>[];
    if (rawLegacyFavorites.length > LearnerStateDatabase.maxFavorites) {
      throw const LegacyLearnerSnapshotException(
        'legacy_favorite_bound_exceeded',
      );
    }
    final legacyFavorites = <String>{};
    for (final raw in rawLegacyFavorites) {
      legacyFavorites.add(
        _strictIdentifier(raw, field: 'legacy_favorite_verb'),
      );
    }

    final mergedFavorites = <String>{
      ...primaryFavorites,
      ...legacyFavorites,
    };
    if (mergedFavorites.length > LearnerStateDatabase.maxFavorites) {
      throw const LegacyLearnerSnapshotException(
        'merged_favorite_bound_exceeded',
      );
    }

    final sqliteSnapshot = LearnerSqliteSnapshot(
      attempts: List<Attempt>.unmodifiable(attempts),
      assessmentHistory:
          List<AssessmentHistory>.unmodifiable(assessments),
      placementHistory:
          List<PlacementDiagnosticRecord>.unmodifiable(placements),
      favoriteVerbs: Set<String>.unmodifiable(mergedFavorites),
    );

    return LegacyLearnerMigrationSnapshot(
      sqliteSnapshot: sqliteSnapshot,
      sourcePayloadSha256: await _sha256Utf8(rawPayload ?? ''),
      sourceLegacyFavoritesSha256:
          await _sha256Utf8(jsonEncode(rawLegacyFavorites)),
      canonicalSnapshotSha256:
          await canonicalSnapshotSha256(sqliteSnapshot),
    );
  }

  static Future<String> canonicalSnapshotSha256(
    LearnerSqliteSnapshot snapshot,
  ) =>
      _sha256Utf8(canonicalSnapshotJson(snapshot));

  static String canonicalSnapshotJson(
    LearnerSqliteSnapshot snapshot,
  ) {
    final favorites = snapshot.favoriteVerbs.toList()..sort();

    return jsonEncode(<String, Object?>{
      'attempts': snapshot.attempts.map(_canonicalAttempt).toList(),
      'assessmentHistory':
          snapshot.assessmentHistory.map(_canonicalAssessment).toList(),
      'placementHistory':
          snapshot.placementHistory.map(_canonicalPlacement).toList(),
      'favoriteVerbs': favorites,
    });
  }

  static Map<String, Object?> _canonicalAttempt(Attempt value) =>
      <String, Object?>{
        'id': value.id,
        'itemId': value.itemId,
        'skill': value.skill,
        'answer': value.answer,
        'correct': value.correct,
        'hinted': value.hinted,
        'seconds': value.seconds,
        'at': value.at.toUtc().toIso8601String(),
        'facetType': value.facetType.wireName,
        'variantKey':
            ReviewFacetKey.normalizeVariant(value.variantKey) ?? '',
      };

  static Map<String, Object?> _canonicalAssessment(
    AssessmentHistory value,
  ) =>
      <String, Object?>{
        'id': value.id,
        'at': value.at.toUtc().toIso8601String(),
        'score': value.score,
        'weakSkills': List<String>.from(value.weakSkills),
        'answered': value.answered,
      };

  static Map<String, Object?> _canonicalPlacement(
    PlacementDiagnosticRecord value,
  ) {
    final dimensions = value.dimensionScores.entries.toList()
      ..sort((a, b) => a.key.wireName.compareTo(b.key.wireName));
    return <String, Object?>{
      'id': value.id,
      'at': value.at.toUtc().toIso8601String(),
      'answered': value.answered,
      'scoredAnswers': value.scoredAnswers,
      'score': value.score,
      'confidence': value.confidence,
      'band': value.band.wireName,
      'dimensionScores': <String, double>{
        for (final entry in dimensions)
          entry.key.wireName: entry.value,
      },
      'weakDimensions':
          value.weakDimensions.map((item) => item.wireName).toList(),
      'reviewItemIds': List<String>.from(value.reviewItemIds),
      'curriculumStartLevel': value.curriculumStartLevel,
      'recommendedStartTaskOrder': value.recommendedStartTaskOrder,
      'learningGoal': value.learningGoal,
    };
  }

  static Map<String, dynamic> _decodeTopLevel(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on Object {
      throw const LegacyLearnerSnapshotException(
        'legacy_payload_invalid_json',
      );
    }
    if (decoded is! Map) {
      throw const LegacyLearnerSnapshotException(
        'legacy_payload_not_object',
      );
    }

    final result = <String, dynamic>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        throw const LegacyLearnerSnapshotException(
          'legacy_payload_non_string_key',
        );
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static List<Attempt> _parseAttempts(Object? raw) {
    if (raw == null) return const <Attempt>[];
    if (raw is! List) {
      throw const LegacyLearnerSnapshotException(
        'legacy_attempts_not_list',
      );
    }
    if (raw.length > LearnerStateDatabase.maxAttempts) {
      throw const LegacyLearnerSnapshotException(
        'legacy_attempt_bound_exceeded',
      );
    }

    final result = <Attempt>[];
    final ids = <String>{};
    for (final value in raw) {
      final row = _strictMap(value, field: 'attempt');
      final id = _strictIdentifier(row['id'], field: 'attempt_id');
      if (!ids.add(id)) {
        throw const LegacyLearnerSnapshotException(
          'duplicate_attempt_id',
        );
      }
      final facet = ReviewFacetType.fromWire(
        _strictString(
          row['facetType'],
          field: 'facet_type',
          maxLength: 64,
        ),
      );
      if (facet == ReviewFacetType.unknown) {
        throw const LegacyLearnerSnapshotException(
          'invalid_attempt_facet_type',
        );
      }
      final variant = _optionalString(
        row['variantKey'],
        field: 'variant_key',
        maxLength: LearnerStateDatabase.maxIdentifierLength,
      );
      result.add(
        Attempt(
          id: id,
          itemId: _strictIdentifier(row['itemId'], field: 'item_id'),
          skill: _strictIdentifier(row['skill'], field: 'skill'),
          answer: _strictString(
            row['answer'],
            field: 'answer',
            maxLength: LearnerStateDatabase.maxAnswerLength,
            allowEmpty: true,
            trim: false,
          ),
          correct: _strictBool(row['correct'], field: 'correct'),
          hinted: _strictBool(row['hinted'], field: 'hinted'),
          seconds: _strictInteger(
            row['seconds'],
            field: 'seconds',
            min: 0,
            max: 3600,
          ),
          at: _strictDateTime(row['at'], field: 'attempt_at'),
          facetType: facet,
          variantKey: variant,
        ),
      );
    }
    return result;
  }

  static List<AssessmentHistory> _parseAssessments(Object? raw) {
    if (raw == null) return const <AssessmentHistory>[];
    if (raw is! List) {
      throw const LegacyLearnerSnapshotException(
        'legacy_assessments_not_list',
      );
    }
    if (raw.length > LearnerStateDatabase.maxAssessments) {
      throw const LegacyLearnerSnapshotException(
        'legacy_assessment_bound_exceeded',
      );
    }

    final result = <AssessmentHistory>[];
    final ids = <String>{};
    for (final value in raw) {
      final row = _strictMap(value, field: 'assessment');
      final id = _strictIdentifier(
        row['id'],
        field: 'assessment_id',
      );
      if (!ids.add(id)) {
        throw const LegacyLearnerSnapshotException(
          'duplicate_assessment_id',
        );
      }

      final rawWeak = row['weakSkills'];
      if (rawWeak is! List ||
          rawWeak.length > LearnerStateDatabase.maxWeakSkills) {
        throw const LegacyLearnerSnapshotException(
          'invalid_assessment_weak_skills',
        );
      }
      final weak = <String>[];
      for (final item in rawWeak) {
        weak.add(_strictIdentifier(item, field: 'weak_skill'));
      }

      result.add(
        AssessmentHistory(
          id: id,
          at: _strictDateTime(row['at'], field: 'assessment_at'),
          score: _strictDouble(
            row['score'],
            field: 'assessment_score',
            min: 0,
            max: 100,
          ),
          weakSkills: List<String>.unmodifiable(weak),
          answered: _strictInteger(
            row['answered'],
            field: 'assessment_answered',
            min: 0,
            max: 100,
          ),
        ),
      );
    }
    return result;
  }

  static List<PlacementDiagnosticRecord> _parsePlacements(Object? raw) {
    if (raw == null) return const <PlacementDiagnosticRecord>[];
    if (raw is! List) {
      throw const LegacyLearnerSnapshotException(
        'legacy_placements_not_list',
      );
    }
    if (raw.length > LearnerStateDatabase.maxPlacements) {
      throw const LegacyLearnerSnapshotException(
        'legacy_placement_bound_exceeded',
      );
    }

    final result = <PlacementDiagnosticRecord>[];
    final ids = <String>{};
    for (final value in raw) {
      final row = _strictMap(value, field: 'placement');
      final id = _strictIdentifier(
        row['id'],
        field: 'placement_id',
      );
      if (!ids.add(id)) {
        throw const LegacyLearnerSnapshotException(
          'duplicate_placement_id',
        );
      }

      final bandRaw = _strictString(
        row['band'],
        field: 'placement_band',
        maxLength: 32,
      );
      final band = DiagnosticPlacementBand.values
          .where((candidate) => candidate.wireName == bandRaw)
          .toList(growable: false);
      if (band.length != 1) {
        throw const LegacyLearnerSnapshotException(
          'invalid_placement_band',
        );
      }

      final rawScores = row['dimensionScores'];
      if (rawScores is! Map ||
          rawScores.length > DiagnosticDimension.values.length) {
        throw const LegacyLearnerSnapshotException(
          'invalid_placement_dimension_scores',
        );
      }
      final scores = <DiagnosticDimension, double>{};
      for (final entry in rawScores.entries) {
        if (entry.key is! String) {
          throw const LegacyLearnerSnapshotException(
            'invalid_placement_dimension_key',
          );
        }
        final dimension = DiagnosticDimension.fromWire(entry.key as String);
        if (dimension == null || scores.containsKey(dimension)) {
          throw const LegacyLearnerSnapshotException(
            'invalid_placement_dimension',
          );
        }
        scores[dimension] = _strictDouble(
          entry.value,
          field: 'placement_dimension_score',
          min: 0,
          max: 1,
        );
      }

      final weak = _parsePlacementWeakDimensions(row['weakDimensions']);
      final reviewItems = _parsePlacementReviewItems(row['reviewItemIds']);
      final level = _optionalEnum(
        row['curriculumStartLevel'],
        field: 'curriculum_start_level',
        allowed: const <String>{'A1', 'A2', 'B1', 'B2'},
      );
      final goal = _optionalEnum(
        row['learningGoal'],
        field: 'learning_goal',
        allowed: const <String>{
          'general',
          'dailyLife',
          'work',
          'studyExam',
          'travel',
        },
      );

      final taskOrder = row.containsKey('recommendedStartTaskOrder')
          ? _strictInteger(
              row['recommendedStartTaskOrder'],
              field: 'recommended_start_task_order',
              min: 1,
              max: 50,
            )
          : 1;

      result.add(
        PlacementDiagnosticRecord(
          id: id,
          at: _strictDateTime(row['at'], field: 'placement_at'),
          answered: _strictInteger(
            row['answered'],
            field: 'placement_answered',
            min: 0,
            max: 20,
          ),
          scoredAnswers: _strictInteger(
            row['scoredAnswers'],
            field: 'placement_scored_answers',
            min: 0,
            max: 20,
          ),
          score: _strictDouble(
            row['score'],
            field: 'placement_score',
            min: 0,
            max: 100,
          ),
          confidence: _strictDouble(
            row['confidence'],
            field: 'placement_confidence',
            min: 0,
            max: 1,
          ),
          band: band.single,
          dimensionScores:
              Map<DiagnosticDimension, double>.unmodifiable(scores),
          weakDimensions:
              List<DiagnosticDimension>.unmodifiable(weak),
          reviewItemIds: List<String>.unmodifiable(reviewItems),
          curriculumStartLevel: level,
          recommendedStartTaskOrder: taskOrder,
          learningGoal: goal,
        ),
      );
    }
    return result;
  }

  static List<DiagnosticDimension> _parsePlacementWeakDimensions(
    Object? raw,
  ) {
    if (raw is! List ||
        raw.length > DiagnosticDimension.values.length) {
      throw const LegacyLearnerSnapshotException(
        'invalid_placement_weak_dimensions',
      );
    }
    final result = <DiagnosticDimension>[];
    for (final item in raw) {
      if (item is! String) {
        throw const LegacyLearnerSnapshotException(
          'invalid_placement_weak_dimension',
        );
      }
      final dimension = DiagnosticDimension.fromWire(item);
      if (dimension == null || result.contains(dimension)) {
        throw const LegacyLearnerSnapshotException(
          'invalid_placement_weak_dimension',
        );
      }
      result.add(dimension);
    }
    return result;
  }

  static List<String> _parsePlacementReviewItems(Object? raw) {
    if (raw is! List ||
        raw.length > LearnerStateDatabase.maxPlacementReviewItems) {
      throw const LegacyLearnerSnapshotException(
        'invalid_placement_review_items',
      );
    }
    final result = <String>[];
    for (final item in raw) {
      final id = _strictIdentifier(
        item,
        field: 'placement_review_item_id',
      );
      if (result.contains(id)) {
        throw const LegacyLearnerSnapshotException(
          'duplicate_placement_review_item',
        );
      }
      result.add(id);
    }
    return result;
  }

  static Set<String> _parseFavoriteList(
    Object? raw, {
    required String field,
  }) {
    if (raw == null) return <String>{};
    if (raw is! List ||
        raw.length > LearnerStateDatabase.maxFavorites) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final result = <String>{};
    for (final item in raw) {
      result.add(_strictIdentifier(item, field: 'favorite_verb'));
    }
    return result;
  }

  static Map<String, dynamic> _strictMap(
    Object? raw, {
    required String field,
  }) {
    if (raw is! Map) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      if (entry.key is! String) {
        throw LegacyLearnerSnapshotException('invalid_$field');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static String _strictIdentifier(
    Object? raw, {
    required String field,
  }) =>
      _strictString(
        raw,
        field: field,
        maxLength: LearnerStateDatabase.maxIdentifierLength,
      );

  static String _strictString(
    Object? raw, {
    required String field,
    required int maxLength,
    bool allowEmpty = false,
    bool trim = true,
  }) {
    if (raw is! String) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final normalized = trim ? raw.trim() : raw;
    if ((!allowEmpty && normalized.isEmpty) ||
        normalized.length > maxLength) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return normalized;
  }

  static String? _optionalString(
    Object? raw, {
    required String field,
    required int maxLength,
  }) {
    if (raw == null) return null;
    if (raw is! String) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.length > maxLength) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return ReviewFacetKey.normalizeVariant(value);
  }

  static bool _strictBool(Object? raw, {required String field}) {
    if (raw is! bool) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return raw;
  }

  static int _strictInteger(
    Object? raw, {
    required String field,
    required int min,
    required int max,
  }) {
    if (raw is! num || raw.toInt() != raw) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final value = raw.toInt();
    if (value < min || value > max) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return value;
  }

  static double _strictDouble(
    Object? raw, {
    required String field,
    required double min,
    required double max,
  }) {
    if (raw is! num) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final value = raw.toDouble();
    if (!value.isFinite || value < min || value > max) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return value;
  }

  static DateTime _strictDateTime(
    Object? raw, {
    required String field,
  }) {
    if (raw is! String) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final value = DateTime.tryParse(raw)?.toUtc();
    if (value == null ||
        value.isBefore(DateTime.utc(2000)) ||
        value.isAfter(DateTime.now().toUtc().add(const Duration(days: 1)))) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return value;
  }

  static String? _optionalEnum(
    Object? raw, {
    required String field,
    required Set<String> allowed,
  }) {
    if (raw == null) return null;
    if (raw is! String) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (!allowed.contains(value)) {
      throw LegacyLearnerSnapshotException('invalid_$field');
    }
    return value;
  }

  static Future<String> _sha256Utf8(String value) async {
    final digest = await Sha256().hash(utf8.encode(value));
    final buffer = StringBuffer();
    for (final byte in digest.bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

final class LegacyLearnerMigrationSnapshot {
  const LegacyLearnerMigrationSnapshot({
    required this.sqliteSnapshot,
    required this.sourcePayloadSha256,
    required this.sourceLegacyFavoritesSha256,
    required this.canonicalSnapshotSha256,
  });

  final LearnerSqliteSnapshot sqliteSnapshot;
  final String sourcePayloadSha256;
  final String sourceLegacyFavoritesSha256;
  final String canonicalSnapshotSha256;

  int get attemptCount => sqliteSnapshot.attempts.length;
  int get assessmentCount => sqliteSnapshot.assessmentHistory.length;
  int get placementCount => sqliteSnapshot.placementHistory.length;
  int get favoriteCount => sqliteSnapshot.favoriteVerbs.length;
}

final class LegacyLearnerSnapshotException implements Exception {
  const LegacyLearnerSnapshotException(this.code);

  final String code;

  @override
  String toString() => 'LegacyLearnerSnapshotException($code)';
}
