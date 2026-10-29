import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('J024 - Offline Security, Content Trust & Zero-Privilege Gate', () {
    test('OfflineGate enforces zero network policy', () {
      expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsStateError);
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('OfflineGate rejects forged authorization', () {
      expect(OfflineGate.authorizeUserDownload(false), isFalse);
      expect(OfflineGate.authorizeUserDownload(true), isTrue);
    });

    test('OfflineGate explicitly denies telemetry', () {
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
    });

    test('StorageGuard preserves local access permissions', () {
      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
    });

    group('DataIntegritySigner manifest validation', () {
      const payload = 'test_payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      test('rejects missing manifest or payload', () {
        expect(DataIntegritySigner.verifyManifest(null, payload), isFalse);
        expect(DataIntegritySigner.verifyManifest({'hash': expectedHash, 'algorithm': 'fnv1a'}, null), isFalse);
      });

      test('rejects unsupported signing metadata', () {
        final manifest = {'hash': expectedHash, 'algorithm': 'md5'};
        expect(DataIntegritySigner.verifyManifest(manifest, payload), isFalse);
      });

      test('rejects altered content (hash mismatch)', () {
        final manifest = {'hash': expectedHash + 1, 'algorithm': 'fnv1a'};
        expect(DataIntegritySigner.verifyManifest(manifest, payload), isFalse);
      });

      test('rejects expired capabilities', () {
        final manifest = {
          'hash': expectedHash,
          'algorithm': 'fnv1a',
          'expiresAt': DateTime.now().millisecondsSinceEpoch - 10000 // 10 seconds ago
        };
        expect(DataIntegritySigner.verifyManifest(manifest, payload), isFalse);
      });

      test('accepts valid manifest without expiration', () {
        final manifest = {
          'hash': expectedHash,
          'algorithm': 'fnv1a',
        };
        expect(DataIntegritySigner.verifyManifest(manifest, payload), isTrue);
      });

      test('accepts valid manifest with future expiration', () {
        final manifest = {
          'hash': expectedHash,
          'algorithm': 'fnv1a',
          'expiresAt': DateTime.now().millisecondsSinceEpoch + 10000 // 10 seconds in future
        };
        expect(DataIntegritySigner.verifyManifest(manifest, payload), isTrue);
      });
    });
  });
}
