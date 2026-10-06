import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../srs_facets.dart';

final class ReviewTransactionEnvelope {
  ReviewTransactionEnvelope._({
    required this.reviewEventId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.conceptId,
    required this.facetType,
    required this.variantKey,
    required this.skill,
    required this.answer,
    required this.correct,
    required this.hinted,
    required this.seconds,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.requestedXp,
    required this.compatibilityStreakTarget,
  });

  static const int schemaVersion = 1;
  static const int maxReviewEventIdLength = 160;
  static const int maxAnswerLength = 1000;
  static const int maxSkillLength = 160;
  static const int maxRequestedXp = 100;
  static const int maxCompatibilityStreak = 10000;

  final String reviewEventId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final String conceptId;
  final ReviewFacetType facetType;
  final String? variantKey;
  final String skill;
  final String answer;
  final bool correct;
  final bool hinted;
  final int seconds;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final int requestedXp;
  final int? compatibilityStreakTarget;

  factory ReviewTransactionEnvelope({
    required String reviewEventId,
    required String sourceLanguageId,
    required String targetLanguageId,
    required String conceptId,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
    required String skill,
    required String answer,
    required bool correct,
    required bool hinted,
    required int seconds,
    required DateTime occurredAt,
    required int timezoneOffsetMinutes,
    required int requestedXp,
    int? compatibilityStreakTarget,
  }) {
    final normalizedEventId = reviewEventId.trim();
    if (normalizedEventId.isEmpty ||
        normalizedEventId.length > maxReviewEventIdLength) {
      throw ArgumentError.value(
        reviewEventId,
        'reviewEventId',
        'must be 1..$maxReviewEventIdLength characters',
      );
    }

    final source = _language(sourceLanguageId, 'sourceLanguageId');
    final target = _language(targetLanguageId, 'targetLanguageId');
    if (source == target) {
      throw ArgumentError('Review source and target languages must differ.');
    }

    final normalizedConceptId = conceptId.trim();
    final facetKey = ReviewFacetKey(
      conceptId: normalizedConceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!facetKey.isValid) {
      throw ArgumentError.value(
        conceptId,
        'conceptId',
        'must define a valid review facet key',
      );
    }

    final normalizedSkill = skill.trim();
    if (normalizedSkill.isEmpty || normalizedSkill.length > maxSkillLength) {
      throw ArgumentError.value(
        skill,
        'skill',
        'must be 1..$maxSkillLength characters',
      );
    }
    if (answer.length > maxAnswerLength) {
      throw ArgumentError.value(
        answer.length,
        'answer.length',
        'must not exceed $maxAnswerLength characters',
      );
    }
    if (seconds < 0 || seconds > 3600) {
      throw ArgumentError.value(seconds, 'seconds', 'must be 0..3600');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(
        timezoneOffsetMinutes,
        'timezoneOffsetMinutes',
        'must be -840..840',
      );
    }
    if (requestedXp < 0 || requestedXp > maxRequestedXp) {
      throw ArgumentError.value(
        requestedXp,
        'requestedXp',
        'must be 0..$maxRequestedXp',
      );
    }
    final streakTarget = compatibilityStreakTarget;
    if (streakTarget != null &&
        (streakTarget < 0 || streakTarget > maxCompatibilityStreak)) {
      throw ArgumentError.value(
        streakTarget,
        'compatibilityStreakTarget',
        'must be 0..$maxCompatibilityStreak',
      );
    }

    return ReviewTransactionEnvelope._(
      reviewEventId: normalizedEventId,
      sourceLanguageId: source,
      targetLanguageId: target,
      conceptId: normalizedConceptId,
      facetType: facetType,
      variantKey: facetKey.normalizedVariantKey,
      skill: normalizedSkill,
      answer: answer,
      correct: correct,
      hinted: hinted,
      seconds: seconds,
      occurredAtUtc: occurredAt.toUtc(),
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      requestedXp: requestedXp,
      compatibilityStreakTarget: streakTarget,
    );
  }

  factory ReviewTransactionEnvelope.fromJournalRow(
    Map<String, Object?> row,
  ) {
    final version = _requiredInt(row, 'envelope_version');
    if (version != schemaVersion) {
      throw FormatException(
        'Unsupported review envelope version: $version',
      );
    }
    final facet = ReviewFacetType.fromWire(
      _requiredString(row, 'facet_type'),
    );
    if (facet == ReviewFacetType.unknown) {
      throw const FormatException('Invalid review facet type.');
    }

    return ReviewTransactionEnvelope(
      reviewEventId: _requiredString(row, 'review_event_id'),
      sourceLanguageId: _requiredString(row, 'source_language_id'),
      targetLanguageId: _requiredString(row, 'target_language_id'),
      conceptId: _requiredString(row, 'concept_id'),
      facetType: facet,
      variantKey: _optionalString(row['variant_key']),
      skill: _requiredString(row, 'skill'),
      answer: _requiredString(row, 'answer', allowEmpty: true),
      correct: _requiredFlag(row, 'correct'),
      hinted: _requiredFlag(row, 'hinted'),
      seconds: _requiredInt(row, 'seconds'),
      occurredAt: _requiredDateTime(row, 'occurred_at_utc'),
      timezoneOffsetMinutes:
          _requiredInt(row, 'timezone_offset_minutes'),
      requestedXp: _requiredInt(row, 'requested_xp'),
      compatibilityStreakTarget:
          _optionalInt(row['compatibility_streak_target']),
    );
  }

  ReviewFacetKey get facetKey => ReviewFacetKey(
        conceptId: conceptId,
        facetType: facetType,
        variantKey: variantKey,
      );

  String get cardId => facetKey.storageKey;

  Map<String, Object?> canonicalPayload() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'reviewEventId': reviewEventId,
        'sourceLanguageId': sourceLanguageId,
        'targetLanguageId': targetLanguageId,
        'conceptId': conceptId,
        'facetType': facetType.wireName,
        'variantKey': variantKey ?? '',
        'skill': skill,
        'answer': answer,
        'correct': correct,
        'hinted': hinted,
        'seconds': seconds,
        'occurredAtUtc': occurredAtUtc.toIso8601String(),
        'timezoneOffsetMinutes': timezoneOffsetMinutes,
        'requestedXp': requestedXp,
        'compatibilityStreakTarget': compatibilityStreakTarget,
      };

  String canonicalJson() => jsonEncode(canonicalPayload());

  Future<String> computePayloadHash() async {
    final digest = await Sha256().hash(utf8.encode(canonicalJson()));
    final buffer = StringBuffer();
    for (final byte in digest.bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Map<String, Object?> toJournalValues({
    required String payloadHash,
    required DateTime createdAtUtc,
  }) {
    final normalizedHash = _sha256(payloadHash);
    return <String, Object?>{
      'review_event_id': reviewEventId,
      'envelope_version': schemaVersion,
      'source_language_id': sourceLanguageId,
      'target_language_id': targetLanguageId,
      'concept_id': conceptId,
      'card_id': cardId,
      'facet_type': facetType.wireName,
      'variant_key': variantKey ?? '',
      'skill': skill,
      'answer': answer,
      'correct': correct ? 1 : 0,
      'hinted': hinted ? 1 : 0,
      'seconds': seconds,
      'occurred_at_utc': occurredAtUtc.toIso8601String(),
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'requested_xp': requestedXp,
      'compatibility_streak_target': compatibilityStreakTarget,
      'payload_hash': normalizedHash,
      'attempt_applied': 0,
      'gamification_applied': 0,
      'created_at_utc': createdAtUtc.toUtc().toIso8601String(),
      'completed_at_utc': null,
    };
  }

  static String generateReviewEventId({
    required String kind,
    required DateTime occurredAt,
    Random? random,
  }) {
    final normalizedKind = kind.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_-]{1,24}$').hasMatch(normalizedKind)) {
      throw ArgumentError.value(
        kind,
        'kind',
        'must match [a-z0-9_-] and be 1..24 characters',
      );
    }
    final source = random ?? Random.secure();
    final nonce = List<int>.generate(12, (_) => source.nextInt(256));
    final token = base64Url.encode(nonce).replaceAll('=', '');
    return 'rv1:$normalizedKind:'
        '${occurredAt.toUtc().microsecondsSinceEpoch}:$token';
  }

  static String validatePayloadHash(String value) => _sha256(value);

  static String _language(String raw, String field) {
    final normalized = raw.trim().replaceAll('_', '-').toLowerCase();
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

  static String _sha256(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalized)) {
      throw ArgumentError.value(raw, 'payloadHash', 'invalid SHA-256');
    }
    return normalized;
  }

  static String _requiredString(
    Map<String, Object?> row,
    String key, {
    bool allowEmpty = false,
  }) {
    final value = row[key]?.toString() ?? '';
    if ((!allowEmpty && value.trim().isEmpty) || value.length > 4096) {
      throw FormatException('Invalid review journal field: $key');
    }
    return allowEmpty ? value : value.trim();
  }

  static int _requiredInt(Map<String, Object?> row, String key) {
    final raw = row[key];
    final value =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
    if (value == null) {
      throw FormatException('Invalid review journal integer: $key');
    }
    return value;
  }

  static bool _requiredFlag(Map<String, Object?> row, String key) {
    final value = _requiredInt(row, key);
    if (value != 0 && value != 1) {
      throw FormatException('Invalid review journal flag: $key');
    }
    return value == 1;
  }

  static int? _optionalInt(Object? raw) {
    if (raw == null) return null;
    final value = raw is num ? raw.toInt() : int.tryParse(raw.toString());
    if (value == null) {
      throw const FormatException(
        'Invalid review journal optional integer.',
      );
    }
    return value;
  }

  static String? _optionalString(Object? raw) {
    final value = raw?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  static DateTime _requiredDateTime(
    Map<String, Object?> row,
    String key,
  ) {
    final value = DateTime.tryParse(row[key]?.toString() ?? '')?.toUtc();
    if (value == null) {
      throw FormatException('Invalid review journal timestamp: $key');
    }
    return value;
  }
}

enum ReviewTransactionSink {
  attempt,
  gamification,
}

final class ReviewTransactionAcceptance {
  const ReviewTransactionAcceptance({
    required this.reviewEventId,
    required this.payloadHash,
    required this.alreadyAccepted,
  });

  final String reviewEventId;
  final String payloadHash;
  final bool alreadyAccepted;
}

final class ReviewTransactionJournalEntry {
  const ReviewTransactionJournalEntry({
    required this.envelope,
    required this.payloadHash,
    required this.attemptApplied,
    required this.gamificationApplied,
    required this.createdAtUtc,
    required this.completedAtUtc,
  });

  final ReviewTransactionEnvelope envelope;
  final String payloadHash;
  final bool attemptApplied;
  final bool gamificationApplied;
  final DateTime createdAtUtc;
  final DateTime? completedAtUtc;

  bool get isComplete =>
      attemptApplied && gamificationApplied && completedAtUtc != null;

  factory ReviewTransactionJournalEntry.fromRow(
    Map<String, Object?> row,
  ) {
    final envelope = ReviewTransactionEnvelope.fromJournalRow(row);
    final storedCardId = row['card_id']?.toString().trim() ?? '';
    if (storedCardId != envelope.cardId) {
      throw const FormatException(
        'Review journal card_id does not match the envelope.',
      );
    }
    final hash = ReviewTransactionEnvelope.validatePayloadHash(
      row['payload_hash']?.toString() ?? '',
    );
    final createdAt =
        DateTime.tryParse(row['created_at_utc']?.toString() ?? '')?.toUtc();
    if (createdAt == null) {
      throw const FormatException(
        'Invalid review journal created_at_utc.',
      );
    }
    final rawCompleted = row['completed_at_utc']?.toString() ?? '';
    final completedAt =
        rawCompleted.isEmpty ? null : DateTime.tryParse(rawCompleted)?.toUtc();
    if (rawCompleted.isNotEmpty && completedAt == null) {
      throw const FormatException(
        'Invalid review journal completed_at_utc.',
      );
    }

    return ReviewTransactionJournalEntry(
      envelope: envelope,
      payloadHash: hash,
      attemptApplied: _flag(row['attempt_applied'], 'attempt_applied'),
      gamificationApplied:
          _flag(row['gamification_applied'], 'gamification_applied'),
      createdAtUtc: createdAt,
      completedAtUtc: completedAt,
    );
  }

  static bool _flag(Object? raw, String field) {
    final value =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
    if (value != 0 && value != 1) {
      throw FormatException('Invalid review journal flag: $field');
    }
    return value == 1;
  }
}

final class ReviewTransactionJournalException implements Exception {
  const ReviewTransactionJournalException(this.code);

  final String code;

  @override
  String toString() => 'ReviewTransactionJournalException($code)';
}
