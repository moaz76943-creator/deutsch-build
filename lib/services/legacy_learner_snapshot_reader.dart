import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../core/srs_facets.dart';
import '../core/storage/local_db/learner_state_database.dart';
import '../models/diagnostic_placement.dart';
import '../models/learner.dart';
import 'preferences_service.dart';

/// Read-only, strictly bounded reader for the legacy prefs learner snapshot.
///
/// It never mutates preferences: legacy keys are retained after cutover so a
/// verified rollback remains possible. The canonical digest it computes is the
/// pre-import half of the migration's integrity check.
final class LegacyLearnerSnapshotReader {
  const LegacyLearnerSnapshotReader(this.prefs, {required this.storageKey});

  final PreferencesService prefs;
  final String storageKey;

  static const int maxPayloadBytes = 4 * 1024 * 1024;
  static const int maxAttempts = 2000;
  static const int maxAssessmentHistory = 100;
  static const int maxPlacementHistory = 20;
  static const int maxFavoriteVerbs = 20000;
  static const int maxStorageKeyLength = 1024;

  Future<LearnerStateSnapshot> readSnapshot() async {
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      final emptyHash = LearnerStateDatabase.canonicalSnapshotSha256(
        attempts: const <Attempt>[],
        assessmentHistory: const <AssessmentHistory>[],
        placementHistory: const <PlacementDiagnosticRecord>[],
        favoriteVerbs: const <String>{},
      );
      return LearnerStateSnapshot(
        sourceKey: 'legacy_prefs',
        attempts: const <Attempt>[],
        assessmentHistory: const <AssessmentHistory>[],
        placementHistory: const <PlacementDiagnosticRecord>[],
        favoriteVerbs: const <String>{},
        canonicalSnapshotSha256: emptyHash,
        capturedAtUtc: DateTime.fromMillisecondsSinceEpoch(
          0,
          isUtc: true,
        ),
      );
    }
    if (utf8.encode(raw).length > maxPayloadBytes) {
      throw const LegacyLearnerSnapshotException('legacy_payload_too_large');
    }
    if (storageKey.trim().length > maxStorageKeyLength) {
      throw const LegacyLearnerSnapshotException('legacy_storage_key_invalid');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const LegacyLearnerSnapshotException('legacy_payload_not_map');
    }
    final json = <String, dynamic>{};
    for (final entry in decoded.entries) {
      if (entry.key is String) json[entry.key as String] = entry.value;
    }

    final attempts = <Attempt>[];
    final seenAttemptIds = <String>{};
    final attemptsRaw = json['attempts'];
    if (attemptsRaw is List) {
      for (final value in attemptsRaw.take(maxAttempts)) {
        if (value is! Map) continue;
        final attempt = _normalizeAttempt(
          Attempt.fromJson(Map<String, dynamic>.from(value)),
        );
        if (attempt.id.isEmpty || attempt.itemId.isEmpty) continue;
        if (!seenAttemptIds.add(attempt.id)) {
          throw const LegacyLearnerSnapshotException(
            'duplicate_attempt_id',
          );
        }
        attempts.add(attempt);
      }
    }

    final assessmentHistory = <AssessmentHistory>[];
    final seenAssessmentIds = <String>{};
    final historyRaw = json['assessmentHistory'];
    if (historyRaw is List) {
      for (final value in historyRaw.take(maxAssessmentHistory)) {
        if (value is! Map) continue;
        final history = AssessmentHistory.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (history.id.isEmpty) continue;
        if (!seenAssessmentIds.add(history.id)) {
          throw const LegacyLearnerSnapshotException(
            'duplicate_assessment_id',
          );
        }
        assessmentHistory.add(history);
      }
    }

    final placementHistory = <PlacementDiagnosticRecord>[];
    final seenPlacementIds = <String>{};
    final placementRaw = json['placementHistory'];
    if (placementRaw is List) {
      for (final value in placementRaw.take(maxPlacementHistory)) {
        if (value is! Map) continue;
        final record = PlacementDiagnosticRecord.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (record.id.isEmpty) continue;
        if (!seenPlacementIds.add(record.id)) {
          throw const LegacyLearnerSnapshotException(
            'duplicate_placement_id',
          );
        }
        placementHistory.add(record);
      }
    }

    final favoriteVerbs = <String>{
      for (final value in (json['favoriteVerbs'] is List
              ? (json['favoriteVerbs'] as List).take(maxFavoriteVerbs)
              : const <dynamic>[])
        if (value is String && value.trim().isNotEmpty) value.trim(),
    };

    // The reader computes the pre-import digest itself (same canonical
    // payload builder the SQLite store uses post-import) so verification
    // is a pure equality check across the cutover.
    final canonicalSnapshotSha256 = Sha256().hash(
          utf8.encode(
            jsonEncode(
              LearnerStateDatabase.canonicalSnapshotPayload(
                attempts: attempts,
                assessmentHistory: assessmentHistory,
                placementHistory: placementHistory,
                favoriteVerbs: favoriteVerbs,
              ),
            ),
          ),
        )
        .toString();

    return LearnerStateSnapshot(
      sourceKey: storageKey,
      attempts: attempts,
      assessmentHistory: assessmentHistory,
      placementHistory: placementHistory,
      favoriteVerbs: favoriteVerbs,
      canonicalSnapshotSha256: canonicalSnapshotSha256,
      capturedAtUtc: DateTime.now().toUtc(),
    );
  }

  static Attempt _normalizeAttempt(Attempt attempt) {
    final now = DateTime.now();
    final safeAt = attempt.at.isAfter(now.add(const Duration(days: 1)))
        ? now
        : attempt.at;
    return Attempt(
      id: attempt.id.trim().length > 160
          ? attempt.id.trim().substring(0, 160)
          : attempt.id.trim(),
      itemId: attempt.itemId.trim().length > 160
          ? attempt.itemId.trim().substring(0, 160)
          : attempt.itemId.trim(),
      skill: attempt.skill.trim().length > 160
          ? attempt.skill.trim().substring(0, 160)
          : attempt.skill.trim(),
      answer: attempt.answer.length > 1000
          ? attempt.answer.substring(0, 1000)
          : attempt.answer,
      correct: attempt.correct,
      hinted: attempt.hinted,
      seconds: attempt.seconds.clamp(0, 3600),
      at: safeAt,
      facetType: attempt.facetType,
      variantKey: ReviewFacetKey.normalizeVariant(attempt.variantKey),
    );
  }
}

final class LegacyLearnerSnapshotException implements Exception {
  const LegacyLearnerSnapshotException(this.code);

  final String code;

  @override
  String toString() => 'LegacyLearnerSnapshotException($code)';
}
