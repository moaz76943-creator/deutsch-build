import 'dart:convert';

import 'package:cryptography/cryptography.dart';

final class LanguagePackDescriptor {
  const LanguagePackDescriptor({
    required this.id,
    required this.languageCode,
    required this.displayName,
    required this.version,
    required this.contractVersion,
    required this.bundleFormat,
    required this.archiveUrl,
    required this.sha256,
    required this.contentSha256,
    required this.archiveSizeBytes,
    required this.installedSizeBytes,
  });

  static const int maxArchiveSizeBytes = 64 * 1024 * 1024;
  static const int maxInstalledSizeBytes = 96 * 1024 * 1024;

  final String id;
  final String languageCode;
  final String displayName;
  final String version;
  final String contractVersion;
  final String bundleFormat;
  final Uri archiveUrl;
  final String sha256;
  final String contentSha256;
  final int archiveSizeBytes;
  final int installedSizeBytes;

  factory LanguagePackDescriptor.fromJson(Map<String, dynamic> json) {
    _rejectUnknownKeys(
        json,
        const <String>{
          'id',
          'languageCode',
          'displayName',
          'version',
          'contractVersion',
          'bundleFormat',
          'archiveUrl',
          'sha256',
          'contentSha256',
          'archiveSizeBytes',
          'installedSizeBytes',
        },
        'pack descriptor');
    final id = _requiredString(json, 'id');
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]{1,63}$').hasMatch(id)) {
      throw const FormatException('Invalid pack id.');
    }
    final languageCode = _requiredString(json, 'languageCode');
    if (!RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$')
        .hasMatch(languageCode)) {
      throw const FormatException('Invalid language code.');
    }
    final archiveUrl = Uri.tryParse(_requiredString(json, 'archiveUrl'));
    if (archiveUrl == null ||
        archiveUrl.scheme != 'https' ||
        archiveUrl.host.isEmpty) {
      throw const FormatException('Pack archiveUrl must use HTTPS.');
    }
    final bundleFormat = _requiredString(json, 'bundleFormat');
    if (bundleFormat != 'json-gzip-v1') {
      throw const FormatException('Unsupported pack bundle format.');
    }
    final checksum = _requiredSha256(json, 'sha256');
    final contentChecksum = _requiredSha256(json, 'contentSha256');
    final archiveSize = _requiredPositiveInt(json, 'archiveSizeBytes');
    final installedSize = _requiredPositiveInt(json, 'installedSizeBytes');
    if (archiveSize > maxArchiveSizeBytes) {
      throw const FormatException('Pack archive exceeds mobile safety limit.');
    }
    if (installedSize > maxInstalledSizeBytes) {
      throw const FormatException(
        'Installed pack exceeds mobile safety limit.',
      );
    }
    return LanguagePackDescriptor(
      id: id,
      languageCode: languageCode,
      displayName: _requiredString(json, 'displayName'),
      version: _requiredString(json, 'version'),
      contractVersion: _requiredString(json, 'contractVersion'),
      bundleFormat: bundleFormat,
      archiveUrl: archiveUrl,
      sha256: checksum,
      contentSha256: contentChecksum,
      archiveSizeBytes: archiveSize,
      installedSizeBytes: installedSize,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'languageCode': languageCode,
        'displayName': displayName,
        'version': version,
        'contractVersion': contractVersion,
        'bundleFormat': bundleFormat,
        'archiveUrl': archiveUrl.toString(),
        'sha256': sha256,
        'contentSha256': contentSha256,
        'archiveSizeBytes': archiveSizeBytes,
        'installedSizeBytes': installedSizeBytes,
      };

  bool sameAs(LanguagePackDescriptor other) =>
      id == other.id &&
      languageCode == other.languageCode &&
      displayName == other.displayName &&
      version == other.version &&
      contractVersion == other.contractVersion &&
      bundleFormat == other.bundleFormat &&
      archiveUrl == other.archiveUrl &&
      sha256 == other.sha256 &&
      contentSha256 == other.contentSha256 &&
      archiveSizeBytes == other.archiveSizeBytes &&
      installedSizeBytes == other.installedSizeBytes;
}

final class PackManifest {
  const PackManifest({
    required this.schemaVersion,
    required this.manifestRevision,
    required this.algorithm,
    required this.keyId,
    required this.signature,
    required this.packs,
  });

  static const int supportedSchemaVersion = 2;
  static const String supportedAlgorithm = 'Ed25519';

  final int schemaVersion;
  final int manifestRevision;
  final String algorithm;
  final String keyId;
  final String signature;
  final List<LanguagePackDescriptor> packs;

  static PackManifest empty() => const PackManifest(
        schemaVersion: supportedSchemaVersion,
        manifestRevision: 0,
        algorithm: supportedAlgorithm,
        keyId: '',
        signature: '',
        packs: <LanguagePackDescriptor>[],
      );

  factory PackManifest.parse(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException('Pack manifest must be a JSON object.');
    }
    final json = decoded.cast<String, dynamic>();
    _rejectUnknownKeys(
        json,
        const <String>{
          'schemaVersion',
          'manifestRevision',
          'algorithm',
          'keyId',
          'packs',
          'signature',
        },
        'manifest');
    final schemaVersion = _requiredPositiveInt(json, 'schemaVersion');
    if (schemaVersion != supportedSchemaVersion) {
      throw FormatException(
        'Unsupported manifest schema version: ' + schemaVersion.toString(),
      );
    }
    final algorithm = _requiredString(json, 'algorithm');
    if (algorithm != supportedAlgorithm) {
      throw const FormatException('Unsupported manifest signature algorithm.');
    }
    final keyId = _requiredString(json, 'keyId');
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$').hasMatch(keyId)) {
      throw const FormatException('Invalid manifest key id.');
    }
    final signature = _requiredString(json, 'signature');
    late final List<int> signatureBytes;
    try {
      signatureBytes = base64Decode(signature);
    } on Object {
      throw const FormatException('Manifest signature is not valid base64.');
    }
    if (signatureBytes.length != 64) {
      throw const FormatException('Ed25519 signature must be 64 bytes.');
    }
    final rawPacks = json['packs'];
    if (rawPacks is! List) {
      throw const FormatException('Manifest packs must be a list.');
    }
    final seen = <String>{};
    final packs = <LanguagePackDescriptor>[];
    for (final rawPack in rawPacks) {
      if (rawPack is! Map) {
        throw const FormatException('Invalid pack manifest entry.');
      }
      final descriptor = LanguagePackDescriptor.fromJson(
        rawPack.cast<String, dynamic>(),
      );
      if (!seen.add(descriptor.id)) {
        throw FormatException('Duplicate pack id: ' + descriptor.id);
      }
      packs.add(descriptor);
    }
    return PackManifest(
      schemaVersion: schemaVersion,
      manifestRevision: _requiredPositiveInt(json, 'manifestRevision'),
      algorithm: algorithm,
      keyId: keyId,
      signature: signature,
      packs: List<LanguagePackDescriptor>.unmodifiable(packs),
    );
  }

  LanguagePackDescriptor? packById(String packId) {
    for (final pack in packs) {
      if (pack.id == packId) return pack;
    }
    return null;
  }
}

final class InstalledLanguagePack {
  const InstalledLanguagePack({
    required this.id,
    required this.languageCode,
    required this.displayName,
    required this.version,
    required this.contractVersion,
    required this.sha256,
    required this.contentSha256,
    required this.storageBytes,
    required this.installedAt,
    required this.manifestRevision,
    required this.manifestKeyId,
    required this.manifestSignature,
    required this.databaseEncrypted,
  });

  final String id;
  final String languageCode;
  final String displayName;
  final String version;
  final String contractVersion;
  final String sha256;
  final String contentSha256;
  final int storageBytes;
  final DateTime installedAt;
  final int manifestRevision;
  final String manifestKeyId;
  final String manifestSignature;
  final bool databaseEncrypted;

  bool get hasSignedProvenance =>
      manifestRevision > 0 &&
      manifestKeyId.isNotEmpty &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(contentSha256) &&
      _validSignature(manifestSignature);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'languageCode': languageCode,
        'displayName': displayName,
        'version': version,
        'contractVersion': contractVersion,
        'sha256': sha256,
        'contentSha256': contentSha256,
        'storageBytes': storageBytes,
        'installedAt': installedAt.toUtc().toIso8601String(),
        'manifestRevision': manifestRevision,
        'manifestKeyId': manifestKeyId,
        'manifestSignature': manifestSignature,
        'databaseEncrypted': databaseEncrypted,
      };

  factory InstalledLanguagePack.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString().trim();
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]{1,63}$').hasMatch(id)) {
      throw const FormatException('Invalid installed pack id.');
    }
    final installedAt = DateTime.tryParse(
      (json['installedAt'] ?? '').toString(),
    );
    if (installedAt == null) {
      throw const FormatException('Invalid installedAt timestamp.');
    }
    return InstalledLanguagePack(
      id: id,
      languageCode: (json['languageCode'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      version: (json['version'] ?? '').toString(),
      contractVersion: (json['contractVersion'] ?? '').toString(),
      sha256: (json['sha256'] ?? '').toString().toLowerCase(),
      contentSha256: (json['contentSha256'] ?? '').toString().toLowerCase(),
      storageBytes: ((json['storageBytes'] as num?)?.toInt() ?? 0)
          .clamp(0, 1 << 50)
          .toInt(),
      installedAt: installedAt.toUtc(),
      manifestRevision:
          ((json['manifestRevision'] as num?)?.toInt() ?? 0).clamp(0, 1 << 31),
      manifestKeyId: (json['manifestKeyId'] ?? '').toString(),
      manifestSignature: (json['manifestSignature'] ?? '').toString(),
      databaseEncrypted: json['databaseEncrypted'] == true,
    );
  }

  InstalledLanguagePack copyWith({int? storageBytes}) => InstalledLanguagePack(
        id: id,
        languageCode: languageCode,
        displayName: displayName,
        version: version,
        contractVersion: contractVersion,
        sha256: sha256,
        contentSha256: contentSha256,
        storageBytes: storageBytes ?? this.storageBytes,
        installedAt: installedAt,
        manifestRevision: manifestRevision,
        manifestKeyId: manifestKeyId,
        manifestSignature: manifestSignature,
        databaseEncrypted: databaseEncrypted,
      );
}

abstract interface class PackManifestVerifier {
  Future<PackManifest> verifyAndParse(String rawJson);
}

final class RejectingPackManifestVerifier implements PackManifestVerifier {
  const RejectingPackManifestVerifier();

  @override
  Future<PackManifest> verifyAndParse(String rawJson) {
    throw const PackManifestAuthenticityException(
      'No trusted manifest public key is configured.',
    );
  }
}

final class Ed25519PackManifestVerifier implements PackManifestVerifier {
  Ed25519PackManifestVerifier({
    required Map<String, List<int>> trustedPublicKeys,
  }) : _trustedPublicKeys = Map<String, List<int>>.unmodifiable(
          trustedPublicKeys.map(
            (key, value) => MapEntry(key, List<int>.unmodifiable(value)),
          ),
        );

  final Map<String, List<int>> _trustedPublicKeys;
  final Ed25519 _algorithm = Ed25519();

  @override
  Future<PackManifest> verifyAndParse(String rawJson) async {
    final manifest = PackManifest.parse(rawJson);
    final publicKeyBytes = _trustedPublicKeys[manifest.keyId];
    if (publicKeyBytes == null || publicKeyBytes.length != 32) {
      throw const PackManifestAuthenticityException(
        'Manifest key id is not trusted.',
      );
    }
    final signatureBytes = base64Decode(manifest.signature);
    final payload = PackManifestCanonicalJson.signingBytes(rawJson);
    final valid = await _algorithm.verify(
      payload,
      signature: Signature(
        signatureBytes,
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519),
      ),
    );
    if (!valid) {
      throw const PackManifestAuthenticityException(
        'Manifest Ed25519 signature verification failed.',
      );
    }
    return manifest;
  }
}

abstract final class PackManifestVerifiers {
  static PackManifestVerifier fromSingleBase64Key({
    required String keyId,
    required String publicKeyBase64,
  }) {
    if (keyId.trim().isEmpty || publicKeyBase64.trim().isEmpty) {
      return const RejectingPackManifestVerifier();
    }
    try {
      final bytes = base64Decode(publicKeyBase64.trim());
      if (bytes.length != 32) {
        return const RejectingPackManifestVerifier();
      }
      return Ed25519PackManifestVerifier(
        trustedPublicKeys: <String, List<int>>{keyId.trim(): bytes},
      );
    } on Object {
      return const RejectingPackManifestVerifier();
    }
  }
}

final class PackManifestAuthenticityException implements Exception {
  const PackManifestAuthenticityException(this.message);
  final String message;

  @override
  String toString() => 'PackManifestAuthenticityException: ' + message;
}

abstract final class PackManifestCanonicalJson {
  static List<int> signingBytes(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException('Manifest must be an object.');
    }
    final unsigned = Map<String, dynamic>.from(decoded.cast<String, dynamic>())
      ..remove('signature');
    return utf8.encode(_encode(unsigned) + '\n');
  }

  static String _encode(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      final parts = <String>[];
      for (final key in keys) {
        parts.add(jsonEncode(key) + ':' + _encode(value[key]));
      }
      return '{' + parts.join(',') + '}';
    }
    if (value is List) {
      return '[' + value.map(_encode).join(',') + ']';
    }
    return jsonEncode(value);
  }
}

bool _validSignature(String encoded) {
  try {
    return base64Decode(encoded).length == 64;
  } on Object {
    return false;
  }
}

void _rejectUnknownKeys(
  Map<String, dynamic> json,
  Set<String> allowed,
  String path,
) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList();
  if (unknown.isNotEmpty) {
    throw FormatException(path + ' contains unknown keys.');
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = (json[key] ?? '').toString().trim();
  if (value.isEmpty || value.length > 500) {
    throw FormatException('Invalid ' + key + '.');
  }
  return value;
}

String _requiredSha256(Map<String, dynamic> json, String key) {
  final value = _requiredString(json, key).toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw FormatException('Invalid ' + key + '.');
  }
  return value;
}

int _requiredPositiveInt(Map<String, dynamic> json, String key) {
  final value = (json[key] as num?)?.toInt();
  if (value == null || value <= 0) {
    throw FormatException('Invalid ' + key + '.');
  }
  return value;
}
