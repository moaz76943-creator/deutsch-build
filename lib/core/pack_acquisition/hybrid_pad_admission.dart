import 'dart:convert';

import '../../services/pack_checksum.dart';
import '../packs/pack_models.dart';
import 'hybrid_pad_models.dart';

enum HybridPadAdmissionCode {
  shardUnavailable,
  shardManifestHashMismatch,
  shardManifestSchemaMismatch,
  shardManifestSchemaRejected,
  logicalPackSizeMismatch,
  logicalPackHashMismatch,
  logicalPackSchemaMismatch,
  logicalPackSchemaRejected,
  activationReceiptMismatch,
}

final class HybridPadAdmissionException implements Exception {
  const HybridPadAdmissionException(
    this.code,
    this.message,
  );

  final HybridPadAdmissionCode code;
  final String message;

  @override
  String toString() =>
      'HybridPadAdmissionException(${code.name}): $message';
}

abstract interface class PhysicalPadShardReader {
  Future<bool> isInstalled(String assetPackName);

  Future<List<int>> readBytes({
    required String assetPackName,
    required String relativePath,
  });
}

abstract interface class PhysicalShardManifestSchemaVerifier {
  Future<int> verifyAndReadSchemaVersion({
    required PhysicalPadShardDescriptor descriptor,
    required List<int> bytes,
  });
}

final class JsonPhysicalShardManifestSchemaVerifier
    implements PhysicalShardManifestSchemaVerifier {
  const JsonPhysicalShardManifestSchemaVerifier();

  @override
  Future<int> verifyAndReadSchemaVersion({
    required PhysicalPadShardDescriptor descriptor,
    required List<int> bytes,
  }) async {
    final decoded = jsonDecode(
      utf8.decode(bytes, allowMalformed: false),
    );
    if (decoded is! Map) {
      throw const FormatException('PAD shard manifest must be an object.');
    }
    final root = decoded.cast<String, dynamic>();
    _rejectKeys(
      root,
      const <String>{'schemaVersion', 'shard', 'logicalPacks'},
      'PAD shard manifest',
    );
    final schemaVersion = _positiveInt(root, 'schemaVersion');

    final rawShard = root['shard'];
    if (rawShard is! Map) {
      throw const FormatException('PAD shard identity must be an object.');
    }
    final shard = rawShard.cast<String, dynamic>();
    _rejectKeys(
      shard,
      const <String>{'id', 'assetPackName', 'version'},
      'PAD shard identity',
    );
    if (shard['id'] != descriptor.id ||
        shard['assetPackName'] != descriptor.assetPackName ||
        shard['version'] != descriptor.version) {
      throw const FormatException(
        'PAD shard manifest identity does not match its descriptor.',
      );
    }

    final rawLogicalPacks = root['logicalPacks'];
    if (rawLogicalPacks is! List ||
        rawLogicalPacks.length != descriptor.logicalPacks.length) {
      throw const FormatException(
        'PAD shard logical-pack inventory does not match its descriptor.',
      );
    }

    final expected = <String, LogicalPadPackDescriptor>{
      for (final item in descriptor.logicalPacks) item.id: item,
    };
    final seen = <String>{};
    for (final rawItem in rawLogicalPacks) {
      if (rawItem is! Map) {
        throw const FormatException(
          'PAD shard logical-pack entry must be an object.',
        );
      }
      final item = rawItem.cast<String, dynamic>();
      _rejectKeys(
        item,
        const <String>{
          'id',
          'kind',
          'languageCode',
          'version',
          'schemaVersion',
          'sha256',
          'sizeBytes',
          'path',
          'sourceLanguageCode',
          'targetLanguageCode',
        },
        'PAD shard logical-pack entry',
      );
      final id = _requiredString(item, 'id');
      final descriptorItem = expected[id];
      if (descriptorItem == null || !seen.add(id)) {
        throw FormatException(
          'Unexpected or duplicate PAD logical pack: $id',
        );
      }

      if (item['kind'] != descriptorItem.kind.name ||
          item['languageCode'] != descriptorItem.languageCode ||
          item['version'] != descriptorItem.version ||
          item['schemaVersion'] != descriptorItem.schemaVersion ||
          item['sha256'] != descriptorItem.sha256 ||
          item['sizeBytes'] != descriptorItem.sizeBytes ||
          item['path'] != descriptorItem.relativePath ||
          item['sourceLanguageCode'] != descriptorItem.sourceLanguageCode ||
          item['targetLanguageCode'] != descriptorItem.targetLanguageCode) {
        throw FormatException(
          'PAD logical-pack manifest mismatch: $id',
        );
      }
    }

    if (seen.length != expected.length) {
      throw const FormatException(
        'PAD shard manifest is missing logical packs.',
      );
    }
    return schemaVersion;
  }

  static void _rejectKeys(
    Map<String, dynamic> value,
    Set<String> allowed,
    String field,
  ) {
    final unknown = value.keys.where((key) => !allowed.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException(
        '$field contains unknown keys: ${unknown.join(', ')}',
      );
    }
  }

  static int _positiveInt(
    Map<String, dynamic> value,
    String key,
  ) {
    final raw = value[key];
    if (raw is! int || raw < 1) {
      throw FormatException('$key must be a positive integer.');
    }
    return raw;
  }

  static String _requiredString(
    Map<String, dynamic> value,
    String key,
  ) {
    final raw = value[key];
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return raw;
  }
}

abstract interface class LogicalPackSchemaVerifier {
  Future<int> verifyAndReadSchemaVersion({
    required LogicalPadPackDescriptor descriptor,
    required List<int> bytes,
  });
}

final class VerifiedLogicalPackReceipt {
  const VerifiedLogicalPackReceipt._({
    required this.logicalPackId,
    required this.physicalShardId,
    required this.assetPackName,
    required this.version,
    required this.schemaVersion,
    required this.sha256,
    required this.sizeBytes,
    required this.verifiedAt,
  });

  final String logicalPackId;
  final String physicalShardId;
  final String assetPackName;
  final String version;
  final int schemaVersion;
  final String sha256;
  final int sizeBytes;
  final DateTime verifiedAt;
}

final class VerifiedDirectionReceipt {
  VerifiedDirectionReceipt._({
    required this.request,
    required Iterable<VerifiedLogicalPackReceipt> logicalPacks,
    required this.verifiedAt,
  }) : logicalPacks =
            List<VerifiedLogicalPackReceipt>.unmodifiable(logicalPacks);

  final PackPairRequest request;
  final List<VerifiedLogicalPackReceipt> logicalPacks;
  final DateTime verifiedAt;

  String get pairKey => request.pairKey;

  bool coversLogicalPack(String logicalPackId) =>
      logicalPacks.any((receipt) => receipt.logicalPackId == logicalPackId);
}

final class HybridPadAdmissionGate {
  HybridPadAdmissionGate({
    required this.catalog,
    required PhysicalPadShardReader reader,
    required PhysicalShardManifestSchemaVerifier shardManifestSchemaVerifier,
    required LogicalPackSchemaVerifier schemaVerifier,
    DateTime Function()? clock,
  })  : _reader = reader,
        _shardManifestSchemaVerifier = shardManifestSchemaVerifier,
        _schemaVerifier = schemaVerifier,
        _clock = clock ?? DateTime.now;

  final HybridPadCatalog catalog;
  final PhysicalPadShardReader _reader;
  final PhysicalShardManifestSchemaVerifier _shardManifestSchemaVerifier;
  final LogicalPackSchemaVerifier _schemaVerifier;
  final DateTime Function() _clock;

  Future<VerifiedDirectionReceipt> verifyDirection(
    PackPairRequest request,
  ) async {
    final required = catalog.requirementsFor(request);
    final verifiedShardManifests = <String>{};
    final receipts = <VerifiedLogicalPackReceipt>[];

    for (final logicalPack in required) {
      final shard = catalog.shardForLogicalPack(logicalPack.id);
      final installed = await _reader.isInstalled(shard.assetPackName);
      if (!installed) {
        throw HybridPadAdmissionException(
          HybridPadAdmissionCode.shardUnavailable,
          'PAD shard is not installed: ${shard.assetPackName}',
        );
      }

      if (verifiedShardManifests.add(shard.id)) {
        await _verifyShardManifest(shard);
      }
      receipts.add(
        await _verifyLogicalPack(
          shard: shard,
          logicalPack: logicalPack,
        ),
      );
    }

    final now = _clock().toUtc();
    return VerifiedDirectionReceipt._(
      request: request,
      logicalPacks: receipts,
      verifiedAt: now,
    );
  }

  void requireActivationReceipt(
    PackPairRequest request,
    VerifiedDirectionReceipt receipt,
  ) {
    if (request.pairKey != receipt.pairKey) {
      throw const HybridPadAdmissionException(
        HybridPadAdmissionCode.activationReceiptMismatch,
        'Admission receipt does not belong to the requested direction.',
      );
    }
    final required = catalog
        .requirementsFor(request)
        .map((descriptor) => descriptor.id)
        .toSet();
    final verified =
        receipt.logicalPacks.map((item) => item.logicalPackId).toSet();
    if (required.length != verified.length ||
        !required.every(verified.contains)) {
      throw const HybridPadAdmissionException(
        HybridPadAdmissionCode.activationReceiptMismatch,
        'Admission receipt does not cover the exact logical-pack set.',
      );
    }
  }

  Future<void> _verifyShardManifest(
    PhysicalPadShardDescriptor shard,
  ) async {
    final bytes = await _reader.readBytes(
      assetPackName: shard.assetPackName,
      relativePath: shard.manifestRelativePath,
    );
    final checksum = PackChecksum.sha256Hex(bytes);
    if (checksum.toLowerCase() != shard.manifestSha256) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.shardManifestHashMismatch,
        'Physical PAD shard manifest failed SHA-256 verification: '
        '${shard.id}',
      );
    }

    late final int schemaVersion;
    try {
      schemaVersion =
          await _shardManifestSchemaVerifier.verifyAndReadSchemaVersion(
        descriptor: shard,
        bytes: bytes,
      );
    } on HybridPadAdmissionException {
      rethrow;
    } on Object catch (error) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.shardManifestSchemaRejected,
        'Physical PAD shard manifest schema rejected '
        '${shard.id}: $error',
      );
    }
    if (schemaVersion != shard.schemaVersion) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.shardManifestSchemaMismatch,
        'Physical PAD shard schema version mismatch for '
        '${shard.id}: expected ${shard.schemaVersion}, '
        'got $schemaVersion',
      );
    }
  }

  Future<VerifiedLogicalPackReceipt> _verifyLogicalPack({
    required PhysicalPadShardDescriptor shard,
    required LogicalPadPackDescriptor logicalPack,
  }) async {
    final bytes = await _reader.readBytes(
      assetPackName: shard.assetPackName,
      relativePath: logicalPack.relativePath,
    );

    if (bytes.length != logicalPack.sizeBytes) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.logicalPackSizeMismatch,
        'Logical pack size mismatch: ${logicalPack.id}',
      );
    }

    final checksum = PackChecksum.sha256Hex(bytes);
    if (checksum.toLowerCase() != logicalPack.sha256) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.logicalPackHashMismatch,
        'Logical pack failed SHA-256 verification: ${logicalPack.id}',
      );
    }

    late final int schemaVersion;
    try {
      schemaVersion = await _schemaVerifier.verifyAndReadSchemaVersion(
        descriptor: logicalPack,
        bytes: bytes,
      );
    } on HybridPadAdmissionException {
      rethrow;
    } on Object catch (error) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.logicalPackSchemaRejected,
        'Logical pack schema verification rejected '
        '${logicalPack.id}: $error',
      );
    }

    if (schemaVersion != logicalPack.schemaVersion) {
      throw HybridPadAdmissionException(
        HybridPadAdmissionCode.logicalPackSchemaMismatch,
        'Logical pack schema version mismatch for '
        '${logicalPack.id}: expected ${logicalPack.schemaVersion}, '
        'got $schemaVersion',
      );
    }

    return VerifiedLogicalPackReceipt._(
      logicalPackId: logicalPack.id,
      physicalShardId: shard.id,
      assetPackName: shard.assetPackName,
      version: logicalPack.version,
      schemaVersion: schemaVersion,
      sha256: checksum.toLowerCase(),
      sizeBytes: bytes.length,
      verifiedAt: _clock().toUtc(),
    );
  }
}
