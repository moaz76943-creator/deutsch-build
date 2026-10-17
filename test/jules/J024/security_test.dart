import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('OfflineGate', () {
    test('denies general network requests', () {
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperationType.general), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperationType.general), throwsException);
    });

    test('denies telemetry requests', () {
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperationType.telemetry), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperationType.telemetry), throwsException);
    });

    test('permits authorized user-directed downloads', () {
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperationType.userDirectedDownload, authorizationToken: 'user_auth_123'), isTrue);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperationType.userDirectedDownload, authorizationToken: 'user_auth_123'), returnsNormally);
    });

    test('denies unauthorized user-directed downloads', () {
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperationType.userDirectedDownload), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperationType.userDirectedDownload, authorizationToken: 'invalid_token'), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperationType.userDirectedDownload), throwsException);
    });
  });

  group('DataIntegritySigner', () {
    const payload = '{"key":"value"}';
    final validChecksum = DataIntegritySigner.computeChecksum(payload);

    test('verifies valid manifest', () {
      final manifestJson = jsonEncode({
        'hash': validChecksum,
        'capabilities': ['content_v1'],
      });
      expect(DataIntegritySigner.verifyManifest(manifestJson), isTrue);
    });

    test('rejects missing capabilities in manifest', () {
      final manifestJson = jsonEncode({
        'hash': validChecksum,
      });
      expect(DataIntegritySigner.verifyManifest(manifestJson), isFalse);
    });

    test('rejects unsupported capabilities in manifest', () {
      final manifestJson = jsonEncode({
        'hash': validChecksum,
        'capabilities': ['content_v3_unsupported'],
      });
      expect(DataIntegritySigner.verifyManifest(manifestJson), isFalse);
    });

    test('rejects expired manifest', () {
      final manifestJson = jsonEncode({
        'hash': validChecksum,
        'capabilities': ['content_v1'],
        'expiresAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(DataIntegritySigner.verifyManifest(manifestJson), isFalse);
    });

    test('verifies valid content integrity', () {
      final manifestJson = jsonEncode({
        'hash': validChecksum,
        'capabilities': ['content_v1'],
      });
      expect(DataIntegritySigner.verifyContentIntegrity(payload, manifestJson), isTrue);
    });

    test('rejects invalid content hash', () {
      const alteredPayload = '{"key":"altered"}';
      final manifestJson = jsonEncode({
        'hash': validChecksum, // Hash corresponds to original payload
        'capabilities': ['content_v1'],
      });
      expect(DataIntegritySigner.verifyContentIntegrity(alteredPayload, manifestJson), isFalse);
    });

    test('rejects forged/invalid manifest json', () {
      expect(DataIntegritySigner.verifyContentIntegrity(payload, 'not_json'), isFalse);
    });
  });

  group('StorageGuard', () {
    const validPayload = '{"key":"value"}';
    const invalidPayload = 'not_json';
    final validChecksum = DataIntegritySigner.computeChecksum(validPayload);
    final manifestJson = jsonEncode({
      'hash': validChecksum,
      'capabilities': ['content_v1'],
    });

    test('permits local read/write on valid json', () {
      expect(StorageGuard.checkAccess(StorageAccessType.read, validPayload), isTrue);
      expect(StorageGuard.checkAccess(StorageAccessType.write, validPayload), isTrue);
    });

    test('denies access on invalid json (fail-closed)', () {
      expect(StorageGuard.checkAccess(StorageAccessType.read, invalidPayload), isFalse);
      expect(StorageGuard.checkAccess(StorageAccessType.write, invalidPayload), isFalse);
    });

    test('permits access when manifest validation passes', () {
      expect(StorageGuard.checkAccess(StorageAccessType.read, validPayload, manifestJson: manifestJson), isTrue);
    });

    test('denies access when manifest validation fails', () {
      const alteredPayload = '{"key":"altered"}';
      expect(StorageGuard.checkAccess(StorageAccessType.read, alteredPayload, manifestJson: manifestJson), isFalse);
    });
  });
}
