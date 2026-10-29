import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('OfflineGate', () {
    test('Denies telemetry and unrestricted network access', () {
      expect(
        OfflineGate.isOperationPermitted(OperationType.telemetry),
        isFalse,
      );
      expect(
        OfflineGate.isOperationPermitted(OperationType.unrestrictedNetwork),
        isFalse,
      );

      expect(
        () => OfflineGate.assertOperationPolicy(OperationType.telemetry),
        throwsException,
      );
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(),
        throwsException,
      );
    });

    test('Allows local operations without capability', () {
      expect(
        OfflineGate.isOperationPermitted(OperationType.localRead),
        isTrue,
      );
      expect(
        OfflineGate.isOperationPermitted(OperationType.localWrite),
        isTrue,
      );
    });

    test('Denies userRequestedDownload without capability', () {
      expect(
        OfflineGate.isOperationPermitted(OperationType.userRequestedDownload),
        isFalse,
      );
    });

    test('Denies userRequestedDownload with expired capability', () {
      final expiredCap = DownloadCapability(
        resourceId: 'pack1',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(
        OfflineGate.isOperationPermitted(
          OperationType.userRequestedDownload,
          capability: expiredCap,
        ),
        isFalse,
      );
    });

    test('Allows userRequestedDownload with valid capability', () {
      final validCap = DownloadCapability(
        resourceId: 'pack1',
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
      expect(
        OfflineGate.isOperationPermitted(
          OperationType.userRequestedDownload,
          capability: validCap,
        ),
        isTrue,
      );
    });
  });

  group('DataIntegritySigner', () {
    test('verifyManifest accepts valid manifest', () {
      final payload = {'pack': 'de-ar', 'version': 1};
      final payloadString = jsonEncode(payload);
      final hash = DataIntegritySigner.computeChecksum(payloadString);

      final manifest = {
        'payload': payload,
        'signature': {
          'keyId': DataIntegritySigner.approvedTrustedKey,
          'algorithm': 'FNV-1a',
          'hash': hash,
        },
      };

      expect(DataIntegritySigner.verifyManifest(manifest), isTrue);
    });

    test('verifyManifest rejects altered content', () {
      final payload = {'pack': 'de-ar', 'version': 1};
      final payloadString = jsonEncode(payload);
      final hash = DataIntegritySigner.computeChecksum(payloadString);

      final manifest = {
        'payload': {'pack': 'de-ar', 'version': 2}, // altered
        'signature': {
          'keyId': DataIntegritySigner.approvedTrustedKey,
          'algorithm': 'FNV-1a',
          'hash': hash,
        },
      };

      expect(DataIntegritySigner.verifyManifest(manifest), isFalse);
    });

    test('verifyManifest rejects invalid trusted key', () {
      final payload = {'pack': 'de-ar', 'version': 1};
      final payloadString = jsonEncode(payload);
      final hash = DataIntegritySigner.computeChecksum(payloadString);

      final manifest = {
        'payload': payload,
        'signature': {
          'keyId': 'rogue_key',
          'algorithm': 'FNV-1a',
          'hash': hash,
        },
      };

      expect(DataIntegritySigner.verifyManifest(manifest), isFalse);
    });

    test('verifyManifest rejects unsupported algorithm', () {
      final payload = {'pack': 'de-ar', 'version': 1};
      final payloadString = jsonEncode(payload);
      final hash = DataIntegritySigner.computeChecksum(payloadString);

      final manifest = {
        'payload': payload,
        'signature': {
          'keyId': DataIntegritySigner.approvedTrustedKey,
          'algorithm': 'SHA-256',
          'hash': hash,
        },
      };

      expect(DataIntegritySigner.verifyManifest(manifest), isFalse);
    });

    test('verifyManifest rejects forged authorization (invalid hash)', () {
      final payload = {'pack': 'de-ar', 'version': 1};

      final manifest = {
        'payload': payload,
        'signature': {
          'keyId': DataIntegritySigner.approvedTrustedKey,
          'algorithm': 'FNV-1a',
          'hash': 123456789,
        },
      };

      expect(DataIntegritySigner.verifyManifest(manifest), isFalse);
    });
  });

  group('StorageGuard', () {
    test('validateJsonIntegrity rejects empty strings', () {
      expect(StorageGuard.validateJsonIntegrity(''), isFalse);
      expect(StorageGuard.validateJsonIntegrity('   '), isFalse);
    });

    test('validateJsonIntegrity accepts valid JSON array/object', () {
      expect(StorageGuard.validateJsonIntegrity('{"a": 1}'), isTrue);
      expect(StorageGuard.validateJsonIntegrity('[1, 2, 3]'), isTrue);
    });

    test('validateManifestStructure accepts valid structure', () {
      final manifest = {
        'payload': {'pack': 'de-ar', 'version': 1},
        'signature': {
          'keyId': 'trusted_key_v1',
          'algorithm': 'FNV-1a',
          'hash': 123456789,
        },
      };
      expect(
        StorageGuard.validateManifestStructure(jsonEncode(manifest)),
        isTrue,
      );
    });

    test('validateManifestStructure rejects missing manifests / critical fields', () {
      final manifest1 = {'payload': {}};
      expect(
        StorageGuard.validateManifestStructure(jsonEncode(manifest1)),
        isFalse,
      );

      final manifest2 = {
        'signature': {
          'keyId': 'trusted_key_v1',
          'algorithm': 'FNV-1a',
          'hash': 123456789,
        }
      };
      expect(
        StorageGuard.validateManifestStructure(jsonEncode(manifest2)),
        isFalse,
      );

      final manifest3 = {
        'payload': {},
        'signature': {
          'keyId': 'trusted_key_v1',
          'algorithm': 'FNV-1a',
        }
      };
      expect(
        StorageGuard.validateManifestStructure(jsonEncode(manifest3)),
        isFalse,
      );
    });
  });
}
