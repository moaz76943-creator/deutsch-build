import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/offline_gate.dart';
import '../../../lib/core/security/storage_guard.dart';
import '../../../lib/core/security/data_integrity_signer.dart';

void main() {
  group('OfflineGate Security Tests', () {
    test('rejects network request for telemetry', () {
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.telemetry), isFalse);
    });

    test('rejects download request without capability', () {
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.download, null), isFalse);
    });

    test('accepts download request with authorized capability', () {
      final capability = OfflineGate.authorizeUserDownload(true);
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.download, capability), isTrue);
    });

    test('rejects download request with unauthorized capability', () {
      final capability = OfflineGate.authorizeUserDownload(false);
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.download, capability), isFalse);
    });

    test('rejects general network request even with capability', () {
      final capability = OfflineGate.authorizeUserDownload(true);
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.network, capability), isFalse);
    });

    test('accepts local request', () {
      expect(OfflineGate.isNetworkRequestPermitted(OperationType.local), isTrue);
    });

    test('assertZeroNetworkPolicy throws on denial', () {
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(OperationType.download, null),
        throwsA(isA<StateError>()),
      );
    });

    test('isNetworkRequestPermitted uses correct defaults', () {
       expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('assertZeroNetworkPolicy uses correct defaults', () {
       expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsA(isA<StateError>()));
    });
  });

  group('StorageGuard Security Tests', () {
    test('allows local read/write permissions', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
    });
  });

  group('DataIntegritySigner Security Tests', () {
    test('verifyManifest returns false for missing manifest or payload', () {
      expect(DataIntegritySigner.verifyManifest(null, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'fnv1a', 'hash': 123}, null), isFalse);
    });

    test('verifyManifest returns false for invalid algorithm type or value', () {
      expect(DataIntegritySigner.verifyManifest({'algorithm': 123, 'hash': 123}, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'sha256', 'hash': 123}, 'payload'), isFalse);
    });

    test('verifyManifest returns false for missing or invalid hash type', () {
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'fnv1a'}, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'fnv1a', 'hash': '123'}, 'payload'), isFalse);
    });

    test('verifyManifest returns false for altered payload', () {
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': DataIntegritySigner.computeChecksum('payload'),
      };
      expect(DataIntegritySigner.verifyManifest(manifest, 'altered payload'), isFalse);
    });

    test('verifyManifest returns true for valid payload and manifest', () {
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': DataIntegritySigner.computeChecksum('valid payload'),
      };
      expect(DataIntegritySigner.verifyManifest(manifest, 'valid payload'), isTrue);
    });

    test('verifyManifest returns false for expired expiresAt', () {
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': DataIntegritySigner.computeChecksum('payload'),
        'expiresAt': DateTime.now().millisecondsSinceEpoch - 10000,
      };
      expect(DataIntegritySigner.verifyManifest(manifest, 'payload'), isFalse);
    });

    test('verifyManifest returns true for valid non-expired expiresAt', () {
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': DataIntegritySigner.computeChecksum('payload'),
        'expiresAt': DateTime.now().millisecondsSinceEpoch + 10000,
      };
      expect(DataIntegritySigner.verifyManifest(manifest, 'payload'), isTrue);
    });
  });
}
