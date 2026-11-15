import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';

void main() {
  group('OfflineGate', () {
    test('local read/write are permitted', () {
      expect(OfflineGate.isOperationPermitted(OperationType.localRead), isTrue);
      expect(OfflineGate.isOperationPermitted(OperationType.localWrite), isTrue);
    });

    test('telemetry and unrestricted network are rejected', () {
      expect(OfflineGate.isOperationPermitted(OperationType.telemetry), isFalse);
      expect(OfflineGate.isOperationPermitted(OperationType.unrestrictedNetwork), isFalse);
    });

    test('unrestricted network access throws when asserting policy', () {
      expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsStateError);
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('authorizeUserDownload requires explicit consent and valid capability', () {
      // Missing capability
      expect(OfflineGate.authorizeUserDownload(true), isFalse);

      // Invalid (expired) capability
      final expiredCap = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch - 10000,
        contentId: 'test_content',
      );
      expect(OfflineGate.authorizeUserDownload(true, capability: expiredCap), isFalse);

      // No consent but valid capability
      final validCap = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
        contentId: 'test_content',
      );
      expect(OfflineGate.authorizeUserDownload(false, capability: validCap), isFalse);

      // Consent and valid capability
      expect(OfflineGate.authorizeUserDownload(true, capability: validCap), isTrue);
    });

    test('userRequestedDownload operation requires valid capability', () {
      expect(OfflineGate.isOperationPermitted(OperationType.userRequestedDownload), isFalse);

      final expiredCap = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch - 10000,
        contentId: 'test_content',
      );
      expect(OfflineGate.isOperationPermitted(OperationType.userRequestedDownload, capability: expiredCap), isFalse);

      final validCap = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
        contentId: 'test_content',
      );
      expect(OfflineGate.isOperationPermitted(OperationType.userRequestedDownload, capability: validCap), isTrue);
    });
  });

  group('StorageGuard', () {
    test('isLocalReadPermitted and isLocalWritePermitted are delegated to OfflineGate', () {
      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
    });
  });

  group('DataIntegritySigner', () {
    test('verifyManifest handles missing manifests and payloads', () {
      expect(DataIntegritySigner.verifyManifest(null, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'hash': 123}, null), isFalse);
    });

    test('verifyManifest rejects missing or unsupported signing metadata', () {
      final validPayload = 'test data';
      final validHash = DataIntegritySigner.computeChecksum(validPayload);

      // Missing keyId
      expect(DataIntegritySigner.verifyManifest({
        'algorithm': 'fnv1a',
        'hash': validHash,
      }, validPayload), isFalse);

      // Wrong keyId
      expect(DataIntegritySigner.verifyManifest({
        'keyId': 'key-prod-ed25519-v2', // unauthorized
        'algorithm': 'fnv1a',
        'hash': validHash,
      }, validPayload), isFalse);

      // Wrong algorithm
      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'sha256', // unauthorized
        'hash': validHash,
      }, validPayload), isFalse);

      // Missing hash
      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
      }, validPayload), isFalse);

      // Invalid hash type
      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': 'not-an-int'
      }, validPayload), isFalse);
    });

    test('verifyManifest checks expiration', () {
      final validPayload = 'test data';
      final validHash = DataIntegritySigner.computeChecksum(validPayload);

      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': validHash,
        'expiresAt': DateTime.now().millisecondsSinceEpoch - 10000,
      }, validPayload), isFalse);

      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': validHash,
        'expiresAt': DateTime.now().millisecondsSinceEpoch + 10000,
      }, validPayload), isTrue);
    });

    test('verifyManifest rejects altered content', () {
      final validPayload = 'test data';
      final alteredPayload = 'test data altered';
      final validHash = DataIntegritySigner.computeChecksum(validPayload);

      expect(DataIntegritySigner.verifyManifest({
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': validHash,
      }, alteredPayload), isFalse);
    });
  });
}
