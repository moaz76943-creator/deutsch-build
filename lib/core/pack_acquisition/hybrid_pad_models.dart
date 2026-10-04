import '../packs/pack_models.dart';

enum LogicalPadPackKind {
  languageCore,
  pairOverlay,
  audio,
}

final class LogicalPadPackDescriptor {
  LogicalPadPackDescriptor({
    required String id,
    required this.kind,
    required String languageCode,
    required String version,
    required this.schemaVersion,
    required String sha256,
    required this.sizeBytes,
    required String relativePath,
    String? sourceLanguageCode,
    String? targetLanguageCode,
  })  : id = _stableToken(id, 'logical pack id'),
        languageCode = _language(languageCode, 'languageCode'),
        version = _version(version),
        sha256 = _sha256(sha256, 'logical pack sha256'),
        relativePath = _safeRelativePath(relativePath),
        sourceLanguageCode = sourceLanguageCode == null
            ? null
            : _language(sourceLanguageCode, 'sourceLanguageCode'),
        targetLanguageCode = targetLanguageCode == null
            ? null
            : _language(targetLanguageCode, 'targetLanguageCode') {
    if (schemaVersion < 1 || schemaVersion > 1 << 20) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'must be a positive bounded schema version',
      );
    }
    if (sizeBytes < 1 || sizeBytes > 512 * 1024 * 1024) {
      throw ArgumentError.value(
        sizeBytes,
        'sizeBytes',
        'must be between 1 byte and 512 MiB',
      );
    }

    final source = this.sourceLanguageCode;
    final target = this.targetLanguageCode;
    if (kind == LogicalPadPackKind.pairOverlay) {
      if (source == null || target == null || source == target) {
        throw ArgumentError(
          'pairOverlay requires distinct source and target languages',
        );
      }
      if (this.languageCode != target) {
        throw ArgumentError(
          'pairOverlay languageCode must match its directed target language',
        );
      }
    } else if (source != null || target != null) {
      throw ArgumentError(
        'Only pairOverlay logical packs may declare directed endpoints',
      );
    }
  }

  final String id;
  final LogicalPadPackKind kind;
  final String languageCode;
  final String version;
  final int schemaVersion;
  final String sha256;
  final int sizeBytes;
  final String relativePath;
  final String? sourceLanguageCode;
  final String? targetLanguageCode;

  String? get pairKey {
    final source = sourceLanguageCode;
    final target = targetLanguageCode;
    if (source == null || target == null) return null;
    return '$source->$target';
  }
}

final class PhysicalPadShardDescriptor {
  PhysicalPadShardDescriptor({
    required String id,
    required String assetPackName,
    required String version,
    required this.schemaVersion,
    required String manifestSha256,
    String manifestRelativePath = 'manifest/shard.json',
    required Iterable<LogicalPadPackDescriptor> logicalPacks,
  })  : id = _stableToken(id, 'physical shard id'),
        assetPackName = _assetPackName(assetPackName),
        version = _version(version),
        manifestSha256 = _sha256(
          manifestSha256,
          'physical shard manifest sha256',
        ),
        manifestRelativePath = _safeRelativePath(manifestRelativePath),
        logicalPacks = List<LogicalPadPackDescriptor>.unmodifiable(
          logicalPacks,
        ) {
    if (schemaVersion < 1 || schemaVersion > 1 << 20) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'must be a positive bounded schema version',
      );
    }
    if (this.logicalPacks.isEmpty) {
      throw ArgumentError('Physical PAD shard must contain logical packs.');
    }

    final ids = <String>{};
    final paths = <String>{manifestRelativePath};
    for (final pack in this.logicalPacks) {
      if (!ids.add(pack.id)) {
        throw ArgumentError('Duplicate logical pack id in shard: ${pack.id}');
      }
      if (!paths.add(pack.relativePath)) {
        throw ArgumentError(
          'Duplicate or reserved logical pack path: ${pack.relativePath}',
        );
      }
    }
  }

  final String id;
  final String assetPackName;
  final String version;
  final int schemaVersion;
  final String manifestSha256;
  final String manifestRelativePath;
  final List<LogicalPadPackDescriptor> logicalPacks;
}

final class HybridPadCatalog {
  HybridPadCatalog(Iterable<PhysicalPadShardDescriptor> shards)
      : shards = List<PhysicalPadShardDescriptor>.unmodifiable(shards) {
    if (this.shards.isEmpty) {
      throw ArgumentError('Hybrid PAD catalog cannot be empty.');
    }

    final shardIds = <String>{};
    final assetPackNames = <String>{};
    final languageCoreIds = <String, String>{};
    final logicalIds = <String>{};

    for (final shard in this.shards) {
      if (!shardIds.add(shard.id)) {
        throw ArgumentError('Duplicate physical shard id: ${shard.id}');
      }
      if (!assetPackNames.add(shard.assetPackName)) {
        throw ArgumentError(
          'Duplicate PAD asset pack name: ${shard.assetPackName}',
        );
      }
      for (final pack in shard.logicalPacks) {
        if (!logicalIds.add(pack.id)) {
          throw ArgumentError(
            'Logical pack cannot belong to multiple shards: ${pack.id}',
          );
        }
        _logicalToShard[pack.id] = shard;
        _logicalById[pack.id] = pack;

        if (pack.kind == LogicalPadPackKind.languageCore) {
          final previous = languageCoreIds[pack.languageCode];
          if (previous != null) {
            throw ArgumentError(
              'Multiple languageCore logical packs for '
              '${pack.languageCode}: $previous and ${pack.id}',
            );
          }
          languageCoreIds[pack.languageCode] = pack.id;
          _languageCoreByLanguage[pack.languageCode] = pack;
        } else if (pack.kind == LogicalPadPackKind.pairOverlay) {
          final pairKey = pack.pairKey!;
          if (_overlayByPair.containsKey(pairKey)) {
            throw ArgumentError(
              'Duplicate directed pair overlay for $pairKey',
            );
          }
          _overlayByPair[pairKey] = pack;
        }
      }
    }
  }

  final List<PhysicalPadShardDescriptor> shards;
  final Map<String, PhysicalPadShardDescriptor> _logicalToShard =
      <String, PhysicalPadShardDescriptor>{};
  final Map<String, LogicalPadPackDescriptor> _logicalById =
      <String, LogicalPadPackDescriptor>{};
  final Map<String, LogicalPadPackDescriptor> _languageCoreByLanguage =
      <String, LogicalPadPackDescriptor>{};
  final Map<String, LogicalPadPackDescriptor> _overlayByPair =
      <String, LogicalPadPackDescriptor>{};

  LogicalPadPackDescriptor requireLogicalPack(String id) {
    final normalized = _stableToken(id, 'logical pack id');
    final value = _logicalById[normalized];
    if (value == null) {
      throw StateError('logical_pack_not_registered:$normalized');
    }
    return value;
  }

  PhysicalPadShardDescriptor shardForLogicalPack(String id) {
    final normalized = _stableToken(id, 'logical pack id');
    final value = _logicalToShard[normalized];
    if (value == null) {
      throw StateError('logical_pack_shard_not_registered:$normalized');
    }
    return value;
  }

  LogicalPadPackDescriptor requireLanguageCore(String languageCode) {
    final normalized = _language(languageCode, 'languageCode');
    final value = _languageCoreByLanguage[normalized];
    if (value == null) {
      throw StateError('language_core_not_registered:$normalized');
    }
    return value;
  }

  LogicalPadPackDescriptor? directedOverlay(
    String sourceLanguageCode,
    String targetLanguageCode,
  ) {
    final source = _language(sourceLanguageCode, 'sourceLanguageCode');
    final target = _language(targetLanguageCode, 'targetLanguageCode');
    if (source == target) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }
    return _overlayByPair['$source->$target'];
  }

  List<LogicalPadPackDescriptor> requirementsFor(
    PackPairRequest request,
  ) {
    final pairKey = request.pairKey;
    final required = <LogicalPadPackDescriptor>[
      requireLanguageCore(request.source),
      requireLanguageCore(request.target),
    ];
    final overlay = _overlayByPair[pairKey];
    if (overlay != null) required.add(overlay);
    return List<LogicalPadPackDescriptor>.unmodifiable(required);
  }
}

String _stableToken(String raw, String field) {
  final value = raw.trim().toLowerCase();
  if (!RegExp(r'^[a-z0-9][a-z0-9._-]{0,79}$').hasMatch(value)) {
    throw ArgumentError.value(raw, field, 'must be a stable token');
  }
  return value;
}

String _assetPackName(String raw) {
  final value = raw.trim().toLowerCase();
  if (!RegExp(r'^[a-z][a-z0-9_]{0,63}$').hasMatch(value)) {
    throw ArgumentError.value(
      raw,
      'assetPackName',
      'must be a stable Android asset-pack module token',
    );
  }
  return value;
}

String _language(String raw, String field) {
  final value = raw.trim().replaceAll('_', '-').toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$').hasMatch(value)) {
    throw ArgumentError.value(raw, field, 'must be a valid language tag');
  }
  return value;
}

String _version(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value.length > 80) {
    throw ArgumentError.value(raw, 'version', 'must be 1..80 characters');
  }
  return value;
}

String _sha256(String raw, String field) {
  final value = raw.trim().toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw ArgumentError.value(raw, field, 'must be a SHA-256 hex digest');
  }
  return value;
}

String _safeRelativePath(String raw) {
  final value = raw.trim().replaceAll('\\', '/');
  final segments = value.split('/');
  if (value.isEmpty ||
      value.startsWith('/') ||
      value.length > 240 ||
      segments.any(
        (segment) =>
            segment.isEmpty || segment == '.' || segment == '..',
      )) {
    throw ArgumentError.value(
      raw,
      'relativePath',
      'must remain inside the physical PAD shard',
    );
  }
  return value;
}
