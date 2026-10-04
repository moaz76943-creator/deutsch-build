import 'dart:convert';

import 'content_card.dart';

final class ContentCasEntry {
  const ContentCasEntry({
    required this.source,
    required this.packId,
    required this.languageCode,
    required this.sha256,
    required this.cardCount,
  });

  final String source;
  final String packId;
  final String languageCode;
  final String sha256;
  final int cardCount;
}

final class ContentCasManifest {
  ContentCasManifest._({
    required this.contentEpoch,
    required this.referenceLanguage,
    required this.wave1Languages,
    required this.directedPairs,
    required Map<String, ContentCasEntry> entries,
  }) : _entries = Map<String, ContentCasEntry>.unmodifiable(entries);

  final String contentEpoch;
  final String referenceLanguage;
  final List<String> wave1Languages;
  final List<String> directedPairs;
  final Map<String, ContentCasEntry> _entries;

  factory ContentCasManifest.fromBytes(List<int> bytes) {
    PipelineContentCard.requireStrictUtf8Bytes(
      bytes,
      field: 'content CAS manifest',
    );
    final decoded = utf8.decode(bytes, allowMalformed: false);
    final root = jsonDecode(decoded);
    final json = _stringKeyedMap(root, 'content CAS manifest');

    if (json['schemaVersion'] != 1) {
      throw const FormatException(
        'content CAS schemaVersion must equal 1',
      );
    }
    if (json['algorithm'] != 'sha256') {
      throw const FormatException(
        'content CAS algorithm must be sha256',
      );
    }

    final contentEpoch = _requiredString(json, 'contentEpoch');
    final referenceLanguage = _requiredLanguage(
      json,
      'referenceLanguage',
    );
    final wave1Languages = _requiredStringList(
      json,
      'wave1Languages',
      normalizeLanguage: true,
    );
    if (!wave1Languages.contains(referenceLanguage)) {
      throw const FormatException(
        'reference language must belong to wave1Languages',
      );
    }

    final rawDirectedPairs = _requiredStringList(
      json,
      'directedPairs',
    );
    final directedPairs = <String>[];
    final seenPairs = <String>{};
    for (final pair in rawDirectedPairs) {
      final parts = pair.split('->');
      if (parts.length != 2) {
        throw FormatException('invalid directed pair: $pair');
      }
      final source = _normalizeLanguage(parts[0]);
      final target = _normalizeLanguage(parts[1]);
      if (source.isEmpty || target.isEmpty || source == target) {
        throw FormatException('invalid directed pair: $pair');
      }
      if (!wave1Languages.contains(source) ||
          !wave1Languages.contains(target)) {
        throw FormatException(
          'directed pair uses language outside Wave 1: $pair',
        );
      }
      final normalizedPair = '$source->$target';
      if (!seenPairs.add(normalizedPair)) {
        throw FormatException(
          'duplicate directed pair: $normalizedPair',
        );
      }
      directedPairs.add(normalizedPair);
    }

    final rawEntries = json['entries'];
    if (rawEntries is! List || rawEntries.isEmpty) {
      throw const FormatException(
        'content CAS entries must be non-empty',
      );
    }

    final entries = <String, ContentCasEntry>{};
    for (final rawEntry in rawEntries) {
      final entry = _stringKeyedMap(rawEntry, 'content CAS entry');
      final source = _requiredString(entry, 'path');
      if (!source.startsWith('assets/data/') ||
          source.startsWith('/') ||
          source.contains('..')) {
        throw FormatException(
          'content CAS path is outside assets/data: $source',
        );
      }
      final packId = _requiredString(entry, 'packId');
      final languageCode = _requiredLanguage(
        entry,
        'languageCode',
      );
      final sha256 = _requiredString(entry, 'sha256').toLowerCase();
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256)) {
        throw FormatException(
          'invalid SHA-256 for content source: $source',
        );
      }
      final cardCount = entry['cardCount'];
      if (cardCount is! int || cardCount < 1) {
        throw FormatException(
          'cardCount must be positive for content source: $source',
        );
      }
      if (!wave1Languages.contains(languageCode)) {
        throw FormatException(
          'content source uses language outside Wave 1: $source',
        );
      }
      if (entries.containsKey(source)) {
        throw FormatException(
          'duplicate content CAS path: $source',
        );
      }
      entries[source] = ContentCasEntry(
        source: source,
        packId: packId,
        languageCode: languageCode,
        sha256: sha256,
        cardCount: cardCount,
      );
    }

    return ContentCasManifest._(
      contentEpoch: contentEpoch,
      referenceLanguage: referenceLanguage,
      wave1Languages: List<String>.unmodifiable(wave1Languages),
      directedPairs: List<String>.unmodifiable(directedPairs),
      entries: entries,
    );
  }

  int get entryCount => _entries.length;

  ContentCasEntry requireEntry(String source) {
    final entry = _entries[source];
    if (entry == null) {
      throw FormatException(
        'content source is absent from CAS manifest: $source',
      );
    }
    return entry;
  }

  ContentCasEntry verifySource({
    required String source,
    required String packId,
    required String languageCode,
    required String checksum,
    int? cardCount,
  }) {
    final entry = requireEntry(source);
    final normalizedLanguage = _normalizeLanguage(languageCode);
    if (packId.trim() != entry.packId) {
      throw FormatException(
        'content CAS pack id mismatch: $source',
      );
    }
    if (normalizedLanguage != entry.languageCode) {
      throw FormatException(
        'content CAS language mismatch: $source',
      );
    }
    if (checksum.toLowerCase() != entry.sha256) {
      throw FormatException(
        'content CAS checksum mismatch: $source',
      );
    }
    if (cardCount != null && cardCount != entry.cardCount) {
      throw FormatException(
        'content CAS card count mismatch: $source',
      );
    }
    return entry;
  }

  bool supportsDirectedPair(
    String sourceLanguage,
    String targetLanguage,
  ) {
    final source = _normalizeLanguage(sourceLanguage);
    final target = _normalizeLanguage(targetLanguage);
    if (source.isEmpty || target.isEmpty) return false;
    return directedPairs.contains('$source->$target');
  }

  static String _requiredString(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key is required');
    }
    return value.trim();
  }

  static String _requiredLanguage(
    Map<String, Object?> json,
    String key,
  ) {
    final normalized = _normalizeLanguage(
      _requiredString(json, key),
    );
    if (normalized.isEmpty) {
      throw FormatException('$key is not a valid language tag');
    }
    return normalized;
  }

  static List<String> _requiredStringList(
    Map<String, Object?> json,
    String key, {
    bool normalizeLanguage = false,
  }) {
    final raw = json[key];
    if (raw is! List || raw.isEmpty) {
      throw FormatException('$key must be a non-empty array');
    }
    final values = <String>[];
    final seen = <String>{};
    for (final item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw FormatException('$key must contain non-empty strings');
      }
      final value = normalizeLanguage
          ? _normalizeLanguage(item)
          : item.trim();
      if (value.isEmpty || !seen.add(value)) {
        throw FormatException(
          '$key contains an invalid or duplicate value',
        );
      }
      values.add(value);
    }
    return values;
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
        throw FormatException('$field keys must be strings');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
