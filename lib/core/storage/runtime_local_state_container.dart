import 'dart:async';
import 'dart:convert';

import '../agents/memory_models.dart';

final class RuntimeLocalStateContainer {
  RuntimeLocalStateContainer._({
    required MemoryAgentStore physicalStore,
    required Map<String, String> namespaces,
  })  : _physicalStore = physicalStore,
        _namespaces = namespaces;

  static const int schemaVersion = 1;
  static const int maxNamespaces = 16;
  static const int maxNamespaceBytes = 1024 * 1024;

  final MemoryAgentStore _physicalStore;
  final Map<String, String> _namespaces;

  Future<void> _writeQueue = Future<void>.value();
  bool _closed = false;

  static Future<RuntimeLocalStateContainer> open(
    MemoryAgentStore physicalStore,
  ) async {
    String? encoded;
    try {
      encoded = await physicalStore.read();
    } on Object {
      encoded = null;
    }

    return RuntimeLocalStateContainer._(
      physicalStore: physicalStore,
      namespaces: _decodeNamespaces(encoded),
    );
  }

  MemoryAgentStore namespace(String rawName) {
    _ensureOpen();
    final name = _validateNamespace(rawName);
    if (!_namespaces.containsKey(name) &&
        _namespaces.length >= maxNamespaces) {
      throw StateError(
        'Runtime local state namespace limit exceeded.',
      );
    }
    return _NamespacedStore(this, name);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _writeQueue.catchError((_) {});
  }

  Future<String?> _read(String name) async {
    _ensureOpen();
    return _namespaces[name];
  }

  Future<void> _write(String name, String encoded) {
    _ensureOpen();
    final bytes = utf8.encode(encoded);
    if (bytes.length > maxNamespaceBytes) {
      return Future<void>.error(
        ArgumentError.value(
          bytes.length,
          'encoded.length',
          'namespace payload exceeds $maxNamespaceBytes bytes',
        ),
      );
    }

    _namespaces[name] = encoded;
    _writeQueue = _writeQueue
        .catchError((_) {})
        .then<void>((_) => _physicalStore.write(_encodeContainer()));
    return _writeQueue;
  }

  String _encodeContainer() {
    final orderedKeys = _namespaces.keys.toList(growable: false)..sort();
    return jsonEncode(
      <String, Object?>{
        'containerSchemaVersion': schemaVersion,
        'namespaces': <String, String>{
          for (final key in orderedKeys) key: _namespaces[key]!,
        },
      },
    );
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('RuntimeLocalStateContainer is closed.');
    }
  }

  static Map<String, String> _decodeNamespaces(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return <String, String>{};

      if (decoded['containerSchemaVersion'] == schemaVersion) {
        final rawNamespaces = decoded['namespaces'];
        if (rawNamespaces is! Map) return <String, String>{};

        final restored = <String, String>{};
        for (final entry in rawNamespaces.entries) {
          if (restored.length >= maxNamespaces) break;
          final key = entry.key;
          final value = entry.value;
          if (key is! String || value is! String) continue;
          final normalized = _tryNamespace(key);
          if (normalized == null) continue;
          if (utf8.encode(value).length > maxNamespaceBytes) continue;
          restored[normalized] = value;
        }
        return restored;
      }

      final looksLikeLegacyMemory =
          decoded['schemaVersion'] is num &&
          decoded['tasks'] is List &&
          decoded['weaknesses'] is List;
      if (looksLikeLegacyMemory) {
        return <String, String>{'memory': encoded};
      }
    } on Object {
      return <String, String>{};
    }

    return <String, String>{};
  }

  static String _validateNamespace(String value) {
    final normalized = _tryNamespace(value);
    if (normalized == null) {
      throw ArgumentError.value(
        value,
        'namespace',
        'must match [a-z0-9._-] and be 1..64 characters',
      );
    }
    return normalized;
  }

  static String? _tryNamespace(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length > 64) return null;
    if (!RegExp(r'^[a-z0-9._-]+$').hasMatch(normalized)) return null;
    return normalized;
  }
}

final class _NamespacedStore implements MemoryAgentStore {
  const _NamespacedStore(this._container, this._name);

  final RuntimeLocalStateContainer _container;
  final String _name;

  @override
  Future<String?> read() => _container._read(_name);

  @override
  Future<void> write(String encoded) =>
      _container._write(_name, encoded);
}
