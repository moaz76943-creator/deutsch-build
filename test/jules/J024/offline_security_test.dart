import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/offline_gate.dart';
import '../../../lib/core/security/storage_guard.dart';
import '../../../lib/core/security/data_integrity_signer.dart';

void main() {
  group('OfflineGate', () {
    test('Denies telemetry and unrestricted network', () {
      expect(OfflineGate.isOperationPermitted(OperationType.telemetry), isFalse);
      expect(OfflineGate.isOperationPermitted(OperationType.unrestrictedNetwork), isFalse);
    });

    test('Allows local read and write', () {
      expect(OfflineGate.isOperationPermitted(OperationType.localRead), isTrue);
      expect(OfflineGate.isOperationPermitted(OperationType.localWrite), isTrue);
    });

    test('Requires unexpired capability for download', () {
      expect(OfflineGate.isOperationPermitted(OperationType.userRequestedDownload), isFalse);

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

    test('authorizeUserDownload enforces capability binding', () {
      expect(OfflineGate.authorizeUserDownload(false, 'test'), isNull);

      final capability = OfflineGate.authorizeUserDownload(true, 'test');
      expect(capability, isNotNull);
      expect(capability!.contentId, 'test');
      expect(capability.isExpired, isFalse);
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

      final validWithExpires = {
        'algorithm': 'fnv1a',
        'hash': 123,
        'keyId': 'key-prod-ed25519-v1',
        'expiresAt': DateTime.now().millisecondsSinceEpoch + 10000,
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(validWithExpires)), isTrue);

      final invalidMissingFields = {
        'algorithm': 'fnv1a',
        'hash': 123,
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalidMissingFields)), isFalse);
      expect(StorageGuard.validateManifestStructure('invalid'), isFalse);

      final invalidTypeAlgo = {
        'algorithm': 123,
        'hash': 123,
        'keyId': 'key',
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalidTypeAlgo)), isFalse);

      final invalidTypeHash = {
        'algorithm': 'fnv1a',
        'hash': '123',
        'keyId': 'key',
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalidTypeHash)), isFalse);

      final invalidTypeKeyId = {
        'algorithm': 'fnv1a',
        'hash': 123,
        'keyId': 123,
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalidTypeKeyId)), isFalse);

      final invalidTypeExpiresAt = {
        'algorithm': 'fnv1a',
        'hash': 123,
        'keyId': 'key-prod-ed25519-v1',
        'expiresAt': 'not_an_int',
      };
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalidTypeExpiresAt)), isFalse);
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

      expect(DataIntegritySigner.verifyManifest(null, payload), isFalse);
      expect(DataIntegritySigner.verifyManifest(manifest, null), isFalse);
    });

    test('Rejects altered payload', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'keyId': DataIntegritySigner.approvedTrustedKey,
      };

      final alteredPayload = 'altered payload';
      expect(DataIntegritySigner.verifyManifest(manifest, alteredPayload), isFalse);
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
