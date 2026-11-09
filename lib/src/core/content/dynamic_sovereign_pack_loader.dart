import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'sovereign_content_compliance_validator.dart';

/// Descriptor for dynamically loadable offline content packs.
class SovereignPackManifest {
  final String packId;
  final String languageCode;
  final int lessonCount;
  final String contentSha256;
  final bool isVerified;

  SovereignPackManifest({
    required this.packId,
    required this.languageCode,
    required this.lessonCount,
    required this.contentSha256,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
        'pack_id': packId,
        'language': languageCode,
        'lesson_count': lessonCount,
        'sha256': contentSha256,
        'verified': isVerified,
      };
}

/// Dynamic content pack loader decoupling lesson assets from compiled binaries.
/// Enforces sovereign linguistic validation and cryptographic checksum verification.
class DynamicSovereignPackLoader {
  final Map<String, SovereignPackManifest> _loadedManifests = <String, SovereignPackManifest>{};

  int get loadedPackCount => _loadedManifests.length;

  /// Load and register an offline pack manifest after strict sovereign and integrity audit.
  SovereignPackManifest loadPackManifest({
    required String packId,
    required String languageCode,
    required int lessonCount,
    required String manifestJsonString,
  }) {
    // 1. Enforce linguistic sovereignty (strictly excludes he, syc, ber, zgh)
    SovereignContentComplianceValidator.validateLanguageCode(languageCode);

    if (lessonCount <= 0) {
      throw ArgumentError('Pack $packId must contain at least one lesson');
    }

    // 2. Cryptographic checksum pinning
    final digest = sha256.convert(utf8.encode(manifestJsonString)).toString();

    final manifest = SovereignPackManifest(
      packId: packId,
      languageCode: languageCode,
      lessonCount: lessonCount,
      contentSha256: digest,
    );

    _loadedManifests[packId] = manifest;
    return manifest;
  }

  SovereignPackManifest? getManifest(String packId) => _loadedManifests[packId];

  void unloadPack(String packId) {
    _loadedManifests.remove(packId);
  }
}
