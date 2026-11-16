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

    test('authorizeUserDownload creates valid capability and network remains denied by default', () {
      final cap = OfflineGate.authorizeUserDownload(true, 'my-pack');
      expect(cap, isNotNull);
      expect(cap!.contentId, 'my-pack');
      expect(cap.isExpired, isFalse);

      expect(OfflineGate.authorizeUserDownload(false, 'my-pack'), isNull);

      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('assertOperationPolicy throws on denial', () {
      expect(() => OfflineGate.assertOperationPolicy(OperationType.telemetry),
          throwsA(isA<StateError>()));
    });

    test('assertZeroNetworkPolicy throws on strictly offline enforced', () {
      expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsA(isA<StateError>()));
    });
  });

  group('StorageGuard', () {
    test('Reflects offline gate policy', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);

      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
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
      expect(StorageGuard.validateManifestStructure(jsonEncode(invalid1)), isFalse);
      expect(StorageGuard.validateManifestStructure('invalid'), isFalse);
    });

    test('sanitizeWordEntries safely sanitizes entries', () {
      final rawList = [
        {'id': 1, 'word': 'test'},
        'invalid',
        ['invalid_list'],
        {'id': 2}
      ];

      final sanitized = StorageGuard.sanitizeWordEntries(rawList);
      expect(sanitized.length, 2);
      expect(sanitized[0]['word'], 'test');
      expect(sanitized[1]['id'], 2);

      expect(StorageGuard.sanitizeWordEntries('invalid'), isEmpty);
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

    test('Rejects missing manifest or payload', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'keyId': DataIntegritySigner.approvedTrustedKey,
      };

      expect(DataIntegritySigner.verifyManifest(null, payload), isFalse);
      expect(DataIntegritySigner.verifyManifest(manifest, null), isFalse);
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
