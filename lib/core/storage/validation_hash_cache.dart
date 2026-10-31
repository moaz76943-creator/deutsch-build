import 'dart:convert';

import '../agents/memory_models.dart';

final class ValidationCacheResult {
  const ValidationCacheResult({
    required this.cacheHit,
    required this.validated,
    required this.contentHash,
  });

  final bool cacheHit;
  final bool validated;
  final String contentHash;
}

final class ValidationCacheEntry {
  const ValidationCacheEntry({
    required this.scopeKey,
    required this.contentHash,
    required this.validatorVersion,
    required this.validatedAtEpochMs,
  });

  final String scopeKey;
  final String contentHash;
  final String validatorVersion;
  final int validatedAtEpochMs;

  Map<String, Object?> toJson() => <String, Object?>{
        'scopeKey': scopeKey,
        'contentHash': contentHash,
        'validatorVersion': validatorVersion,
        'validatedAtEpochMs': validatedAtEpochMs,
      };

  static ValidationCacheEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final scopeKey = raw['scopeKey'];
    final contentHash = raw['contentHash'];
    final validatorVersion = raw['validatorVersion'];
    if (scopeKey is! String ||
        !_validToken(scopeKey, 240) ||
        contentHash is! String ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(contentHash) ||
        validatorVersion is! String ||
        !_validToken(validatorVersion, 80)) {
      return null;
    }

    return ValidationCacheEntry(
      scopeKey: scopeKey.trim(),
      contentHash: contentHash,
      validatorVersion: validatorVersion.trim(),
      validatedAtEpochMs:
          _asInt(raw['validatedAtEpochMs'])
              .clamp(0, 4102444800000)
              .toInt(),
    );
  }
}

final class ValidationHashCache {
  ValidationHashCache._({
    required MemoryAgentStore store,
    required Map<String, ValidationCacheEntry> entries,
  })  : _store = store,
        _entries = entries;

  static const int schemaVersion = 1;
  static const int maxEntries = 2048;

  final MemoryAgentStore _store;
  final Map<String, ValidationCacheEntry> _entries;
  final Map<String, Future<ValidationCacheResult>> _inflight =
      <String, Future<ValidationCacheResult>>{};

  Future<void> _writeQueue = Future<void>.value();
  bool _closed = false;
  int _hits = 0;
  int _misses = 0;

  static Future<ValidationHashCache> open(
    MemoryAgentStore store,
  ) async {
    String? encoded;
    try {
      encoded = await store.read();
    } on Object {
      encoded = null;
    }

    return ValidationHashCache._(
      store: store,
      entries: _decodeEntries(encoded),
    );
  }

  int get entryCount => _entries.length;
  int get hits => _hits;
  int get misses => _misses;

  bool containsValid({
    required String scopeKey,
    required String content,
    required String validatorVersion,
  }) {
    _ensureOpen();
    final scope = _token(scopeKey, 'scopeKey', 240);
    final version = _token(
      validatorVersion,
      'validatorVersion',
      80,
    );
    final hash = ContentChecksum.compute(
      scopeKey: scope,
      content: content,
      validatorVersion: version,
    );
    final entry = _entries[scope];
    return entry != null &&
        entry.contentHash == hash &&
        entry.validatorVersion == version;
  }

  Future<ValidationCacheResult> validateOnce({
    required String scopeKey,
    required String content,
    required String validatorVersion,
    required Future<bool> Function() validator,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    final scope = _token(scopeKey, 'scopeKey', 240);
    final version = _token(
      validatorVersion,
      'validatorVersion',
      80,
    );
    final hash = ContentChecksum.compute(
      scopeKey: scope,
      content: content,
      validatorVersion: version,
    );
    final existing = _entries[scope];

    if (existing != null &&
        existing.contentHash == hash &&
        existing.validatorVersion == version) {
      _hits += 1;
      return Future<ValidationCacheResult>.value(
        ValidationCacheResult(
          cacheHit: true,
          validated: true,
          contentHash: hash,
        ),
      );
    }

    _misses += 1;
    final inflightKey = '$scope|$version|$hash';
    final running = _inflight[inflightKey];
    if (running != null) return running;

    final future = _runValidation(
      scope: scope,
      contentHash: hash,
      validatorVersion: version,
      validator: validator,
      occurredAtEpochMs:
          occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    _inflight[inflightKey] = future;
    return future.whenComplete(() => _inflight.remove(inflightKey));
  }

  Future<void> invalidate(String scopeKey) {
    _ensureOpen();
    final scope = _token(scopeKey, 'scopeKey', 240);
    if (_entries.remove(scope) == null) {
      return Future<void>.value();
    }
    return _persist();
  }

  Future<void> flush() => _writeQueue;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final pending = _inflight.values.toList(growable: false);
    if (pending.isNotEmpty) {
      try {
        await Future.wait<ValidationCacheResult>(pending);
      } on Object {
        // Validation failures are contained by their callers.
      }
    }
    try {
      await flush();
    } on Object {
      // Local persistence failures must not crash shutdown.
    }
  }

  Future<ValidationCacheResult> _runValidation({
    required String scope,
    required String contentHash,
    required String validatorVersion,
    required Future<bool> Function() validator,
    required int occurredAtEpochMs,
  }) async {
    final validated = await validator();
    if (!validated || _closed) {
      return ValidationCacheResult(
        cacheHit: false,
        validated: validated,
        contentHash: contentHash,
      );
    }

    _entries[scope] = ValidationCacheEntry(
      scopeKey: scope,
      contentHash: contentHash,
      validatorVersion: validatorVersion,
      validatedAtEpochMs:
          occurredAtEpochMs.clamp(0, 4102444800000).toInt(),
    );
    _trim();
    await _persist();

    return ValidationCacheResult(
      cacheHit: false,
      validated: true,
      contentHash: contentHash,
    );
  }

  Future<void> _persist() {
    final encoded = _encode();
    _writeQueue = _writeQueue
        .catchError((_) {})
        .then<void>((_) => _store.write(encoded));
    return _writeQueue;
  }

  String _encode() {
    final ordered = _entries.values.toList(growable: false)
      ..sort((a, b) => a.scopeKey.compareTo(b.scopeKey));
    return jsonEncode(
      <String, Object?>{
        'schemaVersion': schemaVersion,
        'entries': ordered.map((entry) => entry.toJson()).toList(),
      },
    );
  }

  void _trim() {
    if (_entries.length <= maxEntries) return;
    final ranked = _entries.values.toList(growable: false)
      ..sort(
        (a, b) => b.validatedAtEpochMs.compareTo(
          a.validatedAtEpochMs,
        ),
      );
    final keep = ranked.take(maxEntries).map((entry) => entry.scopeKey).toSet();
    _entries.removeWhere((key, _) => !keep.contains(key));
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('ValidationHashCache is closed.');
    }
  }

  static Map<String, ValidationCacheEntry> _decodeEntries(
    String? encoded,
  ) {
    if (encoded == null || encoded.trim().isEmpty) {
      return <String, ValidationCacheEntry>{};
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map ||
          _asInt(decoded['schemaVersion']) != schemaVersion) {
        return <String, ValidationCacheEntry>{};
      }

      final entries = <String, ValidationCacheEntry>{};
      final rawEntries = decoded['entries'];
      if (rawEntries is List) {
        for (final raw in rawEntries.take(maxEntries)) {
          final entry = ValidationCacheEntry.fromJson(raw);
          if (entry != null) entries[entry.scopeKey] = entry;
        }
      }
      return entries;
    } on Object {
      return <String, ValidationCacheEntry>{};
    }
  }
}

abstract final class ContentChecksum {
  static const int _mask32 = 0xffffffff;
  static const int _prime = 16777619;

  static String compute({
    required String scopeKey,
    required String content,
    required String validatorVersion,
  }) {
    final bytes = utf8.encode(
      '${validatorVersion.trim()}\u0000'
      '${scopeKey.trim()}\u0000'
      '${content.trim()}',
    );

    var first = 2166136261;
    var second = 2246822519;
    var third = 3266489917;
    var fourth = 668265263;

    for (final byte in bytes) {
      first = ((first ^ byte) * _prime) & _mask32;
      second =
          ((second ^ ((byte + 0x3d) & 0xff)) * _prime) & _mask32;
      third =
          ((third ^ ((byte + 0x7f) & 0xff)) * _prime) & _mask32;
      fourth =
          ((fourth ^ ((byte + 0xb5) & 0xff)) * _prime) & _mask32;

      second = _rotateLeft32(second, 5);
      third = _rotateLeft32(third, 11);
      fourth = _rotateLeft32(fourth, 17);
    }

    return _hex32(first) +
        _hex32(second) +
        _hex32(third) +
        _hex32(fourth);
  }

  static int _rotateLeft32(int value, int shift) =>
      ((value << shift) | (value >> (32 - shift))) & _mask32;

  static String _hex32(int value) =>
      (value & _mask32).toRadixString(16).padLeft(8, '0');
}

String _token(String value, String field, int maxLength) {
  final normalized = value.trim();
  if (!_validToken(normalized, maxLength)) {
    throw ArgumentError.value(
      value,
      field,
      'must be 1..$maxLength characters',
    );
  }
  return normalized;
}

bool _validToken(String value, int maxLength) =>
    value.trim().isNotEmpty && value.trim().length <= maxLength;

int _asInt(Object? value) => value is num ? value.toInt() : 0;
