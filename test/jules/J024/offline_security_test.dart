import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/offline_gate.dart';
import '../../../lib/core/security/storage_guard.dart';
import '../../../lib/core/security/data_integrity_signer.dart';

void main() {
  main2();
  group('OfflineGate', () {
    test('Denies telemetry and unrestricted network', () {
      expect(
          OfflineGate.isOperationPermitted(OperationType.telemetry), isFalse);
      expect(
          OfflineGate.isOperationPermitted(OperationType.unrestrictedNetwork),
          isFalse);
    });

    test('Allows local read and write', () {
      expect(OfflineGate.isOperationPermitted(OperationType.localRead), isTrue);
      expect(
          OfflineGate.isOperationPermitted(OperationType.localWrite), isTrue);
    });

    test('Requires unexpired capability for download', () {
      expect(
          OfflineGate.isOperationPermitted(OperationType.userRequestedDownload),
          isFalse);

      final expired = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch - 1000,
        contentId: 'test',
      );
      expect(
          OfflineGate.isOperationPermitted(OperationType.userRequestedDownload,
              capability: expired),
          isFalse);

      final valid = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
        contentId: 'test',
      );
      expect(
          OfflineGate.isOperationPermitted(OperationType.userRequestedDownload,
              capability: valid),
          isTrue);
    });

    test('assertOperationPolicy throws on denial', () {
      expect(() => OfflineGate.assertOperationPolicy(OperationType.telemetry),
          throwsA(isA<StateError>()));
    });
  });

  group('StorageGuard', () {
    test('Reflects offline gate policy', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });

    test('Validates JSON integrity', () {
      expect(StorageGuard.validateJsonIntegrity('{"a": 1}'), isTrue);
      expect(StorageGuard.validateJsonIntegrity('[1, 2]'), isTrue);
      expect(StorageGuard.validateJsonIntegrity('invalid'), isFalse);
    });

    test('Validates manifest structure', () {
      final valid = {
        'algorithm': 'fnv1a',
        'hash': 123,
        'keyId': 'key-prod-ed25519-v1',
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(valid)), isTrue);

      final invalid1 = {
        'algorithm': 'fnv1a',
        'hash': 123,
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalid1)),
          isFalse);
      expect(StorageGuard.validateManifestStructure('invalid'), isFalse);
    });
  });

  group('DataIntegritySigner', () {
    test('Computes and verifies checksum', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      expect(DataIntegritySigner.verifyIntegrity(payload, hash), isTrue);
      expect(DataIntegritySigner.verifyIntegrity(payload, hash + 1), isFalse);
    });

    test('Verifies valid manifest', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'keyId': DataIntegritySigner.approvedTrustedKey,
      };
      expect(DataIntegritySigner.verifyManifest(manifest, payload), isTrue);
    });

    test('Rejects invalid algorithm or key', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);

      final badAlgo = {
        'algorithm': 'sha256',
        'hash': hash,
        'keyId': DataIntegritySigner.approvedTrustedKey,
      };
      expect(DataIntegritySigner.verifyManifest(badAlgo, payload), isFalse);

      final badKey = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'keyId': 'unknown-key',
      };
      expect(DataIntegritySigner.verifyManifest(badKey, payload), isFalse);
    });

    test('Rejects expired manifest', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'expiresAt': DateTime.now().millisecondsSinceEpoch - 1000,
      };
      expect(DataIntegritySigner.verifyManifest(manifest, payload), isFalse);
    });
  });
}

void main2() {
  group('J024 Additional Coverage', () {
    test('Forged authorization (invalid capability for download) is rejected',
        () {
      final invalidCapability = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch - 10000,
        contentId: 'test-content',
      );

      expect(
          OfflineGate.isOperationPermitted(OperationType.userRequestedDownload,
              capability: invalidCapability),
          false);

      expect(
          () => OfflineGate.assertOperationPolicy(
              OperationType.userRequestedDownload,
              capability: invalidCapability),
          throwsStateError);
      expect(
          () => OfflineGate.assertOperationPolicy(
              OperationType.userRequestedDownload),
          throwsStateError);
    });

    test('Missing manifests for content integrity fail validation', () {
      final validPayload = '{"some": "data"}';
      expect(DataIntegritySigner.verifyManifest(null, validPayload), false);
      expect(DataIntegritySigner.verifyManifest({'hash': 123}, null), false);
    });

    test('Altered content (checksum mismatch) fails validation', () {
      final payload = '{"test": "data"}';
      final alteredPayload = '{"test": "data_altered"}';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      final manifest = {
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': expectedHash,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, payload), true);
      expect(
          DataIntegritySigner.verifyManifest(manifest, alteredPayload), false);
    });

    test('Expired capabilities for manifest verification fail', () {
      final payload = '{"test": "data"}';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      final manifest = {
        'keyId': DataIntegritySigner.approvedTrustedKey,
        'algorithm': 'fnv1a',
        'hash': expectedHash,
        'expiresAt': DateTime.now().millisecondsSinceEpoch - 10000,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, payload), false);
    });

    test(
        'Network denial (unrestrictedNetwork and telemetry) are strictly enforced',
        () {
      expect(
          OfflineGate.isOperationPermitted(OperationType.unrestrictedNetwork),
          false);
      expect(OfflineGate.isOperationPermitted(OperationType.telemetry), false);
      expect(OfflineGate.isTelemetryAllowed(), false);

      expect(
          () => OfflineGate.assertOperationPolicy(
              OperationType.unrestrictedNetwork),
          throwsStateError);
      expect(() => OfflineGate.assertOperationPolicy(OperationType.telemetry),
          throwsStateError);

      if (OfflineGate.strictOfflineEnforced) {
        expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsStateError);
      }
    });

    test(
        'Verify local read/write are permitted via StorageGuard and OfflineGate',
        () {
      expect(OfflineGate.isOperationPermitted(OperationType.localRead), true);
      expect(OfflineGate.isOperationPermitted(OperationType.localWrite), true);

      expect(StorageGuard.isLocalReadPermitted(), true);
      expect(StorageGuard.isLocalWritePermitted(), true);

      expect(StorageGuard.hasPermission(StoragePermission.read), true);
      expect(StorageGuard.hasPermission(StoragePermission.write), true);
    });
  });
}
