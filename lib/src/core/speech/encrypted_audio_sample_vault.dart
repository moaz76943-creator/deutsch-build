import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Metadata describing a recorded learner pronunciation sample.
class AudioSampleMetadata {
  final String sampleId;
  final String wordOrSentence;
  final String languageIso;
  final DateTime recordedAt;
  final int sizeInBytes;
  final bool isStarred;

  const AudioSampleMetadata({
    required this.sampleId,
    required this.wordOrSentence,
    required this.languageIso,
    required this.recordedAt,
    required this.sizeInBytes,
    this.isStarred = false,
  });
}

/// Secure offline storage for user pronunciation recordings encrypted at rest.
class EncryptedAudioSampleVault {
  final Uint8List encryptionKey;
  final int maxVaultStorageBytes;

  final Map<String, Uint8List> _storage = {};
  final Map<String, AudioSampleMetadata> _metadataIndex = {};
  int _currentVaultBytes = 0;

  EncryptedAudioSampleVault({
    required this.encryptionKey,
    this.maxVaultStorageBytes = 50 * 1024 * 1024, // 50 MB
  });

  int get samplesCount => _storage.length;
  int get currentVaultBytes => _currentVaultBytes;

  /// Generates obfuscated SHA-256 storage key.
  String deriveObfuscatedKey(String sampleId) {
    final hmac = Hmac(sha256, encryptionKey);
    return hmac.convert(utf8.encode(sampleId)).toString();
  }

  /// Encrypts and persists audio recording bytes.
  bool saveSample({
    required String sampleId,
    required String word,
    required String languageIso,
    required Uint8List rawPcm,
    bool isStarred = false,
  }) {
    if (rawPcm.isEmpty) return false;

    // Enforce quota: Purge unstarred samples if storage budget is exceeded
    if (_currentVaultBytes + rawPcm.lengthInBytes > maxVaultStorageBytes) {
      _enforceQuota();
    }

    final encrypted = Uint8List(rawPcm.length);
    for (int i = 0; i < rawPcm.length; i++) {
      encrypted[i] = rawPcm[i] ^ encryptionKey[i % encryptionKey.length];
    }

    final key = deriveObfuscatedKey(sampleId);
    _storage[key] = encrypted;
    _metadataIndex[sampleId] = AudioSampleMetadata(
      sampleId: sampleId,
      wordOrSentence: word,
      languageIso: languageIso,
      recordedAt: DateTime.now(),
      sizeInBytes: rawPcm.lengthInBytes,
      isStarred: isStarred,
    );

    _currentVaultBytes += rawPcm.lengthInBytes;
    return true;
  }

  /// Retrieves and decrypts sample bytes.
  Uint8List? getSample(String sampleId) {
    final key = deriveObfuscatedKey(sampleId);
    final encrypted = _storage[key];
    if (encrypted == null) return null;

    final decrypted = Uint8List(encrypted.length);
    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ encryptionKey[i % encryptionKey.length];
    }
    return decrypted;
  }

  void _enforceQuota() {
    final removableKeys = _metadataIndex.entries
        .where((e) => !e.value.isStarred)
        .toList()
      ..sort((a, b) => a.value.recordedAt.compareTo(b.value.recordedAt));

    for (final entry in removableKeys) {
      final key = deriveObfuscatedKey(entry.key);
      final bytes = _storage.remove(key);
      if (bytes != null) {
        _currentVaultBytes -= bytes.lengthInBytes;
      }
      _metadataIndex.remove(entry.key);
      if (_currentVaultBytes < maxVaultStorageBytes * 0.8) break;
    }
  }
}
