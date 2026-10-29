import 'dart:async';
import 'dart:convert';

import 'canonical_content_gate.dart';
import 'content_card.dart';
import 'content_cas_manifest.dart';
import 'validation_cache.dart';

typedef LanguagePackGenerator = Future<List<int>> Function(
  LanguagePackRequest request,
);

final class LanguagePackRequest {
  const LanguagePackRequest({
    required this.packId,
    required this.languageCode,
    required this.source,
    this.requireManifestVerification = false,
  });

  final String packId;
  final String languageCode;
  final String source;
  final bool requireManifestVerification;
}

final class LanguagePackAudit {
  const LanguagePackAudit({
    required this.packId,
    required this.languageCode,
    required this.valid,
    required this.packChecksum,
    required this.wholePackCacheHit,
    required this.cardCount,
    required this.validatedCards,
    required this.cachedCards,
    required this.errorCode,
    this.promotion = const ContentPromotionBatch.empty(),
  });

  final String packId;
  final String languageCode;
  final bool valid;
  final String? packChecksum;
  final bool wholePackCacheHit;
  final int cardCount;
  final int validatedCards;
  final int cachedCards;
  final String? errorCode;
  final ContentPromotionBatch promotion;

  Map<String, Object?> toJson() => <String, Object?>{
        'packId': packId,
        'languageCode': languageCode,
        'valid': valid,
        'packChecksum': packChecksum,
        'wholePackCacheHit': wholePackCacheHit,
        'cardCount': cardCount,
        'validatedCards': validatedCards,
        'cachedCards': cachedCards,
        'canonicalCards': promotion.canonicalCount,
        'quarantinedCards': promotion.quarantineCount,
        if (promotion.quarantine.isNotEmpty)
          'quarantine': promotion.quarantine
              .map((entry) => entry.toAuditJson())
              .toList(growable: false),
        'errorCode': errorCode,
      };
}

final class ParallelContentPipeline {
  const ParallelContentPipeline({
    required this.generator,
    required this.cache,
    this.manifest,
    this.canonicalGate = const CanonicalContentGate(),
    this.maxParallel = 4,
  });

  final LanguagePackGenerator generator;
  final ContentValidationCache cache;
  final ContentCasManifest? manifest;
  final CanonicalContentGate canonicalGate;
  final int maxParallel;

  Stream<LanguagePackAudit> run(
    Stream<LanguagePackRequest> requests,
  ) async* {
    if (maxParallel < 1 || maxParallel > 32) {
      throw ArgumentError.value(
        maxParallel,
        'maxParallel',
        'must be between 1 and 32',
      );
    }

    final batch = <LanguagePackRequest>[];
    await for (final request in requests) {
      batch.add(request);
      if (batch.length < maxParallel) continue;

      final audits = await Future.wait(
        batch.map(_process),
        eagerError: false,
      );
      for (final audit in audits) {
        yield audit;
      }
      batch.clear();
    }

    if (batch.isNotEmpty) {
      final audits = await Future.wait(
        batch.map(_process),
        eagerError: false,
      );
      for (final audit in audits) {
        yield audit;
      }
    }
  }

  Future<LanguagePackAudit> _process(
    LanguagePackRequest request,
  ) async {
    String? packChecksum;
    try {
      final packId = request.packId.trim();
      final languageCode = _normalizeLanguage(
        request.languageCode,
      );
      if (packId.isEmpty || packId.length > 160) {
        throw const FormatException('pack id is invalid');
      }
      if (languageCode.isEmpty) {
        throw const FormatException('language code is invalid');
      }

      final bytes = await generator(request);
      PipelineContentCard.requireStrictUtf8Bytes(
        bytes,
        field: 'language pack',
      );
      packChecksum = await ValidationFingerprint.bytes(bytes);

      ContentCasEntry? manifestEntry;
      if (request.requireManifestVerification) {
        final activeManifest = manifest;
        if (activeManifest == null) {
          throw const FormatException(
            'content CAS manifest is required',
          );
        }
        manifestEntry = activeManifest.verifySource(
          source: request.source,
          packId: packId,
          languageCode: languageCode,
          checksum: packChecksum,
        );
      }

      final packCacheKey = 'pack:$languageCode:$packId';
      final wholePackCacheHit = cache.isValidated(
        key: packCacheKey,
        checksum: packChecksum,
      );

      final decoded = utf8.decode(bytes, allowMalformed: false);
      final root = jsonDecode(decoded);
      _rejectEmptyStrings(root, 'pack root');
      if (root is! Map) {
        throw const FormatException('pack root must be an object');
      }
      final json = _stringKeyedMap(root, 'pack root');
      if (json['schemaVersion'] != 1) {
        throw const FormatException(
          'schemaVersion must equal 1',
        );
      }

      final pack = _stringKeyedMap(json['pack'], 'pack');
      final declaredPackId = pack['id'];
      final declaredLanguage = pack['languageCode'];
      if (declaredPackId is! String ||
          declaredPackId.trim() != packId) {
        throw const FormatException('pack id mismatch');
      }
      if (declaredLanguage is! String ||
          _normalizeLanguage(declaredLanguage) != languageCode) {
        throw const FormatException('pack language mismatch');
      }

      final rawCards = json['cards'];
      if (rawCards is! List || rawCards.isEmpty) {
        throw const FormatException(
          'cards must be a non-empty array',
        );
      }

      if (manifestEntry != null &&
          rawCards.length != manifestEntry.cardCount) {
        throw const FormatException(
          'content CAS card count mismatch',
        );
      }

      var validatedCards = 0;
      var cachedCards = 0;
      final seenCardIds = <String>{};
      final parsedCards = <PipelineContentCard>[];

      for (final rawCard in rawCards) {
        final cardJson = _stringKeyedMap(rawCard, 'card');
        final rawId = cardJson['id'];
        final rawLanguage = cardJson['languageCode'];
        if (rawId is! String || rawId.trim().isEmpty) {
          throw const FormatException('card id is required');
        }
        final cardId = rawId.trim();
        if (!seenCardIds.add(cardId)) {
          throw FormatException(
            'duplicate card id: ' + cardId,
          );
        }
        if (rawLanguage is! String ||
            _normalizeLanguage(rawLanguage) != languageCode) {
          throw FormatException(
            'card language mismatch: ' + cardId,
          );
        }

        final card = PipelineContentCard.fromJson(cardJson);
        if (_normalizeLanguage(card.languageCode) != languageCode) {
          throw FormatException(
            'card language mismatch: ' + cardId,
          );
        }
        parsedCards.add(card);

        final checksum =
            await ValidationFingerprint.jsonValue(cardJson);
        final cardCacheKey =
            'card:$languageCode:$packId:$cardId';
        if (cache.isValidated(
          key: cardCacheKey,
          checksum: checksum,
        )) {
          cachedCards += 1;
        } else {
          cache.remember(
            key: cardCacheKey,
            checksum: checksum,
          );
          validatedCards += 1;
        }
      }

      final promotion = canonicalGate.classify(parsedCards);

      cache.remember(
        key: packCacheKey,
        checksum: packChecksum,
      );

      return LanguagePackAudit(
        packId: packId,
        languageCode: languageCode,
        valid: true,
        packChecksum: packChecksum,
        wholePackCacheHit: wholePackCacheHit,
        cardCount: rawCards.length,
        validatedCards: validatedCards,
        cachedCards: cachedCards,
        errorCode: null,
        promotion: promotion,
      );
    } on FormatException catch (error) {
      return LanguagePackAudit(
        packId: request.packId,
        languageCode: request.languageCode,
        valid: false,
        packChecksum: packChecksum,
        wholePackCacheHit: false,
        cardCount: 0,
        validatedCards: 0,
        cachedCards: 0,
        errorCode: error.message,
      );
    } on ArgumentError catch (error) {
      return LanguagePackAudit(
        packId: request.packId,
        languageCode: request.languageCode,
        valid: false,
        packChecksum: packChecksum,
        wholePackCacheHit: false,
        cardCount: 0,
        validatedCards: 0,
        cachedCards: 0,
        errorCode: error.message?.toString() ?? 'invalid_argument',
      );
    } on Object {
      return LanguagePackAudit(
        packId: request.packId,
        languageCode: request.languageCode,
        valid: false,
        packChecksum: packChecksum,
        wholePackCacheHit: false,
        cardCount: 0,
        validatedCards: 0,
        cachedCards: 0,
        errorCode: 'content_pipeline_failure',
      );
    }
  }

  static void _rejectEmptyStrings(
    Object? value,
    String path,
  ) {
    if (value is String) {
      if (value.trim().isEmpty) {
        throw FormatException('$path must not be empty');
      }
      if (!PipelineContentCard.isStrictUtf8String(value)) {
        throw FormatException(
          '$path must round-trip through strict UTF-8',
        );
      }
      return;
    }
    if (value is List) {
      for (var index = 0; index < value.length; index += 1) {
        _rejectEmptyStrings(value[index], '$path[$index]');
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw FormatException('$path keys must be strings');
        }
        _rejectEmptyStrings(
          entry.value,
          '$path.' + entry.key.toString(),
        );
      }
    }
  }

  static String _normalizeLanguage(String value) {
    final normalized =
        value.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
        .hasMatch(normalized)) {
      return '';
    }
    return normalized;
  }

  static Map<String, Object?> _stringKeyedMap(
    Object? raw,
    String field,
  ) {
    if (raw is! Map) {
      throw FormatException('$field must be an object');
    }
    final result = <String, Object?>{};
    for (final entry in raw.entries) {
      if (entry.key is! String) {
        throw FormatException(
          '$field keys must be strings',
        );
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
